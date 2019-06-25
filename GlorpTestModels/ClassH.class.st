Class {
	#name : #ClassH,
	#superclass : #Object,
	#instVars : [
		'attrAClassH',
		'attrBClassH',
		'attrCClassH',
		'attrDClassH'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassH class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassH class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassH >> attrAClassH [

	^attrAClassH
]

{ #category : #accessing }
ClassH >> attrAClassH: anObject [

	attrAClassH := anObject
]

{ #category : #accessing }
ClassH >> attrBClassH [

	^attrBClassH
]

{ #category : #accessing }
ClassH >> attrBClassH: anObject [

	attrBClassH := anObject
]

{ #category : #accessing }
ClassH >> attrCClassH [

	^attrCClassH
]

{ #category : #accessing }
ClassH >> attrCClassH: anObject [

	attrCClassH := anObject
]

{ #category : #accessing }
ClassH >> attrDClassH [

	^attrDClassH
]

{ #category : #accessing }
ClassH >> attrDClassH: anObject [

	attrDClassH := anObject
]

{ #category : #'initialize-release' }
ClassH >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassH := nil.
	attrBClassH := nil.
	attrCClassH := nil.
	attrDClassH := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
