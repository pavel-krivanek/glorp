Class {
	#name : #GlorpMediaType,
	#superclass : #Object,
	#instVars : [
		'name',
		'mimeType'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'instance creation' }
GlorpMediaType class >> text [
	^self new name: 'text'; mimeType: 'text/plain'
]

{ #category : #'VisualWorks metadata' }
GlorpMediaType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpMediaType >> mimeType [
	^mimeType
]

{ #category : #accessing }
GlorpMediaType >> mimeType: anObject [
	mimeType := anObject
]

{ #category : #accessing }
GlorpMediaType >> name [ 
	^name
]

{ #category : #accessing }
GlorpMediaType >> name: anObject [
	name := anObject
]
