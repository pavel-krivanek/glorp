Extension { #name : #Collection }

{ #category : #'*GlorpPharoPort' }
Collection >> any [

	^ self anyOne 
]

{ #category : #'*GlorpPharoPort' }
Collection >> copyEmpty: aSize [
	^self species new: aSize
]
