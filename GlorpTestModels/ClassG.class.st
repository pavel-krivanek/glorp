Class {
	#name : #ClassG,
	#superclass : #ClassE,
	#instVars : [
		'attrAClassG'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
ClassG class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassG >> attrAClassG [

	^attrAClassG
]

{ #category : #accessing }
ClassG >> attrAClassG: anObject [

	attrAClassG := anObject
]

{ #category : #'initialize-release' }
ClassG >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassG := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
