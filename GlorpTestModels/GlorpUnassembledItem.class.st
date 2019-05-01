Class {
	#name : #GlorpUnassembledItem,
	#superclass : #GlorpNonperishableItem,
	#instVars : [
		'assemblyCost'
	],
	#category : #GlorpTestModels
}

{ #category : #accessing }
GlorpUnassembledItem >> assemblyCost [
	^assemblyCost
]

{ #category : #accessing }
GlorpUnassembledItem >> assemblyCost: anObject [
	assemblyCost := anObject
]
