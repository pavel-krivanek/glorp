Class {
	#name : #GlorpReadingDifferentCollectionsThroughMappingsWithClassModelsTest,
	#superclass : #GlorpReadingDifferentCollectionsThroughMappingsTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpReadingDifferentCollectionsThroughMappingsWithClassModelsTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #setup }
GlorpReadingDifferentCollectionsThroughMappingsWithClassModelsTest >> descriptorClass [
	^GlorpCollectionTypesWithClassModelsDescriptorSystem.
]
