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
