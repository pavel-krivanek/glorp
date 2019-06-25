Class {
	#name : #ASCustomer,
	#superclass : #Object,
	#instVars : [
		'id',
		'name',
		'orders',
		'customer'
	],
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
ASCustomer class >> new [
	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ASCustomer class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ASCustomer >> customer [

	^customer
]

{ #category : #accessing }
ASCustomer >> customer: anObject [

	customer := anObject
]

{ #category : #accessing }
ASCustomer >> id [

	^id
]

{ #category : #accessing }
ASCustomer >> id: anObject [

	id := anObject
]

{ #category : #'initialize-release' }
ASCustomer >> initialize [
	id := nil.
	customer := nil.
	name := nil.
	orders := OrderedCollection new.
]

{ #category : #accessing }
ASCustomer >> name [

	^name
]

{ #category : #accessing }
ASCustomer >> name: anObject [

	name := anObject
]

{ #category : #accessing }
ASCustomer >> orders [

	^orders
]

{ #category : #accessing }
ASCustomer >> orders: anObject [

	orders := anObject
]
