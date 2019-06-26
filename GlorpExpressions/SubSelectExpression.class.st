"
This is a special sort of relation expression used when printing subselects that are generated out of anySatisfy: or noneSatisfy: using an EXISTS/NOT EXISTS clause.

Instance Variables:
	localBase	<SubSelectBaseExpression>	The base expression that our sub-query is built on, as opposed to the overall base expression of query.
	query	<SimpleQuery>	The sub-query we are responsible for.


"
Class {
	#name : #SubSelectExpression,
	#superclass : #RelationExpression,
	#instVars : [
		'query',
		'localBase'
	],
	#category : #GlorpExpressions
}

{ #category : #'VisualWorks metadata' }
SubSelectExpression class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #preparing }
SubSelectExpression >> addBoundExpressionsIn: aCommand [
	self query prepare.
	self query addBoundExpressionsIn: aCommand.
]

{ #category : #accessing }
SubSelectExpression >> descriptor [
	^self leftChild descriptor.
]

{ #category : #internal }
SubSelectExpression >> named: aSymbol basedOn: anExpression withArguments: anArray [

	| right |
	outerJoin := false.
	relation := self operationFor: aSymbol.
	leftChild := anExpression base.

	localBase := SubSelectBaseExpression on: anExpression.
	right := anArray first.
	rightChild := right rebuildOn: localBase startingFrom: anExpression.
]

{ #category : #'printing SQL' }
SubSelectExpression >> printSQLOn: aStream withParameters: aDictionary [ 
	| command toPrint |
	toPrint := relation = #noneSatisfy: ifTrue: ['NOT EXISTS ('] ifFalse: [' EXISTS ('].
	aStream nextPutAll: toPrint.
	command := self query sqlWith: aDictionary.
	command boundExpressions: aStream boundExpressions.
	aStream nextPutAll: command sqlString.
	aStream nextPutAll: ')'.
]

{ #category : #accessing }
SubSelectExpression >> query [
	query isNil ifTrue: [self initializeQuery].
	^query.
]

{ #category : #preparing }
SubSelectExpression >> rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression [
	| expression left |
	self == anExpression ifTrue: [^aBaseExpression].
	"We've swallowed our left child, so we have to unswallow it before rebuilding"
	left := localBase trueBase rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression.
	expression := left 
		get: relation
		withArguments:
			(Array
				with:
					(self rightChildToRebuild rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression)).
	self isOuterJoin ifTrue: [expression beOuterJoin].
	^expression.
]
