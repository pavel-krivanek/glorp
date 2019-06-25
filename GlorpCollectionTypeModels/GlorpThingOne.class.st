"
This just exists to be put in collections.

Instance Variables:
	id	<SmallInteger>	description of id
	name	<String>	description of name


"
Class {
	#name : #GlorpThingOne,
	#superclass : #Object,
	#instVars : [
		'id',
		'name'
	],
	#category : #GlorpCollectionTypeModels
}

{ #category : #'instance creation' }
GlorpThingOne class >> named: aString [
	^self new name: aString.
]

{ #category : #'VisualWorks metadata' }
GlorpThingOne class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #comparing }
GlorpThingOne >> <= aThingOne [
	^self name <= aThingOne name.
]

{ #category : #accessing }
GlorpThingOne >> id [
	^id
]

{ #category : #accessing }
GlorpThingOne >> id: anInteger [
	id := anInteger
]

{ #category : #accessing }
GlorpThingOne >> name [
	^name
]

{ #category : #accessing }
GlorpThingOne >> name: aString [
	name := aString
]
