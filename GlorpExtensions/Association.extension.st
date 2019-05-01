Extension { #name : #Association }

{ #category : #'*GlorpExtensions' }
Association >> glorpAtIdentity: aKey ifAbsent: aBlock [
	"A cheat to let use use this like an identity dictionary"
	^key == aKey ifTrue: [value] ifFalse: aBlock.
]

{ #category : #'*GlorpExtensions' }
Association >> keysAndValuesDo: aBlock [
	"A memory allocation hack. Let us use a single association in place of a dictionary"
	aBlock value: key value: value.
]
