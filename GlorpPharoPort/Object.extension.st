Extension { #name : #Object }

{ #category : #'*GlorpPharoPort' }
Object >> asNanoseconds [

	^ self asNanoSeconds
]

{ #category : #'*GlorpPharoPort' }
Object >> asTimestamp [

	^ self asDateAndTime
]

{ #category : #'*GlorpPharoPort' }
Object >> glorpCopyIn: aDictionary [
	"For non-storeForGlorp objects, just copy normally"
	^self copy.
]

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

{ #category : #'*GlorpPharoPort' }
Object >> respondsToArithmetic [
	"Answer whether the object responds to the numeric (#+, #-, #*, #/)
	protocol as defined in the class ArithmeticValue"

	^false
]
