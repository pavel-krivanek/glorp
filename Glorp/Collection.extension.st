Extension { #name : #Collection }

{ #category : #'*Glorp-Core' }
Collection >> copyEmpty: aSize [
	^self species new: aSize
]
