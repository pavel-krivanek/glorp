Class {
	#name : #GlorpSlave,
	#superclass : #Object,
	#instVars : [
		'id'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpSlave class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpSlave >> id [
	^id.
]

{ #category : #accessing }
GlorpSlave >> id: anObject [
	id := anObject.
]
