Class {
	#name : #GlorpUser,
	#superclass : #Object,
	#instVars : [
		'id',
		'name',
		'folders'
	],
	#category : #'GlorpTestModels-Glorp TestModels'
}

{ #category : #'instance creation' }
GlorpUser class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
GlorpUser class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpUser >> folders [
	^folders
]

{ #category : #accessing }
GlorpUser >> folders: aCollection [
	folders := aCollection
]

{ #category : #accessing }
GlorpUser >> id [
	^id
]

{ #category : #accessing }
GlorpUser >> id: anInteger [
	id := anInteger
]

{ #category : #'initialize-release' }
GlorpUser >> initialize [

	id := nil.
	folders := OrderedCollection new.
]

{ #category : #accessing }
GlorpUser >> name [
	^name.
]

{ #category : #accessing }
GlorpUser >> name: aString [
	name := aString.
]
