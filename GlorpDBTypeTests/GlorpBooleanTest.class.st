Class {
	#name : #GlorpBooleanTest,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #'GlorpDBTypeTests-GlorpDBTests'
}

{ #category : #'VisualWorks metadata' }
GlorpBooleanTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpBooleanTest >> defaultDatabaseType [
	^self platform boolean.
]

{ #category : #tests }
GlorpBooleanTest >> testBoolean [
	stType := Boolean.
	self helpTestValue: nil compareWith: [:read :original |
		self platform usesNullForFalse ifTrue: [read = false] ifFalse: [read = nil]].
	self helpTestValue: true.
	self helpTestValue: false.
]
