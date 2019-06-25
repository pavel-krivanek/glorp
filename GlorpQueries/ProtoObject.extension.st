Extension { #name : #ProtoObject }

{ #category : #'*GlorpQueries-doesNotUnderstand' }
ProtoObject >> asGlorpExpression [
	^GlorpHelper glorpConstantExpressionClass for: self.
]

{ #category : #'*GlorpQueries-doesNotUnderstand' }
ProtoObject >> asGlorpExpressionOn: anExpression [

	^self asGlorpExpression.
]

{ #category : #'*GlorpQueries-doesNotUnderstand' }
ProtoObject >> asGlorpExpressionOn: anExpression basedOn: aMessageArchiver withUltimateBase: aBaseExpression [

	^self asGlorpExpression.
]

{ #category : #'*GlorpQueries-testing' }
ProtoObject >> isGlorpExpression [
	^false.
]

{ #category : #'*GlorpQueries-doesNotUnderstand' }
ProtoObject >> isGlorpProxy [
	^false.
]

{ #category : #'*GlorpQueries-doesNotUnderstand' }
ProtoObject >> isKindOf: aClass [
	^self class includesBehavior: aClass.
]
