Class {
	#name : #GlorpVarchar1Test,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #'GlorpDBTypeTests-GlorpDBTests'
}

{ #category : #'VisualWorks metadata' }
GlorpVarchar1Test class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpVarchar1Test >> defaultDatabaseType [
	^self platform varchar: 1.
]

{ #category : #tests }
GlorpVarchar1Test >> testBooleanToTFString [

	stType := Boolean.
	self helpTestValue: nil.
	self helpTestValue: true.
	self helpTestValue: false.
]
