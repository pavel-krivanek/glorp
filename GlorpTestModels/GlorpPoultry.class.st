Class {
	#name : #GlorpPoultry,
	#superclass : #GlorpPerishableItem,
	#instVars : [
		'featherColor'
	],
	#category : #GlorpTestModels
}

{ #category : #accessing }
GlorpPoultry >> featherColor [
	^featherColor
]

{ #category : #accessing }
GlorpPoultry >> featherColor: anObject [
	featherColor := anObject
]
