Extension { #name : #Collection }

{ #category : #'*GlorpPharoPort' }
Collection >> copyEmpty: aSize [
	^self species new: aSize
]
