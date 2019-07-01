Extension { #name : #ByteArray }

{ #category : #'*GlorpPharoPort' }
ByteArray >> asStringEncoding: encoding [ 

	^ self decodeWith: (ZnCharacterEncoder newForEncoding: encoding)
]
