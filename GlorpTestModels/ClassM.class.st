Class {
	#name : #ClassM,
	#superclass : #Object,
	#instVars : [
		'attrAClassM'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
ClassM class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassM >> attrAClassM [

	^attrAClassM
]

{ #category : #accessing }
ClassM >> attrAClassM: anObject [

	attrAClassM := anObject
]
