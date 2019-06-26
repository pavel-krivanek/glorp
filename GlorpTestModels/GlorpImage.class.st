Class {
	#name : #GlorpImage,
	#superclass : #GlorpTaggableObject,
	#instVars : [
		'id',
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

{ #category : #'as yet unclassified' }
GlorpImage >> location [
	^ location
]

{ #category : #'as yet unclassified' }
GlorpImage >> location: aLocation [
	location := aLocation
]
