"
This is a sequence that doesn't do anything. It's really just a placeholder.
"
Class {
	#name : #NullSequence,
	#superclass : #DatabaseSequence,
	#classVars : [
		'NullSequence'
	],
	#category : #'Glorp-Database'
}

{ #category : #defaults }
NullSequence class >> default [

	^self new.
]

{ #category : #'instance creation' }
NullSequence class >> new [

	Singleton isNil ifTrue: [Singleton := self basicNew].
	^Singleton.
]

{ #category : #public }
NullSequence >> getSequenceValueFromDatabaseFor: aField in: aRow using: aSession [
]

{ #category : #sequencing }
NullSequence >> postWriteAssignSequenceValueFor: aField in: aRow [
]

{ #category : #sequencing }
NullSequence >> postWriteAssignSequenceValueFor: aField in: aRow using: anAccessor [
]

{ #category : #sequencing }
NullSequence >> preWriteAssignSequenceValueFor: aField in: aRow [
]
