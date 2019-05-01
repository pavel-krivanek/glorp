Class {
	#name : #GlorpPerishableItem,
	#superclass : #GlorpInventoryItem,
	#instVars : [
		'age'
	],
	#category : #GlorpTestModels
}

{ #category : #accessing }
GlorpPerishableItem >> age [
	^age
]

{ #category : #accessing }
GlorpPerishableItem >> age: anObject [
	age := anObject
]
