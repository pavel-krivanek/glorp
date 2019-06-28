Class {
	#name : #Station,
	#superclass : #Object,
	#instVars : [
		'id',
		'successor'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
Station class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
Station >> id [

	^id
]

{ #category : #accessing }
Station >> id: anObject [

	id := anObject
]

{ #category : #accessing }
Station >> successor [

	^successor
]

{ #category : #accessing }
Station >> successor: anObject [

	successor := anObject
]
