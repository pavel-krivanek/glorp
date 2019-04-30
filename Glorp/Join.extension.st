Extension { #name : #Join }

{ #category : #'*Glorp' }
Join >> addSource: aField target: anotherField [ 
	| value targetValue |
	value := (self isConstant: aField) 
				ifTrue: [ConstantExpression for: aField]
				ifFalse: [aField].
	sources add: value.
	targetValue := anotherField class == SimpleQuery
		ifTrue: [anotherField asGlorpExpressionOn: base] 
		ifFalse: [anotherField].
	((self isConstant: targetValue) and: [(Dialect isBlock: targetValue) not]) ifTrue:
		[self error: 'You are attempting to set a constant value as the target of a relationship. I suspect you want to set it on the source instead. Either that or you''re trying to use a field name where a field object is required.'].
	targets add: targetValue.
]

{ #category : #'*Glorp' }
Join >> condenseBooleanEquality [
	^self.
]

{ #category : #'*Glorp' }
Join >> condenseBooleanEqualityExpressions [
	^self.
]

{ #category : #'*Glorp' }
Join >> mapFromSource: sourceObject andTarget: targetObject intoRowsIn: aRowMap [
	(sourceObject isNil or: [targetObject isNil]) ifTrue: [^self].
	1
		to: sources size
		do:
			[:i | 
			| eachSourceField eachTargetField |
			eachSourceField := sources at: i.
			eachTargetField := targets at: i.
			(self isConstant: eachSourceField)
				ifTrue: [aRowMap at: eachTargetField key: targetObject put: eachSourceField value]
				ifFalse:
					[aRowMap
						unifyField: eachSourceField
						key: sourceObject
						withField: eachTargetField
						key: targetObject]].
]

{ #category : #'*Glorp' }
Join >> rewriteEquality [
	^self.
]
