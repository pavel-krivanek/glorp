Extension { #name : #Object }

{ #category : #'*Glorp-Core' }
Object >> glorpCopyIn: aDictionary [
	"For non-storeForGlorp objects, just copy normally"
	^self copy.
]

{ #category : #'*Glorp-Core' }
Object >> glorpEndOfIndexedInstVars [
	"Return the index at which indexed instance variables start. The same as basicSize for most dialects, but funny for ObjectStudio"

	^self basicSize.
]

{ #category : #'*Glorp-Core' }
Object >> glorpIsBlock [
	^false.
]

{ #category : #'*Glorp-Core' }
Object >> glorpStartOfIndexedInstVars [
	"Return the index at which indexed instance variables start. 1 for most dialects, but funny for ObjectStudio"
	^1.
]
