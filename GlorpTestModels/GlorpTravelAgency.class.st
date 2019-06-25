"
This represents a travel agency. The interesting persistence feature of these is that they are embedded in the agent table, but also treated as unique objects with their own relationships.

Instance Variables:
	agents	<Collection of: GlorpTravelAgent>	description of agents
	name	<String>	description of name


"
Class {
	#name : #GlorpTravelAgency,
	#superclass : #Object,
	#instVars : [
		'name',
		'agents'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpTravelAgency class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #comparing }
GlorpTravelAgency >> = aGlorpTravelAgency [
	^self name = aGlorpTravelAgency name.
]

{ #category : #accessing }
GlorpTravelAgency >> agents [
	^agents
]

{ #category : #accessing }
GlorpTravelAgency >> agents: anObject [
	agents := anObject
]

{ #category : #accessing }
GlorpTravelAgency >> name [
	^name
]

{ #category : #accessing }
GlorpTravelAgency >> name: anObject [
	name := anObject
]
