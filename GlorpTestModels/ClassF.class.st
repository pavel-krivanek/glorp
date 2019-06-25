Class {
	#name : #ClassF,
	#superclass : #ClassE,
	#instVars : [
		'attrAClassF'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
ClassF class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassF >> attrAClassF [

	^attrAClassF
]

{ #category : #accessing }
ClassF >> attrAClassF: anObject [

	attrAClassF := anObject
]

{ #category : #'initialize-release' }
ClassF >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	" *** Edit the following to properly initialize instance variables ***"
	attrAClassF := nil.
	" *** And replace this comment with additional initialization code *** "
	^self
]
