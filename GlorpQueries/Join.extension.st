Extension { #name : #Join }

{ #category : #'*GlorpQueries-api' }
Join >> addSource: aField target: anotherField [ 
	| sourceValue targetValue |
	sourceValue := (self isConstant: aField) 
		ifTrue: [ConstantExpression for: aField]
		ifFalse: [aField].
	sources add: sourceValue.
	targetValue := anotherField class == SimpleQuery
		ifTrue: [anotherField asGlorpExpressionOn: base] 
		ifFalse: [anotherField].
	"isConstant: returns true to a block so we have this very debatable protection;
	should we instead handle it as we do a SimpleQuery above? (to be reviewed)"
	((self isConstant: targetValue) and: [(Dialect isBlock: targetValue) not]) ifTrue:	
		[self error: 'You are attempting to set a constant value as the target of a relationship. I suspect you want to set it on the source instead. Either that or you''re trying to use a field name where a field object is required.'].
	targets add: targetValue.
]
