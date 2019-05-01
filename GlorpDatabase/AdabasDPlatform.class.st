"
This is a platform for the Adabas database, but appears very unfinished;  for example, it needs to define int4, which is a subclassResponsibility inherit from the super.
"
Class {
	#name : #AdabasDPlatform,
	#superclass : #AdabasLikePlatform,
	#category : #GlorpDatabase
}

{ #category : #accessing }
AdabasDPlatform class >> kind [
	^'Adabas'
]
