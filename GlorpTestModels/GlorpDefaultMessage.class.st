"
GlorpDefaultMessage is a notional default message whose text is used as template for its owning user.

Instance Variables:
	userRestrictions	<Array of: GlorpUser>	users who may not see my messages
"
Class {
	#name : #GlorpDefaultMessage,
	#superclass : #GlorpAbstractMessage,
	#instVars : [
		'userRestrictions'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpDefaultMessage class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpDefaultMessage >> contents [
	^'Hello', user name, ':  click ''WRITE'' to begin an email.'
]
