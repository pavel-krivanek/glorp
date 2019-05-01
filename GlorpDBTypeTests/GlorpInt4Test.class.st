Class {
	#name : #GlorpInt4Test,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #GlorpDBTypeTests
}

{ #category : #types }
GlorpInt4Test >> defaultDatabaseType [
	^self platform int4
]

{ #category : #tests }
GlorpInt4Test >> testInt4 [
	self helpTestValue: nil.
	self helpTestValue: 3212321.
]
