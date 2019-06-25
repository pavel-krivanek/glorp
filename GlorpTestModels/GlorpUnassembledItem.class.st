Class {
	#name : #GlorpUnassembledItem,
	#superclass : #GlorpNonperishableItem,
	#instVars : [
		'assemblyCost'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpUnassembledItem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpUnassembledItem >> assemblyCost [
	^assemblyCost
]

{ #category : #accessing }
GlorpUnassembledItem >> assemblyCost: anObject [
	assemblyCost := anObject
]