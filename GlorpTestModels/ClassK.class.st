Class {
	#name : #ClassK,
	#superclass : #Object,
	#instVars : [
		'attrAClassK',
		'attrBClassK',
		'attrCClassK'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassK class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassK class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassK >> attrAClassK [

	^attrAClassK
]

{ #category : #accessing }
ClassK >> attrAClassK: anObject [

	attrAClassK := anObject
]

{ #category : #accessing }
ClassK >> attrBClassK [

	^attrBClassK
]

{ #category : #accessing }
ClassK >> attrBClassK: anObject [

	attrBClassK := anObject
]

{ #category : #accessing }
ClassK >> attrCClassK [

	^attrCClassK
]

{ #category : #accessing }
ClassK >> attrCClassK: anObject [

	attrCClassK := anObject
]

{ #category : #'initialize-release' }
ClassK >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassK := nil.
	attrBClassK := nil.
	attrCClassK := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
