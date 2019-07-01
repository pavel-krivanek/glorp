Extension { #name : #DateAndTime }

{ #category : #'*GlorpPharoPort' }
DateAndTime >> addSeconds: aNumber [

	^ self + aNumber seconds
]

{ #category : #'*GlorpPharoPort' }
DateAndTime >> asMilliseconds [
	"Answer the number of milliseconds since midnight"

	^ self asSeconds * 1000 + self milliseconds

]

{ #category : #'*GlorpPharoPort' }
DateAndTime >> milliseconds [
	"Added for GLORP compatibility"

	^(nanos / 1000000.0) truncated
]

{ #category : #'*GlorpPharoPort' }
DateAndTime >> subtractSeconds: aNumber [

	^ self - aNumber seconds
]
