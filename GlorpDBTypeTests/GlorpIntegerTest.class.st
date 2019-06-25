Class {
	#name : #GlorpIntegerTest,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #GlorpDBTypeTests
}

{ #category : #'VisualWorks metadata' }
GlorpIntegerTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpIntegerTest >> defaultDatabaseType [
	^self platform integer.
]

{ #category : #tests }
GlorpIntegerTest >> testInteger [
	type := (self platform) integer.
	self helpTestValue: nil.
	self helpTestValue: 3212321.
]
