Class {
	#name : #GlorpImage,
	#superclass : #GlorpTaggableObject,
	#instVars : [
		'location'
	],
	#category : #'GlorpTestModels-PolyTest'
}

{ #category : #'as yet unclassified' }
GlorpImage class >> fromStream: aStream [
	^ self new image: aStream
]

{ #category : #'VisualWorks metadata' }
GlorpImage class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpImage >> location [
	^ location
]

{ #category : #accessing }
GlorpImage >> location: aLocation [
	location := aLocation
]
