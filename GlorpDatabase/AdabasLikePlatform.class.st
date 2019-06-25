"
This is a platform for Adabas and related databases.
"
Class {
	#name : #AdabasLikePlatform,
	#superclass : #DatabasePlatform,
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #'VisualWorks metadata' }
AdabasLikePlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #testing }
AdabasLikePlatform >> supportsConstraints [
	^false
]
