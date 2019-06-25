Class {
	#name : #ASOrder,
	#superclass : #Object,
	#instVars : [
		'orderNo',
		'lineItems',
		'customer'
	],
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
ASOrder class >> new [
	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ASOrder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ASOrder >> customer [

	^customer
]

{ #category : #accessing }
ASOrder >> customer: anObject [

	customer := anObject
]

{ #category : #'initialize-release' }
ASOrder >> initialize [
	orderNo := nil.
	lineItems := OrderedCollection new.
]

{ #category : #accessing }
ASOrder >> lineItems [

	^lineItems
]

{ #category : #accessing }
ASOrder >> lineItems: anObject [

	lineItems := anObject
]

{ #category : #accessing }
ASOrder >> orderNo [

	^orderNo
]

{ #category : #accessing }
ASOrder >> orderNo: anObject [

	orderNo := anObject
]