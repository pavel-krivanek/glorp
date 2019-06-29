Class {
	#name : #Successor,
	#superclass : #Object,
	#instVars : [
		'id',
		'successorCustomer',
		'successorFeeder',
		'station'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
Successor class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
Successor >> id [

	^id
]

{ #category : #accessing }
Successor >> id: anObject [

	id := anObject
]

{ #category : #accessing }
Successor >> station [

	^station
]

{ #category : #accessing }
Successor >> station: anObject [

	station := anObject
]

{ #category : #accessing }
Successor >> successorCustomer [

	^successorCustomer
]

{ #category : #accessing }
Successor >> successorCustomer: anObject [

	successorCustomer := anObject
]

{ #category : #accessing }
Successor >> successorFeeder [

	^successorFeeder
]

{ #category : #accessing }
Successor >> successorFeeder: anObject [

	successorFeeder := anObject
]
