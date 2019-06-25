Class {
	#name : #GlorpBookstoreCustomer,
	#superclass : #Object,
	#instVars : [
		'name',
		'accountNumber',
		'booksOnOrder'
	],
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
GlorpBookstoreCustomer class >> new [
	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
GlorpBookstoreCustomer class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpBookstoreCustomer >> accountNumber [
	^accountNumber
]

{ #category : #accessing }
GlorpBookstoreCustomer >> accountNumber: anObject [
	accountNumber := anObject
]

{ #category : #accessing }
GlorpBookstoreCustomer >> booksOnOrder [
	^booksOnOrder
]

{ #category : #accessing }
GlorpBookstoreCustomer >> booksOnOrder: someBooks [
	booksOnOrder := someBooks.
]

{ #category : #'initialize-release' }
GlorpBookstoreCustomer >> initialize [
	booksOnOrder := OrderedCollection new.
]

{ #category : #accessing }
GlorpBookstoreCustomer >> name [
	^name
]

{ #category : #accessing }
GlorpBookstoreCustomer >> name: anObject [
	name := anObject
]
