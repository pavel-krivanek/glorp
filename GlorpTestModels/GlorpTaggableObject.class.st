Class {
	#name : #GlorpTaggableObject,
	#superclass : #Object,
	#instVars : [
		'tags'
	],
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
GlorpTaggableObject class >> new [
	^super new initialize.
]

{ #category : #'as yet unclassified' }
GlorpTaggableObject >> initialize [
	tags := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
GlorpTaggableObject >> tags [
	^ tags
]

{ #category : #'as yet unclassified' }
GlorpTaggableObject >> tags: someTags [
	tags := someTags
]
