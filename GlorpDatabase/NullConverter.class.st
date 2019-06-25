"
This is a no-op converter. When converting in either direction, it just returns the value.
"
Class {
	#name : #NullConverter,
	#superclass : #DatabaseConverter,
	#category : #GlorpDatabase
}

{ #category : #'VisualWorks metadata' }
NullConverter class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #converting }
NullConverter >> convert: anObject fromDatabaseRepresentationAs: aDatabaseType [
	^anObject.
]

{ #category : #converting }
NullConverter >> convert: anObject toDatabaseRepresentationAs: aDatabaseType [
	^anObject.
]
