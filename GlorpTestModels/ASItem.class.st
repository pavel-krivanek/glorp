Class {
	#name : #ASItem,
	#superclass : #Object,
	#instVars : [
		'id',
		'name',
		'bonuses'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ASItem class >> new [
	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ASItem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ASItem >> bonuses [

	^bonuses
]

{ #category : #accessing }
ASItem >> bonuses: anObject [

	bonuses := anObject
]

{ #category : #accessing }
ASItem >> id [

	^id
]

{ #category : #accessing }
ASItem >> id: anObject [

	id := anObject
]

{ #category : #'initialize-release' }
ASItem >> initialize [
	bonuses := OrderedCollection new.
]

{ #category : #accessing }
ASItem >> name [

	^name
]

{ #category : #accessing }
ASItem >> name: anObject [

	name := anObject
]
