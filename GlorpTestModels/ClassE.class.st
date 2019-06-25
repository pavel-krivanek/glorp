Class {
	#name : #ClassE,
	#superclass : #Object,
	#instVars : [
		'attrAClassE',
		'attrBClassE'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassE class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassE class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassE >> attrAClassE [

	^attrAClassE
]

{ #category : #accessing }
ClassE >> attrAClassE: anObject [

	attrAClassE := anObject
]

{ #category : #accessing }
ClassE >> attrBClassE [

	^attrBClassE
]

{ #category : #accessing }
ClassE >> attrBClassE: anObject [

	attrBClassE := anObject
]

{ #category : #'initialize-release' }
ClassE >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassE := nil.
	attrBClassE := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
