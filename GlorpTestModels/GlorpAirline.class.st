Class {
	#name : #GlorpAirline,
	#superclass : #Object,
	#instVars : [
		'id',
		'name'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #examples }
GlorpAirline class >> example1 [
	^self new
		id: 73;
		name: 'Air Canada'.
]

{ #category : #examples }
GlorpAirline class >> example2 [
	^self new
		id: 74;
		name: 'Lufthansa'.
]

{ #category : #'VisualWorks metadata' }
GlorpAirline class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpAirline >> id [
	^id
]

{ #category : #accessing }
GlorpAirline >> id: anInteger [
	id := anInteger
]

{ #category : #accessing }
GlorpAirline >> name [
	^name
]

{ #category : #accessing }
GlorpAirline >> name: aString [
	name := aString
]
