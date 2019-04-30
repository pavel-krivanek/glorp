"
A command to insert our set of rows.
"
Class {
	#name : #InsertCommand,
	#superclass : #RowBasedCommand,
	#category : 'Glorp-Database'
}

{ #category : #accessing }
InsertCommand >> arrayBoundFields [
	"For array binding, include all the fields, except if we're inserting into a database with identity columns, where we must omit those columns"
	^self platform usesIdentityColumns
		ifTrue: [row table fields reject: [:each | each type isIdentityColumn]]
		ifFalse: [row table fields].
]

{ #category : #accessing }
InsertCommand >> basicPrintSQLFor: aRow [
	| fields |
	self nextPutAll: 'INSERT INTO '.
	aRow table printSQLOn: self withParameters: #().
	fields := self shouldUseGroupWriting
		ifTrue: [self arrayBoundFields]
		ifFalse: [aRow nonGeneratedFieldsWithValues].
	self nextPutAll: ' ('.
	GlorpHelper
		do: [:each | self nextPutAll: (self platform nameForColumn: each name)]
		for: fields
		separatedBy: [self nextPutAll: ','].
	self nextPutAll: ') '.
	self nextPutAll: ' VALUES ('.
	GlorpHelper
		do:
			[:each | 
			(self canBind: (aRow at: each ifAbsent: [nil]) to: each type)
				ifTrue: [self nextPut: $?]
				ifFalse: [aRow printValueOfField: each on: self]]
		for: fields
		separatedBy: [self nextPutAll: ','].
	self nextPutAll: ')'.
]

{ #category : #'bound values' }
InsertCommand >> bindingTypes [
	| all basic size |
	^(self shouldUseGroupWriting)
		ifTrue: [
			basic := self arrayBoundFields collect: [:each | each type].
			size := basic size.
			all := Array new: (allRows size * size).
			0 to: allRows size - 1 do: [:i |
				| index |
				index := i * size.
				all replaceElementsFrom: index + 1 to: index + size withArray: basic startingAt: 1].
			all]
		ifFalse: [self singleRowBoundFields collect: [:each | each type]].
]

{ #category : #executing }
InsertCommand >> executeBoundInRoundTrip: anAccessor [
	"An inserted row may have a column whose value is set by the server;  get it."

	super executeBoundInRoundTrip: anAccessor.
	self postWriteAssignSequencesUsing: anAccessor.
]

{ #category : #executing }
InsertCommand >> executeUnboundInRoundTrip: anAccessor [
	"An inserted row may have a column whose value is set by the server;  get it."

	super executeUnboundInRoundTrip: anAccessor.
	self postWriteAssignSequencesUsing: anAccessor.
]

{ #category : #executing }
InsertCommand >> postWriteAssignSequencesUsing: anAccessor [
	"The default insert command does not check whether it has an identity column (a column whose value is set by the server) and cannot recover the set value in the same round trip.  Instead we iterate over the row's fields and make a follow-up query if needed to get the value.  The default approach gets the value in a follow-up query and so uses the Accessor."

	row postWriteAssignSequencesUsing: anAccessor.
]

{ #category : #executing }
InsertCommand >> printSQL [
	self printSQLForFirstRow: row.
	self hasMultipleRows ifFalse: [^self].
	(self useBinding and: [self platform usesArrayBindingToGroupWrite]) ifTrue: [^self].
	2 to: self allRows size do:
		[:i | self printSQLForNextRow: (allRows at: i)].
]

{ #category : #executing }
InsertCommand >> printSQLForFirstRow: aRow [
	| fields |
	self nextPutAll: 'INSERT INTO '.
	aRow table printSQLOn: self withParameters: #().
	fields := self shouldUseGroupWriting
		ifTrue: [self arrayBoundFields]
		ifFalse: [aRow nonGeneratedFieldsWithValues].
	self space; nextPut: $(.
	GlorpHelper
		do: [:each | self nextPutAll: (self platform nameForColumn: each name)]
		for: fields
		separatedBy: [self nextPut: $,].
	self nextPut: $).
	self nextPutAll: '  VALUES ('.
	GlorpHelper
		do: [:each | (self canBind: (aRow at: each ifAbsent: [nil]) to: each type)
					ifTrue: [self nextPutBindMarkerIn: nil]
					ifFalse: [aRow printValueOfField: each on: self]]
		for: fields
		separatedBy: [self nextPut: $,].
	self nextPut: $).
]

{ #category : #executing }
InsertCommand >> printSQLForNextRow: aRow [
	self nextPut: $;.
	self space.
	self printSQLForFirstRow: aRow.
]

{ #category : #accessing }
InsertCommand >> singleRowBoundFields [
	"Include only the fields that have values in our particular row"
	^row nonGeneratedFieldsWithValues
]

{ #category : #testing }
InsertCommand >> supportsGroupWriting [
	^true
]
