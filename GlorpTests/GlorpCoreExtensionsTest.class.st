Class {
	#name : #GlorpCoreExtensionsTest,
	#superclass : #GlorpTestCase,
	#category : #GlorpTests
}

{ #category : #tests }
GlorpCoreExtensionsTest >> testGlorpIsCollection [
	self deny: Object new glorpIsCollection.
	self assert: Collection new glorpIsCollection
]
