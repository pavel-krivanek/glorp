"
Abstract superclass for email messages.

Instance Variables:
	user	<GlorpUser>	the sender of the message


"
Class {
	#name : #GlorpAbstractMessage,
	#superclass : #Object,
	#instVars : [
		'user'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpAbstractMessage class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpAbstractMessage >> user [
	^user
]

{ #category : #accessing }
GlorpAbstractMessage >> user: aGlorpUser [
	user := aGlorpUser.
]

{ #category : #accessing }
GlorpAbstractMessage >> userId [
	^self user id
]
