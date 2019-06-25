Class {
	#name : #GlorpInt8Test,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #GlorpDBTypeTests
}

{ #category : #'VisualWorks metadata' }
GlorpInt8Test class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpInt8Test >> defaultDatabaseType [
	^self platform int8
]

{ #category : #tests }
GlorpInt8Test >> testInt8 [
	type := (self platform) int8.
	self helpTestValue: nil.
	self helpTestValue: 3212321555.
]