Class {
	#name : #GlorpSurcharge,
	#superclass : #GlorpTax,
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
GlorpSurcharge class >> glorpSetupDescriptor: aDescriptor forSystem: aSystem [
	| table |
	table := aSystem tableNamed: 'TAX'.
	self glorpCommonSetupDescriptor: aDescriptor forSystem: aSystem.
	(aSystem typeResolverFor: GlorpTax)
		register: aDescriptor
		keyedBy: 'S'
		field: (table fieldNamed: 'TYPE').
]

{ #category : #'VisualWorks metadata' }
GlorpSurcharge class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
