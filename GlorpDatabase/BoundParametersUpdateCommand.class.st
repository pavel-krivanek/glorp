"
BoundParametersUpdateCommand outputs the returned relative field values to bind variables.  It is only used by Oracle when binding at the moment. For Oracle, this command must be bound, since the RETURN values are only able to be transmitted by Oracle through a bound array. An added curiousity, the EXDI permits us to access the returned array values through the >>bindVariable: method, normally intended for PLSQL queries.
"
Class {
	#name : #BoundParametersUpdateCommand,
	#superclass : #ReturningUpdateCommand,
	#category : #'GlorpDatabase-GlorpCore'
}

{ #category : #'instance creation' }
BoundParametersUpdateCommand class >> forRow: aDatabaseRow useBinding: aBoolean session: aSession [
	"If we are not binding, we cannot return values."

	^aBoolean
		ifTrue: [super forRow: aDatabaseRow useBinding: aBoolean session: aSession]
		ifFalse: [RelativeUpdateCommand
				forRow: aDatabaseRow
				useBinding: aBoolean
				session: aSession]
]

{ #category : #'instance creation' }
BoundParametersUpdateCommand class >> forRows: aCollectionOfDatabaseRows useBinding: aBoolean session: aSession [
	"If we are not binding, we cannot return values."

	^aBoolean
		ifTrue: [super forRows: aCollectionOfDatabaseRows useBinding: aBoolean session: aSession]
		ifFalse: [RelativeUpdateCommand
				forRows: aCollectionOfDatabaseRows
				useBinding: aBoolean
				session: aSession]
]

{ #category : #'VisualWorks metadata' }
BoundParametersUpdateCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'bound values' }
BoundParametersUpdateCommand >> arrayBindings [
	"For Oracle, we get the updated relative field values as final parameters via output buffers.
	Append each returning field's template value here so that they are added to our exdi buffers.
	These buffers are just receptacles for the returned data, so their content merely needs the
	correct type. Their value is ignored by Oracle, and will be overwritten with return content."

	| arrayBindings |
	arrayBindings := super arrayBindings asOrderedCollection.
	1 to: relativeFields size
		do: 
			[:columnNumber |
			| relativeField sampleValue |
			relativeField := relativeFields at: columnNumber.
			sampleValue := row at: relativeField ifAbsent: [nil].
			sampleValue isNil ifTrue: [sampleValue := relativeField type nilOldValueEquivalent].
			arrayBindings addLast: (Array new: (allRows size) withAll: sampleValue)].
	^arrayBindings asArray
]

{ #category : #'bound values' }
BoundParametersUpdateCommand >> bindingTypes [
	"Use my superclass bindTemplate, and then append one more entry for each relative field, for the return values."

	| result |
	result := super bindingTypes.
	self singleRowBoundFields do:
		[:each |
		each type isRelativeType ifTrue: [result add: each type]].
	^result
]

{ #category : #executing }
BoundParametersUpdateCommand >> postWriteAssignReturnValuesUsing: answerStream [
	"Ask the relative type how to assign returned value(s) to the target column(s) of my rows.  As result returns an array of arrays, we need the inner array.  If relative fields and values are not the same size, #with:do: will raise an error."

	| index |
	allRows isNil
		ifTrue:
			[index := self singleRowBindings size - relativeFields size + 1.	"position of first output value"
			relativeFields do:
				[:field || value |
				value := answerStream accessor
					bindReturningVariableAt: index
					forStatement: answerStream statement.
			 	row at: field forcePut: value.
				index := index + 1]]
		ifFalse:
			[index := self arrayBindings size - relativeFields size + 1.	"position of first output array"
			relativeFields do:
				[:field || valueArray |
				valueArray := answerStream accessor
					bindReturningVariableAt: index
					forStatement: answerStream statement.
		"IF allRows size = 1, row == allRows first AND SO we could use the branch above;  can we nil allRows beforehand?"
				(allRows size = 1 and: [valueArray glorpIsCollection not]) ifTrue:	"With just one row (after grouping), not an array."
					[valueArray := Array with: valueArray].
			 	allRows with: valueArray do:
					[:eachRow :eachValue| eachRow at: field forcePut: eachValue].
				index := index + 1]].
]

{ #category : #'bound values' }
BoundParametersUpdateCommand >> singleRowBindings [
	"For Oracle, we get the updated relative field values as final parameters via output buffers.
	Append each returning field's template value here so that they are added to our exdi buffers.
	These buffers are just receptacles for the returned data, so their content merely needs the
	correct type. Their value is ignored by Oracle, and will be overwritten with return content."

	| rowBindings |
	rowBindings := super singleRowBindings asOrderedCollection.
	1 to: relativeFields size
		do: 
			[:columnNumber |
			| relativeField sampleValue |
			relativeField := relativeFields at: columnNumber.
			sampleValue := row at: relativeField ifAbsent: [nil].
			sampleValue isNil ifTrue: [sampleValue := relativeField type nilOldValueEquivalent].
			rowBindings addLast: sampleValue].
	^rowBindings asArray
]
