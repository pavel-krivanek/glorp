Extension { #name : #ElementBuilder }

{ #category : #'*GlorpDatabase' }
ElementBuilder >> valueOf: anExpression [
	^expression valueInBuilder: self
]

{ #category : #'*GlorpDatabase' }
ElementBuilder >> valueOfField: aField [
	"aField is either a database field, or a constant expression containing a non-varying value that isn't derived from the row"
	(aField class == ConstantExpression) ifTrue: [^aField value].
	^self row at: (self translateFieldPosition: aField)
]

{ #category : #'*GlorpDatabase' }
ElementBuilder >> valueOfField: aField in: aRow [
	"Since the elementBuilder now holds the row, #valueOfField: is preferred protocol, but some things (e.g. ad hoc mapping blocks) might still be using this, so left for compatibility"
	(aField class == ConstantExpression) ifTrue: [^aField value].
	^aRow at: (self translateFieldPosition: aField)
]
