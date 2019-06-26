Class {
	#name : #GlorpDescriptorSystemWithNamespaces,
	#superclass : #GlorpTestDescriptorSystem,
	#category : #'GlorpTestModels-GlorpTest'
}

{ #category : #'VisualWorks metadata' }
GlorpDescriptorSystemWithNamespaces class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpDescriptorSystemWithNamespaces >> allTableNames [
	^#()
]

{ #category : #accessing }
GlorpDescriptorSystemWithNamespaces >> constructAllClasses [
	^(super constructAllClasses)
		add: GlorpTestClassInNamespace;
		yourself
]

{ #category : #accessing }
GlorpDescriptorSystemWithNamespaces >> descriptorForGlorpTestClassInNamespace: aDescriptor [ 
	^aDescriptor
]
