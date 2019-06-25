Class {
	#name : #GlorpBankBranch,
	#superclass : #Object,
	#instVars : [
		'accounts',
		'branchNumber'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpBankBranch class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpBankBranch >> accounts [
	^accounts
]

{ #category : #accessing }
GlorpBankBranch >> accounts: anObject [
	accounts := anObject
]

{ #category : #accessing }
GlorpBankBranch >> branchNumber [
	^branchNumber.
]

{ #category : #accessing }
GlorpBankBranch >> branchNumber: aString [
	branchNumber := aString
]

{ #category : #printing }
GlorpBankBranch >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '(', self branchNumber printString, ')'.
]