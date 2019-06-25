Class {
	#name : #GlorpManager,
	#superclass : #GlorpEmployee,
	#instVars : [
		'branch'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpManager class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

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
