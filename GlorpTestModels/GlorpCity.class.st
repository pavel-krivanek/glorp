"
City models a table with city name and id. 

Instance Variables:
	id	<Integer> The city's id.
	name	<String>	The city's name.
	nextCities	<Dictionary> A dictionary of other cities that we can directly reach from this city.
	priorCities	<Dictionary>	A dictionary of other cities with a direct link to this city.


"
Class {
	#name : #GlorpCity,
	#superclass : #Object,
	#instVars : [
		'id',
		'name',
		'priorCities',
		'nextCities'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
GlorpCity class >> new [
	^super new initialize
]

{ #category : #'adding-removing' }
GlorpCity >> addNextCity: aGlorpCity distance: anInteger [
	"Create and return a cities graph link object"
	^GlorpCitiesGraph new city: self; nextCity: aGlorpCity; distance: anInteger; yourself
]

{ #category : #accessing }
GlorpCity >> id [
	"	***This is decompiled code.*** 
	No source was available"

	^id
]

{ #category : #accessing }
GlorpCity >> id: t1 [ 
	"	***This is decompiled code.*** 
	No source was available"

	id := t1.
	^self
]

{ #category : #'initialize-release' }
GlorpCity >> initialize [
	nextCities := OrderedCollection new.
	priorCities := OrderedCollection new.
]

{ #category : #accessing }
GlorpCity >> name [
	"	***This is decompiled code.*** 
	No source was available"

	^name
]

{ #category : #accessing }
GlorpCity >> name: t1 [ 
	"	***This is decompiled code.*** 
	No source was available"

	name := t1.
	^self
]

{ #category : #accessing }
GlorpCity >> nextCities [

	^nextCities
]

{ #category : #accessing }
GlorpCity >> nextCities: anObject [

	nextCities := anObject
]

{ #category : #accessing }
GlorpCity >> priorCities [

	^priorCities
]

{ #category : #accessing }
GlorpCity >> priorCities: anObject [

	priorCities := anObject
]
