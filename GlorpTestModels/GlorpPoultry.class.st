Class {
	#name : #GlorpPoultry,
	#superclass : #GlorpPerishableItem,
	#instVars : [
		'featherColor'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpPoultry class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpPoultry >> featherColor [
	^featherColor
]

{ #category : #accessing }
GlorpPoultry >> featherColor: anObject [
	featherColor := anObject
]
