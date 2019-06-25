"
ValidationError is a superclass for all errors that are raise while validating a descriptor. The exception may resume.


"
Class {
	#name : #ValidationError,
	#superclass : #GlorpError,
	#category : #GlorpMisc
}

{ #category : #testing }
ValidationError class >> mayResume [

	^true
]

{ #category : #'VisualWorks metadata' }
ValidationError class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #printing }
ValidationError >> description [
	^self messageText
]

{ #category : #accessing }
ValidationError >> model [
	^self parameter
]

{ #category : #accessing }
ValidationError >> model: aClass [
	self parameter: aClass
]
