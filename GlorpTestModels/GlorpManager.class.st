Class {
	#name : #GlorpManager,
	#superclass : #GlorpEmployee,
	#instVars : [
		'branch'
	],
	#category : #GlorpTestModels
}

{ #category : #comparing }
GlorpManager >> = aManager [
	^super = aManager and: [branch = aManager branch].
]

{ #category : #accessing }
GlorpManager >> branch [
	^branch
]

{ #category : #accessing }
GlorpManager >> branch: anObject [
	branch := anObject
]
