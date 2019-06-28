"
I am a GlorpVideoRental offered with a promotion code.

Instance Variables:
	rentalPromotion	<String>	A promotion text for this video rental.
	storePromotionalName	<String>	An emphasised name of the video store we're renting from.

The test descriptor system converts rentalPromotion text to/from an abbreviated code on DB write/read.  It converts the store's name to uppercase on DB read into storePromotionalName, and to camelCase on DB write back into VIDEO_STORE.NAME.

"
Class {
	#name : #GlorpVideoRentalPromotion,
	#superclass : #GlorpVideoRental,
	#instVars : [
		'storePromotionalName',
		'rentalPromotion'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpVideoRentalPromotion class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpVideoRentalPromotion >> rentalPromotion [
	^rentalPromotion
]

{ #category : #accessing }
GlorpVideoRentalPromotion >> rentalPromotion: aString [
	rentalPromotion := aString.
]

{ #category : #accessing }
GlorpVideoRentalPromotion >> storePromotionalName [
	^storePromotionalName
]
