Class {
	#name : #GlorpAttachment,
	#superclass : #Object,
	#instVars : [
		'index',
		'mimeType',
		'attachmentBytes'
	],
	#category : #'GlorpTestModels-AAGlorp'
}

{ #category : #glorp }
GlorpAttachment class >> glorpSetupClassModel: model forSystem: system [ 
	model
		newAttributeNamed: #index;
		newAttributeNamed: #mimeType;
		newAttributeNamed: #attachmentBytes type: GlorpAttachmentBytes
]

{ #category : #glorp }
GlorpAttachment class >> glorpSetupDescriptor: aDesc forSystem: system [ 
	| t |
	t := system tableNamed: 'attachment'.
	aDesc table: t.
	(aDesc newMapping: DirectMapping) from: #index
		to: (t fieldNamed: 'indexInDocument').
	(aDesc newMapping: DirectMapping) from: #mimeType
		to: (t fieldNamed: 'mimetype').
	(aDesc newMapping: OneToOneMapping) attributeName: #attachmentBytes
]

{ #category : #'VisualWorks metadata' }
GlorpAttachment class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpAttachment >> attachmentBytes [
	^attachmentBytes
]

{ #category : #accessing }
GlorpAttachment >> attachmentBytes: anObject [
	attachmentBytes := anObject
]

{ #category : #accessing }
GlorpAttachment >> index [
	^index
]

{ #category : #accessing }
GlorpAttachment >> index: anObject [
	index := anObject
]

{ #category : #accessing }
GlorpAttachment >> mimeType [
	^mimeType
]

{ #category : #accessing }
GlorpAttachment >> mimeType: anObject [
	mimeType := anObject
]
