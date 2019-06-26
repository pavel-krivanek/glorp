Class {
	#name : #ClassQ,
	#superclass : #Object,
	#instVars : [
		'attrAClassQ',
		'attrBClassQ'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
ClassQ class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassQ >> attrAClassQ [

	^attrAClassQ
]

{ #category : #accessing }
ClassQ >> attrAClassQ: anObject [

	attrAClassQ := anObject
]

{ #category : #accessing }
ClassQ >> attrBClassQ [

	^attrBClassQ
]

{ #category : #accessing }
ClassQ >> attrBClassQ: anObject [

	attrBClassQ := anObject
]
