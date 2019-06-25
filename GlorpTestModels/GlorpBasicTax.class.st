Class {
	#name : #GlorpBasicTax,
	#superclass : #GlorpTax,
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
GlorpBasicTax class >> glorpSetupDescriptor: aDescriptor forSystem: aSystem [
	| table |
	table := aSystem tableNamed: 'TAX'.
	self glorpCommonSetupDescriptor: aDescriptor forSystem: aSystem.
	(aSystem typeResolverFor: GlorpTax)
		register: aDescriptor
		keyedBy: 'T'
		field: (table fieldNamed: 'TYPE').
]

{ #category : #'VisualWorks metadata' }
GlorpBasicTax class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
