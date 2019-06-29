"
GlorpPictureReview holds a picture (the one nominally review) and a sequence number:  is it the first, second, third, fourth, fifth or what'th review of the picture?  In real use, it would also hold some text (the actual review of teh picture) but we ignore that in this test example.

Instance Variables:
	picture	<GlorpTaggableObject>
	sequence	<Integer>


"
Class {
	#name : #GlorpPictureReview,
	#superclass : #Object,
	#instVars : [
		'picture',
		'sequence'
	],
	#category : #'GlorpTestModels-PolyTest'
}

{ #category : #'VisualWorks metadata' }
GlorpPictureReview class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpPictureReview >> picture [
	^picture
]

{ #category : #accessing }
GlorpPictureReview >> picture: aGlorpTaggableObject [
	picture := aGlorpTaggableObject.
]

{ #category : #accessing }
GlorpPictureReview >> sequence [
	^sequence
]

{ #category : #accessing }
GlorpPictureReview >> sequence: anInteger [
	sequence := anInteger.
]
