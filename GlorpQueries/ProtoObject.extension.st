Extension { #name : #ProtoObject }

{ #category : #'*GlorpQueries' }
ProtoObject >> asGlorpExpression [
	^GlorpHelper glorpConstantExpressionClass for: self.
]

{ #category : #'*GlorpQueries' }
ProtoObject >> asGlorpExpressionOn: anExpression [

	^self asGlorpExpression.
]

{ #category : #'*GlorpQueries' }
ProtoObject >> asGlorpExpressionOn: anExpression basedOn: aMessageArchiver withUltimateBase: aBaseExpression [

	^self asGlorpExpression.
]

{ #category : #'*GlorpQueries' }
ProtoObject >> isGlorpExpression [
	^false.
]

{ #category : #'*GlorpQueries' }
ProtoObject >> isGlorpProxy [
	^false.
]

{ #category : #'*GlorpQueries' }
ProtoObject >> isKindOf: aClass [
	^self class includesBehavior: aClass.
]
