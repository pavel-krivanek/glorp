Class {
	#name : #GlorpPassenger,
	#superclass : #Object,
	#instVars : [
		'id',
		'name',
		'frequentFlyerMiles',
		'airline'
	],
	#category : #GlorpTestModels
}

{ #category : #examples }
GlorpPassenger class >> example1 [

	^self new
		id: 3;
		name: 'Some Passenger';
		frequentFlyerPoints: 10000;
		airline: GlorpAirline example1.
]

{ #category : #examples }
GlorpPassenger class >> example2 [

	^self new
		id: 39;
		name: 'Some Other Passenger';
		frequentFlyerPoints: 7;
		airline: GlorpAirline example2.
]

{ #category : #'VisualWorks metadata' }
GlorpPassenger class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpPassenger >> airline [
	^airline.
]

{ #category : #accessing }
GlorpPassenger >> airline: anAirline [
	airline := anAirline.
]

{ #category : #accessing }
GlorpPassenger >> frequentFlyerPoints [
	^frequentFlyerMiles.
]

{ #category : #accessing }
GlorpPassenger >> frequentFlyerPoints: aSmallInteger [ 
	frequentFlyerMiles := aSmallInteger.
]

{ #category : #accessing }
GlorpPassenger >> id [
	^id
]

{ #category : #accessing }
GlorpPassenger >> id: aSmallInteger [ 
	id := aSmallInteger.
]

{ #category : #accessing }
GlorpPassenger >> name [
	^name.
]

{ #category : #accessing }
GlorpPassenger >> name: aString [ 
	name := aString.
]