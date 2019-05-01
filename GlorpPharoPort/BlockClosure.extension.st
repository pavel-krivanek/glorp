Extension { #name : #BlockClosure }

{ #category : #'*GlorpPharoPort' }
BlockClosure >> asGlorpExpression [

	^self asGlorpExpressionOn: BaseExpression new.
]

{ #category : #'*GlorpPharoPort' }
BlockClosure >> asGlorpExpressionForDescriptor: aDescriptor [

	| base |
	base := BaseExpression new.
	base descriptor: aDescriptor.
	^self asGlorpExpressionOn: base.
]

{ #category : #'*GlorpPharoPort' }
BlockClosure >> asGlorpExpressionOn: anExpression [ 
	^(self value: MessageArchiver new) asGlorpExpressionOn: anExpression
]

{ #category : #'*GlorpPharoPort' }
BlockClosure >> asGlorpExpressionOn: anExpression in: aQuery [ 
	^(self value: (MessageArchiver new privateGlorpQuery: aQuery)) asGlorpExpressionOn: anExpression.
]

{ #category : #'*GlorpPharoPort' }
BlockClosure >> asGlorpExpressionOn: anExpression withUltimateBase: aBaseExpression [
	"Build the expression, knowing that some parts of it may refer to an outer context based on aBaseExpression. This is primarily useful for subselect blocks"
	| archiver tree |
	archiver := MessageArchiver new.
	tree := self value: archiver.
	^tree asGlorpExpressionOn: anExpression basedOn: archiver withUltimateBase: aBaseExpression.
]

{ #category : #'*GlorpPharoPort' }
BlockClosure >> glorpIsBlock [
	^true.
]
