"
GlorpMessage is a notional email message.

Instance Variables:
	contents	<String>	some text for the message
	folder	<GlorpFolder>	folder containing message
	subject	<String>	title of message

"
Class {
	#name : #GlorpMessage,
	#superclass : #GlorpAbstractMessage,
	#instVars : [
		'subject',
		'folder',
		'contents'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
GlorpMessage class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
GlorpMessage class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpMessage >> contents [

	^contents
]

{ #category : #accessing }
GlorpMessage >> contents: aString [
	contents := aString.
]

{ #category : #accessing }
GlorpMessage >> folder [
	^folder
]

{ #category : #accessing }
GlorpMessage >> folder: aGlorpFolder [
	folder := aGlorpFolder.
]

{ #category : #accessing }
GlorpMessage >> folderName [
	^self folder name
]

{ #category : #'initialize-release' }
GlorpMessage >> initialize [
	contents := ''.
	subject := ''.
]

{ #category : #accessing }
GlorpMessage >> subject [
	^subject
]

{ #category : #accessing }
GlorpMessage >> subject: aString [
	subject := aString.
]
