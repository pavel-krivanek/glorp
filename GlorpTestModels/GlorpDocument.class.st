Class {
	#name : #GlorpDocument,
	#superclass : #Object,
	#instVars : [
		'id',
		'whatever',
		'attachments'
	],
	#category : #'GlorpTestModels-AAGlorp'
}

{ #category : #glorp }
GlorpDocument class >> glorpSetupClassModel: model forSystem: system [ 
	model
		newAttributeNamed: #id;
		newAttributeNamed: #whatever;
		newAttributeNamed: #attachments
			collection: OrderedCollection
			of: GlorpAttachment
]

{ #category : #glorp }
GlorpDocument class >> glorpSetupDescriptor: aDesc forSystem: system [ 
	| t |
	t := system tableNamed: 'document'.
	aDesc table: t.
	(aDesc newMapping: DirectMapping) from: #id to: (t fieldNamed: 'id').
	(aDesc newMapping: DirectMapping) from: #whatever to: (t fieldNamed: 'whatever').
	(aDesc newMapping: OneToManyMapping)
		attributeName: #attachments;
		orderBy: [:ea | ea index]
]

{ #category : #'VisualWorks metadata' }
GlorpDocument class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpDocument >> attachments [
	^attachments
]

{ #category : #accessing }
GlorpDocument >> attachments: anObject [
	attachments := anObject
]

{ #category : #accessing }
GlorpDocument >> id [
	^id
]

{ #category : #accessing }
GlorpDocument >> id: anObject [
	id := anObject
]

{ #category : #'initialize-release' }
GlorpDocument >> initialize [
	attachments := OrderedCollection new.
	whatever := 3.
]
