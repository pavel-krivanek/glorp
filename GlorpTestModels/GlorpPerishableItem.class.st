Class {
	#name : #GlorpPerishableItem,
	#superclass : #GlorpInventoryItem,
	#instVars : [
		'age'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpPerishableItem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpPerishableItem >> age [
	^age
]

{ #category : #accessing }
GlorpPerishableItem >> age: anObject [
	age := anObject
]
