Class {
	#name : #GlorpNonperishableItem,
	#superclass : #GlorpInventoryItem,
	#instVars : [
		'serialNumber'
	],
	#category : #GlorpTestModels
}

{ #category : #accessing }
GlorpNonperishableItem >> serialNumber [
	^serialNumber
]

{ #category : #accessing }
GlorpNonperishableItem >> serialNumber: anObject [
	serialNumber := anObject
]
