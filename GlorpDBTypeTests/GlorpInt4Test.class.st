Class {
	#name : #GlorpInt4Test,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #GlorpDBTypeTests
}

{ #category : #'VisualWorks metadata' }
GlorpInt4Test class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpInt4Test >> defaultDatabaseType [
	^self platform int4
]

{ #category : #tests }
GlorpInt4Test >> testInt4 [
	self helpTestValue: nil.
	self helpTestValue: 3212321.
]