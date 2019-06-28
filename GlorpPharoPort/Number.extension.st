Extension { #name : #Number }

{ #category : #'*GlorpPharoPort' }
Number >> d [

	^ self
]

{ #category : #'*GlorpPharoPort' }
Number >> respondsToArithmetic [
	"Answer whether the object responds to the numeric (#+, #-, #*, #/)
	protocol as defined in the class ArithmeticValue"

	^true
]
