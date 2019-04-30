"
Ths is a platform for SAPDB, but appears very unfinished;  for example, it needs to define int4, which is a subclassResponsibility inherit from the super.
"
Class {
	#name : #SAPDBPlatform,
	#superclass : #AdabasLikePlatform,
	#category : #'Glorp-Database'
}

{ #category : #accessing }
SAPDBPlatform class >> kind [
	^'SAP'
]
