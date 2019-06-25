Class {
	#name : #GlorpNonperishableItem,
	#superclass : #GlorpInventoryItem,
	#instVars : [
		'serialNumber'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpNonperishableItem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpNonperishableItem >> serialNumber [
	^serialNumber
]

{ #category : #accessing }
GlorpNonperishableItem >> serialNumber: anObject [
	serialNumber := anObject
]
