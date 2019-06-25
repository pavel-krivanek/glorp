Class {
	#name : #ClassJ,
	#superclass : #Object,
	#instVars : [
		'attrAClassJ',
		'attrBClassJ',
		'attrCClassJ'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassJ class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassJ class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassJ >> addK: aKObj [
	attrCClassJ ifNil: [attrCClassJ := OrderedCollection new].
	attrCClassJ add: aKObj.
]

{ #category : #accessing }
ClassJ >> attrAClassJ [

	^attrAClassJ
]

{ #category : #accessing }
ClassJ >> attrAClassJ: anObject [

	attrAClassJ := anObject
]

{ #category : #accessing }
ClassJ >> attrBClassJ [

	^attrBClassJ
]

{ #category : #accessing }
ClassJ >> attrBClassJ: anObject [

	attrBClassJ := anObject
]

{ #category : #accessing }
ClassJ >> attrCClassJ [

	^attrCClassJ
]

{ #category : #accessing }
ClassJ >> attrCClassJ: anObject [

	attrCClassJ := anObject
]

{ #category : #'initialize-release' }
ClassJ >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassJ := nil.
	attrBClassJ := nil.
	attrCClassJ := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
