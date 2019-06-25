"
Abstract numeric type
"
Class {
	#name : #GlorpAbstractNumericType,
	#superclass : #GlorpDatabaseType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'VisualWorks metadata' }
GlorpAbstractNumericType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #converting }
GlorpAbstractNumericType >> impliedSmalltalkType [
	^Number.
]
