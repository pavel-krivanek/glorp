Class {
	#name : #ClassI,
	#superclass : #Object,
	#instVars : [
		'attrAClassI',
		'attrBClassI'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassI class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassI class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassI >> attrAClassI [

	^attrAClassI
]

{ #category : #accessing }
ClassI >> attrAClassI: anObject [

	attrAClassI := anObject
]

{ #category : #accessing }
ClassI >> attrBClassI [

	^attrBClassI
]

{ #category : #accessing }
ClassI >> attrBClassI: anObject [

	attrBClassI := anObject
]

{ #category : #'initialize-release' }
ClassI >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassI := nil.
	attrBClassI := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
