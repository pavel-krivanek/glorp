Extension { #name : #DateAndTime }

{ #category : #'*GlorpExtensions' }
DateAndTime >> asMilliseconds [
	"Answer the number of milliseconds since midnight"

	^ self asSeconds * 1000 + self milliseconds

]

{ #category : #'*GlorpExtensions' }
DateAndTime >> milliseconds [
	"Added for GLORP compatibility"

	^(nanos / 1000000.0) truncated
]
