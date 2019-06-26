"
Represents the author of an encyclopedia entry. Used to exercise object->object dictionary mappings.


"
Class {
	#name : #GlorpEncyclopediaAuthor,
	#superclass : #Object,
	#instVars : [
		'id',
		'name'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpEncyclopediaAuthor class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpEncyclopediaAuthor >> <= aGlorpEncyclopediaAuthor [
	^self name <= aGlorpEncyclopediaAuthor name.
]

{ #category : #accessing }
GlorpEncyclopediaAuthor >> id [
	^id
]

{ #category : #accessing }
GlorpEncyclopediaAuthor >> id: anObject [
	id := anObject
]

{ #category : #accessing }
GlorpEncyclopediaAuthor >> name [
	^name
]

{ #category : #accessing }
GlorpEncyclopediaAuthor >> name: aString [
	name := aString
]

{ #category : #printing }
GlorpEncyclopediaAuthor >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: (self name isNil ifTrue: ['nil'] ifFalse: [self name]).
	aStream nextPut: $).
]
