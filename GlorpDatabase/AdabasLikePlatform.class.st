"
This is a platform for Adabas and related databases.
"
Class {
	#name : #AdabasLikePlatform,
	#superclass : #DatabasePlatform,
	#category : #GlorpDatabase
}

{ #category : #testing }
AdabasLikePlatform >> supportsConstraints [
	^false
]
