"
Integer type
"
Class {
	#name : #GlorpIntegerType,
	#superclass : #GlorpAbstractIntegerType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'VisualWorks metadata' }
GlorpIntegerType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #comparing }
GlorpIntegerType >> = aType [
	(aType class == self platform numeric class and: [aType isIntegerType]) ifTrue: [^true].
	^super = aType
]

{ #category : #comparing }
GlorpIntegerType >> hash [
	"Our hash must be identical to GlorpNumericType's hash when it is an #isInteger"
	^self platform hash bitXor: self impliedSmalltalkType hash
]

{ #category : #initialize }
GlorpIntegerType >> initialize [
	super initialize.
	typeString := 'integer'.
]