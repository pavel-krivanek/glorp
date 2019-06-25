"
An abstract superclass providing convenience methods for domain objects to facilitate testing.
"
Class {
	#name : #GlorpTestModelClass,
	#superclass : #TestAsserter,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpTestModelClass class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'XProgramming.SUnit'
	)

]
