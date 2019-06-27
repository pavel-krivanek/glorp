Extension { #name : #Exception }

{ #category : #'*GlorpPharoPort' }
Exception class >> raiseErrorString: aString [

	^ self signal: aString
]

{ #category : #'*GlorpPharoPort' }
Exception class >> raiseRequest [

	^ self signal
]
