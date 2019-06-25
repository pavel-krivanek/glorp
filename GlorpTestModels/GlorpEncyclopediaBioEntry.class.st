Class {
	#name : #GlorpEncyclopediaBioEntry,
	#superclass : #Object,
	#instVars : [
		'owner',
		'title',
		'text'
	],
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
GlorpEncyclopediaBioEntry class >> new [
	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
GlorpEncyclopediaBioEntry class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #'initialize-release' }
GlorpEncyclopediaBioEntry >> initialize [
]

{ #category : #accessing }
GlorpEncyclopediaBioEntry >> text [
	^text
]

{ #category : #accessing }
GlorpEncyclopediaBioEntry >> text: anObject [
	text := anObject
]

{ #category : #accessing }
GlorpEncyclopediaBioEntry >> title [
	^title
]

{ #category : #accessing }
GlorpEncyclopediaBioEntry >> title: anObject [
	title := anObject
]