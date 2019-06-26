Class {
	#name : #ClassB,
	#superclass : #Object,
	#instVars : [
		'attrAClassB',
		'attrBClassB',
		'attrCClassB',
		'attrDClassB'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassB class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassB class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassB >> attrAClassB [

	^attrAClassB
]

{ #category : #accessing }
ClassB >> attrAClassB: anObject [

	attrAClassB := anObject
]

{ #category : #accessing }
ClassB >> attrBClassB [

	^attrBClassB
]

{ #category : #accessing }
ClassB >> attrBClassB: anObject [

	attrBClassB := anObject
]

{ #category : #accessing }
ClassB >> attrCClassB [

	^attrCClassB
]

{ #category : #accessing }
ClassB >> attrCClassB: anObject [

	attrCClassB := anObject
]

{ #category : #accessing }
ClassB >> attrDClassB [

	^attrDClassB
]

{ #category : #accessing }
ClassB >> attrDClassB: anObject [

	attrDClassB := anObject
]

{ #category : #'initialize-release' }
ClassB >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassB := nil.
	attrBClassB := nil.
	attrCClassB := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
