Class {
	#name : #ClassC,
	#superclass : #Object,
	#instVars : [
		'attrAClassC',
		'attrBClassC'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassC class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassC class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassC >> attrAClassC [

	^attrAClassC
]

{ #category : #accessing }
ClassC >> attrAClassC: anObject [

	attrAClassC := anObject
]

{ #category : #accessing }
ClassC >> attrBClassC [

	^attrBClassC
]

{ #category : #accessing }
ClassC >> attrBClassC: anObject [

	attrBClassC := anObject
]

{ #category : #'initialize-release' }
ClassC >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassC := nil.
	attrBClassC := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
