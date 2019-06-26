"
Ths is a platform for SAPDB, but appears very unfinished;  for example, it needs to define int4, which is a subclassResponsibility inherit from the super.
"
Class {
	#name : #SAPDBPlatform,
	#superclass : #AdabasLikePlatform,
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #accessing }
SAPDBPlatform class >> kind [
	^'SAP'
]

{ #category : #'VisualWorks metadata' }
SAPDBPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
