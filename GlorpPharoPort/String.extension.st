Extension { #name : #String }

{ #category : #'*GlorpPharoPort' }
String >> isByteIndexed [
	"Answer whether the receiver is represented as bytes, and if so, whether a 
	byte in the receiver always maps on a one-to-one basis with a Character"

	^false
]
