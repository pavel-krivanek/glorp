Class {
	#name : #GlorpPortrait,
	#superclass : #GlorpTaggableObject,
	#instVars : [
		'subjectFullName'
	],
	#category : #'GlorpTestModels-PolyTest'
}

{ #category : #'VisualWorks metadata' }
GlorpPortrait class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpPortrait >> id [

	^id
]

{ #category : #accessing }
GlorpPortrait >> id: anInteger [
	id := anInteger.
]

{ #category : #accessing }
GlorpPortrait >> subjectFullName [
	^subjectFullName
]

{ #category : #accessing }
GlorpPortrait >> subjectFullName: aString [
	subjectFullName := aString.
]
