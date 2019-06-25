Class {
	#name : #GlorpCoreExtensionsTest,
	#superclass : #GlorpTestCase,
	#category : #'GlorpTests-GlorpTest'
}

{ #category : #'VisualWorks metadata' }
GlorpCoreExtensionsTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #tests }
GlorpCoreExtensionsTest >> testGlorpIsCollection [
	self deny: Object new glorpIsCollection.
	self assert: Collection new glorpIsCollection
]
