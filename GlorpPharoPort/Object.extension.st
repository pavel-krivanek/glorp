Extension { #name : #Object }

{ #category : #'*GlorpPharoPort' }
Object >> glorpEndOfIndexedInstVars [
	"Return the index at which indexed instance variables start. The same as basicSize for most dialects, but funny for ObjectStudio"

	^self basicSize.
]

{ #category : #'*GlorpPharoPort' }
Object >> glorpIsBlock [
	^false.
]

{ #category : #'*GlorpPharoPort' }
Object >> glorpStartOfIndexedInstVars [
	"Return the index at which indexed instance variables start. 1 for most dialects, but funny for ObjectStudio"
	^1.
]
