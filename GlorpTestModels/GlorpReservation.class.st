Class {
	#name : #GlorpReservation,
	#superclass : #Object,
	#instVars : [
		'id',
		'passenger',
		'passengers'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #examples }
GlorpReservation class >> example1 [

	^self new
		id: 2;
		passenger: GlorpPassenger example1.
]

{ #category : #examples }
GlorpReservation class >> example2 [

	^self new
		id: 7;
		passenger: GlorpPassenger example2.
]

{ #category : #'instance creation' }
GlorpReservation class >> new [
	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
GlorpReservation class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpReservation >> id [
	^id
]

{ #category : #accessing }
GlorpReservation >> id: anInteger [
	id := anInteger
]

{ #category : #'initialize/release' }
GlorpReservation >> initialize [
	passengers := OrderedCollection new.
]

{ #category : #accessing }
GlorpReservation >> passenger [
	^passenger
]

{ #category : #accessing }
GlorpReservation >> passenger: aPassenger [
	passenger := aPassenger.
	passengers add: aPassenger.
]

{ #category : #accessing }
GlorpReservation >> passengers [
	^passengers
]

{ #category : #accessing }
GlorpReservation >> passengers: aCollection [
	passengers := aCollection.
]
