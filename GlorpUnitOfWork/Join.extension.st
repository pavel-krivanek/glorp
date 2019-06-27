Extension { #name : #Join }

{ #category : #'*GlorpUnitOfWork-preparing' }
Join >> condenseBooleanEquality [
	^self.
]

{ #category : #'*GlorpUnitOfWork-preparing' }
Join >> condenseBooleanEqualityExpressions [
	^self.
]

{ #category : #'*GlorpUnitOfWork-api' }
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

{ #category : #'*GlorpUnitOfWork-preparing' }
Join >> rewriteEquality [
	^self.
]
