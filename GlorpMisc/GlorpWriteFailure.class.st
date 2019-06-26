"
I am raised if Glorp encounters an error while trying to write some rows. This typically indicates an optimistic lock failure, although it might also happen if we violated a constraint.  I can be handled via
	on: GlorpWriteFailure
	do: [:ex | ex resume: true]
to carry on and treat the whole operation as a success, or
	on: GlorpWriteFailure
	do: [:ex | ex resume: false]
(false is my defaultResumeValue, so 
	do: [:ex | ex resume]
would do as well) to raise a GlorpTransactionFailure.  See GlorpOptimisticLockingTest for examples of handling and not handling.

Instance Variables:
	command	<DatabaseCommand>	The command we were trying to execute.
	object	<Collection>			A collection of the one or more objects we were trying to write.


"
Class {
	#name : #GlorpWriteFailure,
	#superclass : #GlorpError,
	#instVars : [
		'command',
		'object'
	],
	#category : #'GlorpMisc-Glorp'
}

{ #category : #testing }
GlorpWriteFailure class >> mayResume [
	^true.
]

{ #category : #'VisualWorks metadata' }
GlorpWriteFailure class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpWriteFailure >> command [
	^command
]

{ #category : #accessing }
GlorpWriteFailure >> command: anObject [
	command := anObject
]

{ #category : #accessing }
GlorpWriteFailure >> defaultMessageText [
	^'Database write failed'.
]

{ #category : #constants }
GlorpWriteFailure >> defaultResumeValue [
	"If we resume, we encounter boolean-checking code.  It is pointless to resume and immediately meet a MustBeBoolean.  By default, resume with false, leading to a GlorpTransactionFailure."

	^false
]

{ #category : #accessing }
GlorpWriteFailure >> object [
	^object
]

{ #category : #accessing }
GlorpWriteFailure >> object: anObject [
	object := anObject
]

{ #category : #accessing }
GlorpWriteFailure >> session [
	^self command session.
]
