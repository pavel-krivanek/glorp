"
This isn't really an expression, in that it can never occur due to parsing. It's a way of grouping several expressions together so that we can process them together, essentially making sure that the iteration methods will loop over all the expressions, but only do each node once, even if it occurs in multiple expressions.  This is used in processing order expressions to figure out what tables and join expressions we need.

Because it is only used in transient ways, it probably doesn't implement all the required operations for normal expression usage.

"
Class {
	#name : #ExpressionGroup,
	#superclass : #GlorpExpression,
	#instVars : [
		'children'
	],
	#category : #'GlorpExpressions-Glorp-Expressions'
}

{ #category : #'VisualWorks metadata' }
ExpressionGroup class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'instance creation' }
ExpressionGroup class >> with: anExpression [
	^self new add: anExpression.
]

{ #category : #accessing }
ExpressionGroup >> add: anExpression [
	anExpression isNil ifTrue: [^self].
	children add: anExpression.
]

{ #category : #accessing }
ExpressionGroup >> addAll: anExpressionCollection [
	"Unlike other addAll:, this returns self, not its parameter, and callers use this.  (Rename it, to avoid confusion with the base parameter-returning addAll: in code-checking tools.)"

	anExpressionCollection isNil ifTrue: [^self].
	children addAll: anExpressionCollection.
]

{ #category : #converting }
ExpressionGroup >> asExpressionGroup [
	^self
]

{ #category : #converting }
ExpressionGroup >> asMultipleExpressionRelationOf: aRelationExpression [
	"We are the base (left child) of aRelationExpression whose relation is one of = , <> or IN.  (We were probably constructed explicitly using #getMappings: for lack of a descriptor whose primaryKeys matched our requirements.)  If we have two or more children and our platform does not allow composites for our relation, or our right-hand side is not a subselect, then we must be rewritten as a conjuction of AND:s or OR:s.  The expression intentionally begins unset, i.e. as nil, since we can AND: and OR: to nil parameter."

	| expression orderedRetrievals tracing |
	self size < 2 ifTrue: [^aRelationExpression].
	(aRelationExpression rightChild class == GeneralSubSelectExpression ifTrue:
		[self queryLevelBaseExpression system platform supportsCompositeKeyArgsForOperand: aRelationExpression relation])
			ifTrue: [^aRelationExpression]
			ifFalse:
				[tracing := aRelationExpression rightChild query tracing.
				orderedRetrievals := tracing allTracings select:
					[:each | tracing retrievalExpressions includes: each]].
	1 to: children size do:
		[:index || leftChild rightChild clause |
		leftChild := children at: index.
		rightChild := aRelationExpression rightChild.
		rightChild class == GeneralSubSelectExpression ifTrue:
			[rightChild := rightChild shallowCopy query: rightChild query cloneWithinQuery; yourself.
			rightChild query retrieve: (orderedRetrievals at: index)].
		clause := aRelationExpression shallowCopy leftChild: leftChild; rightChild: rightChild.
		expression := aRelationExpression relation = #<> ifTrue: [clause OR: expression] ifFalse: [clause AND: expression]].
	^expression
]

{ #category : #accessing }
ExpressionGroup >> canHaveBase [
	^self children anySatisfy: [:each | each canHaveBase]
]

{ #category : #accessing }
ExpressionGroup >> children [
	^children.
]

{ #category : #iterating }
ExpressionGroup >> do: aBlock skipping: aSet [
	"Iterate over the expression tree. Keep track of who has already been visited, so we don't get trapped in cycles or visit nodes twice."

	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	children do: [:each | each do: aBlock skipping: aSet].
	aBlock value: self.
]

{ #category : #api }
ExpressionGroup >> get: aSymbol withArguments: anArray [
	"This is a direct clone of the code in ObjectExpression which is what MappingExpression inherits (If the ExpressionGroup has a single child, it would usually be a mapping expression), minus behaviours we suspect are not relevant to functiona groups and/or should be pushed within them to relevant members of the group."

	| functionExpression |
	functionExpression := self getFunction: aSymbol withArguments: anArray.
	functionExpression isNil ifFalse: [^functionExpression].
	"specialExpression := self performSpecialExpression: aSymbol withArguments: anArray.
	specialExpression isNil ifFalse: [^specialExpression].
	anArray isEmpty ifTrue: [^self get: aSymbol]."
	^RelationExpression
		named: aSymbol
		basedOn: self
		withArguments: anArray
]

{ #category : #initialize }
ExpressionGroup >> initialize [
	super initialize.
	children := OrderedCollection new.
]

{ #category : #accessing }
ExpressionGroup >> isEmpty [
	^self size = 0.
]

{ #category : #mapping }
ExpressionGroup >> mappedFields [
	^self children
		inject: OrderedCollection new
		into: [:all :each | all addAll: each mappedFields. all]
]

{ #category : #printing }
ExpressionGroup >> printOnlySelfOn: aStream [
	"If #displayString is sent to an expression, it calls #printOnlySelfOn: and it is sent e.g. by the LHS pane of an IdentitySet inspector in VW.  Whether there is any other need for this class to have this method I do not know."

	aStream
		nextPutAll: children size printString;
		nextPutAll: ' expressions'.
]

{ #category : #'printing SQL' }
ExpressionGroup >> printSQLOn: aStream withParameters: anArray [
	aStream nextPutAll: '('.
	GlorpHelper 
		do: [:expr | expr printSQLOn: aStream withParameters: anArray]
		for: self children
		separatedBy: [aStream nextPutAll: ', '].
	aStream nextPutAll: ')'.
]

{ #category : #printing }
ExpressionGroup >> printTreeOn: aStream [

	children do: [:each |
		aStream nextPut: $(.
		each printOn: aStream.
		aStream nextPut: $).
		aStream cr].
]

{ #category : #navigating }
ExpressionGroup >> queryLevelBaseExpression [
	^(self children
		detect: [:each | each canHaveBase]
		ifNone: [^nil]) queryLevelBaseExpression
]

{ #category : #accessing }
ExpressionGroup >> size [
	^children size.
]

{ #category : #navigating }
ExpressionGroup >> ultimateBaseExpression [
	^(self children
		detect: [:each | each canHaveBase]
		ifNone: [^nil]) ultimateBaseExpression
]
