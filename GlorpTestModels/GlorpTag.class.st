Class {
	#name : #GlorpTag,
	#superclass : #Object,
	#instVars : [
		'id',
		'key',
		'label'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpTag class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #'as yet unclassified' }
GlorpTag >> generateKeyFromLabel [
	key := label asLowercase
]

{ #category : #'as yet unclassified' }
GlorpTag >> key [
	^ key
]

{ #category : #'as yet unclassified' }
GlorpTag >> key: aKey [
	key := aKey
]

{ #category : #'as yet unclassified' }
GlorpTag >> label [
	^ label
]

{ #category : #'as yet unclassified' }
GlorpTag >> label: aLabel [
	label := aLabel
]
