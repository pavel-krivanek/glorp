"
This is a command based on one or more in-memory rows. The purposes is to write, or delete that row or rows. This knows enough to be able to use features like array binding to do the row operations more efficiently.

Subclasses must implement the following messages:
	bound values
		arrayBoundFields
		singleRowBoundFields

Instance Variables:
	allRows	<(Collection of: (DatabaseRow))> A collection of rows. May be nil. If we have multiples, then we will be array bound or otherwise bulk-written under certain circumstances.
	row	<DatabaseRow>	The primary row, either the single row we're writing, or the one we're writing right now out of the allRows collection.
	rowCount	<Integer>	The row count from the last statement we executed.
	succeeded	<Boolean>	Has the statement overall succeded or failed.


"
Class {
	#name : #RowBasedCommand,
	#superclass : #DatabaseCommand,
	#instVars : [
		'row',
		'allRows',
		'rowCount',
		'failed'
	],
	#category : #'GlorpDatabase-GlorpCore'
}

{ #category : #'instance creation' }
RowBasedCommand class >> forRow: aDatabaseRow useBinding: aBoolean session: aSession [
	"The caller knows there is only one row, thus #allRows: is not called and not set."

	^self new
		row: aDatabaseRow;
		useBinding: aBoolean;
		session: aSession;
		yourself.
]

{ #category : #'instance creation' }
RowBasedCommand class >> forRows: aCollectionOfDatabaseRows useBinding: aBoolean session: aSession [
	"The calling path ensures there is more than one row."

	^self new
		row: aCollectionOfDatabaseRows first;
		allRows: aCollectionOfDatabaseRows;
		useBinding: aBoolean;
		session: aSession;
		yourself
]

{ #category : #'VisualWorks metadata' }
RowBasedCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
RowBasedCommand >> allRows [
	^allRows.
]

{ #category : #accessing }
RowBasedCommand >> allRows: aCollectionOfDatabaseRows [
	allRows := aCollectionOfDatabaseRows.
]

{ #category : #executing }
RowBasedCommand >> allRowsGrouped: maxSizeInteger evaluate: aBlock [
	"Set me to hold each of the first n * maximum row subgroups in turn, then set me to hold the final maximum-or-less residue of rows.  Do the whileTrue: compare using <, not <=, to ensure I will have some rows remaining for the post-loop run.  At the end, reset me to my start state (if debugging, be aware that we do not do this final reset inside an #ensure: block, instead assuming that any actual rerun will begin sufficiently far up the stack to ensure the command is recomputed;  a safe assumption?)."

	| startPosition endPosition theRows |
	maxSizeInteger < allRows size ifFalse: [^aBlock value].	"no splitting needed"
	theRows := allRows.
	startPosition := 1.
	endPosition := maxSizeInteger.
	[endPosition < theRows size] whileTrue:	"set me to hold the next maxSize rows"
		[allRows := theRows copyFrom: startPosition to: endPosition.
		self row: allRows first.
		aBlock value.
		startPosition := endPosition + 1.
		endPosition := endPosition + maxSizeInteger].
	"Set me to hold the remaining maxSize-or-less rows"
	allRows := theRows copyFrom: startPosition to: theRows size.
	self row: allRows first.
	aBlock value.
	"We're finished;  reset me back to my start state."
	allRows := theRows.
	self row: allRows first.
]

{ #category : #executing }
RowBasedCommand >> allRowsSinglyEvaluate: aBlock [
	"Run each row singly, nilling allRows during the run so no code in aBlock can imagine it should run grouped."

	| theRows |
	theRows := allRows.
	allRows := nil.
	theRows do:
		[:each |
		self row: each.
		aBlock value].
	"We're finished;  reset me back to my start state."
	allRows := theRows.
	self row: allRows first.
]

{ #category : #'bound values' }
RowBasedCommand >> arrayBindings [
	"Return bindings in a form suitable for Oracle array binding, i.e. an array of arrays.  The outer array has one position for each field;  each position holds an array of values of that field, one for each row."

	| allBindings fields |
	fields := self arrayBoundFields.
	allBindings := (1 to: fields size) collect: [:each | Array new: allRows size].
	1 to: allRows size do:
		[:rowNumber || inputRow | inputRow := allRows at: rowNumber.
		1 to: fields size do:
			[:columnNumber |
			(allBindings at: columnNumber)
				at: rowNumber
				put: (inputRow at: (fields at: columnNumber) ifAbsent: [nil])]].
	^allBindings asArray
]

{ #category : #'bound values' }
RowBasedCommand >> arrayBoundFields [
	"Return the list of fields to be bound in the SQL string we will use for array binding. For array binding, we need to include all possible fields, rather than those that just have values in a particular row"
	self subclassResponsibility.
]

{ #category : #'bound values' }
RowBasedCommand >> batchStatementBindings [
	"Return our bindings, which we assume are for multiple rows, as one big array, one statement after the other"

	| bound fields |
	fields := self arrayBoundFields.
	bound := OrderedCollection new: allRows size * fields size.
	allRows do: [:eachRow | 
		fields do: [:each | 
			| fieldValue |
			fieldValue := eachRow at: each ifAbsent: [nil].
			(self canBind: fieldValue to: each type) ifTrue: [bound add: fieldValue]]].
	^bound asArray.
]

{ #category : #'bound values' }
RowBasedCommand >> bindingTypes [
	"It is not functionally necessary to check usesArrayBindingRatherThanGroupWriting since the first part of the longer row is what the bindTemplate needs for a bound array and the rest is just ignored.  We check for (trivial) performance and for code clarity."

	| all basic size |
	^self shouldUseGroupWriting
		ifTrue:
			[basic := self arrayBoundFields collect: [:each | each type].
			self platform usesArrayBindingToGroupWrite
				ifTrue: [basic]
				ifFalse:
					[size := basic size.
					all := Array new: allRows size * size.
					0 to: allRows size - 1 do:
						[:i || index | index := i * size.
						all replaceElementsFrom: index + 1 to: index + size withArray: basic startingAt: 1].
					all]]
		ifFalse: [self singleRowBoundFields collect: [:each | each type]]
]

{ #category : #'bound values' }
RowBasedCommand >> bindings [
	^self shouldUseGroupWriting
		ifTrue: [self platform bindingsForGroupWritingFor: self]
		ifFalse: [self singleRowBindings]
]

{ #category : #executing }
RowBasedCommand >> executeBoundIn: anAccessor [
	self hasMultipleRows
		ifFalse: [self executeBoundInRoundTrip: anAccessor]
		ifTrue: [self shouldUseGroupWriting
				ifFalse: [self allRowsSinglyEvaluate: [self executeBoundInRoundTrip: anAccessor]]
				ifTrue: [self
						allRowsGrouped: self maximumBoundWriteSize
						evaluate: [self executeBoundInRoundTrip: anAccessor]]].
	^anAccessor cursorFor: #() readStream	"insert results aren't interesting so return an empty cursor"
]

{ #category : #executing }
RowBasedCommand >> executeBoundInRoundTrip: anAccessor [
	"Send one or more rows to the database in a single round trip, bound to an array of values.  The array will be  two-dimensional (arrayBindings) or one-dimensional (batchStatementBindings)."

	| result |
	result := anAccessor executeCommandBound: self.
	result release.
	failed := self needsRowCount and: [rowCount ~= self expectedNumberOfModifiedRows].
]

{ #category : #executing }
RowBasedCommand >> executeUnboundIn: anAccessor [
	anAccessor returnRowCount: self needsRowCount.
	self hasMultipleRows
		ifFalse:  [self executeUnboundInRoundTrip: anAccessor]
		ifTrue: [self shouldUseGroupWriting
				ifFalse: [self allRowsSinglyEvaluate: [self executeUnboundInRoundTrip: anAccessor]]
				ifTrue: [self
						allRowsGrouped: self maximumUnboundWriteSize
						evaluate: [self executeUnboundInRoundTrip: anAccessor]]].
	^#() readStream	"Results aren't interesting"
]

{ #category : #executing }
RowBasedCommand >> executeUnboundInRoundTrip: anAccessor [
	"Only an UpdateCommand with lock field(s) can return true to #needsRowCount.  Thus we call answer on the session in the #doing: block only if an UpdateCommand writes multiple optimistically-locked rows batched (must be batched as we are unbound and there is no way to write two or more such rows otherwise except via a bound call with #usesArrayBindingToGroupWrite).  The accessor has already called answer once, for the first row, and obtained the rowCount (one if optimistic locking succeeded, zero if it failed).  The second and subsequent rows will each return #noAnswerStream to successive calls of answer, plus the rowCount which we aggregate.  If the rowCount total is the total number of rows written, optimistic locking succeeded, otherwise we had one or more failures.  The index when any call of answer is followed by a rowCount of zero corresponds to the number in allRows of the row for which optimistic locking failed (i.e. someone had updated the row between this image's reading and writing of it).
	BE AWARE:  the caller has cached the answer stream, which will be #noAnswerStream in the sole case where needsRowCount is true (an update of rows with lock fields), and so we raise an error if we do not exit with the answer stream still being #noAnswerStream, letting the caller continue safely."

	anAccessor
		executeSQLStringNoResult: self sqlString
		doing: [failed := failed or:
				[self needsRowCount and:		"if rowCount unsupported, we cannot tell if it worked, so assume it did but leave rowCount nil"
					[(anAccessor platform supportsRowCountFor: self) and:
						[rowCount := anAccessor rowCount.
						2 to: self expectedNumberOfModifiedRows do:
							[:index |
							anAccessor driverSession answer == #noAnswerStream
								ifFalse: [self error: 'Tell Niall:  platform does not support batched rowCount']
								ifTrue: [rowCount := rowCount + anAccessor rowCount]].
						rowCount ~= self expectedNumberOfModifiedRows]]]]
		forCommand: self.
]

{ #category : #executing }
RowBasedCommand >> expectedNumberOfModifiedRows [
	^allRows isNil
		ifTrue: [1]
		ifFalse: [allRows size]
]

{ #category : #testing }
RowBasedCommand >> hasMultipleRows [
	^allRows notNil and: [allRows size > 1].
]

{ #category : #initializing }
RowBasedCommand >> initialize [
	super initialize.
	failed := false.
]

{ #category : #testing }
RowBasedCommand >> maximumBoundWriteSize [
	"How many bound rows can we send to the DB in a single trip."

	^self system maximumSizeToGroupWriteFor: self
]

{ #category : #testing }
RowBasedCommand >> maximumUnboundWriteSize [
	"How many values can we write at once. This is only really applicable when not doing binding and concatenating many statements together for one trip to the DB"

	^1000 min: (self system maximumSizeToGroupWriteFor: self)
]

{ #category : #accessing }
RowBasedCommand >> parameterTypeSignature [
	"Return a string indicating the parameter types. Complicated by the possibility of multiple rows, and of null values"
	| result |
	result := WriteStream on: String new.
	self hasMultipleRows
		ifTrue:
			[row
				keysAndValuesDo:
					[:eachKey :eachValInFirstRow| 
					| nextValue |
					eachValInFirstRow notNil
						ifTrue: [result nextPutAll: eachValInFirstRow class name]
						ifFalse:
							[allRows
								do:
									[:eachRow | 
									(nextValue := eachRow at: eachKey ifAbsent: [nil]) notNil
										ifTrue: [result nextPutAll: nextValue class name]]]]]
		ifFalse:
			[row
				keysAndValuesDo:
					[:eachKey :eachValue | result nextPutAll: eachValue class name]].
	^result contents.
]

{ #category : #accessing }
RowBasedCommand >> row [
	^row.
]

{ #category : #accessing }
RowBasedCommand >> row: anObject [
	row := anObject.
	sqlString := nil.
]

{ #category : #'bound values' }
RowBasedCommand >> rowAtATimeBindings [
	"Return multiple sets of bindings in a form suitable for iterating over"
	| allBindings fields rowTemplate |
	fields := self arrayBoundFields.
	rowTemplate := Array new: fields size.
	allBindings := Array new: allRows size.
	1 to: allBindings size do: [:i | | currentRow input |
		currentRow := rowTemplate copy.
		input := allRows at: i.
		allBindings at: i put: currentRow.
		1 to: fields size do: [:j |
			currentRow at: j put: (input at: (fields at: j) ifAbsent: [nil])]].
	^allBindings asArray.
]

{ #category : #accessing }
RowBasedCommand >> rowCount [
	^rowCount.
]

{ #category : #accessing }
RowBasedCommand >> rowCount: anInteger [
	rowCount := anInteger.
]

{ #category : #'bound values' }
RowBasedCommand >> singleRowBindings [
	| bound |
	bound := OrderedCollection new.
	self singleRowBoundFields
		do:
			[:each | 
			| fieldValue |
			fieldValue := row at: each ifAbsent: [nil].
			(self canBind: fieldValue to: each type) ifTrue: [bound add: fieldValue]].
	^bound asArray.
]

{ #category : #'bound values' }
RowBasedCommand >> singleRowBoundFields [
	"Return the list of fields to be bound in the SQL string we will use for a single operation. We only need to include those fields that actually have values in the particular row we're operating on"
	self subclassResponsibility.
]

{ #category : #testing }
RowBasedCommand >> succeeded [
	^failed not.
]

{ #category : #testing }
RowBasedCommand >> supportsGroupWriting [
	"Return true if array binding of values to a single statement, or batching of multiple statements, or concatenation of values to a single statement (or other similar mechanism) can be used to execute this command with multiple rows in a single round trip to the database."

	^false
]

{ #category : #testing }
RowBasedCommand >> supportsGroupWritingValues [
	"The version of the INSERT command that can concatenate values onto a command (as one way of group-writing) is only supported by some database platforms in some versions.  Only if the platform supports it will an instance of an InsertCommand subclass that supports it be created."

	^false
]

{ #category : #reporting }
RowBasedCommand >> tables [
	^Array with: self row table.
]
