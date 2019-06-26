Class {
	#name : #GlorpTestCase,
	#superclass : #TestCase,
	#category : #'GlorpTestModels-SUnit'
}

{ #category : #testing }
GlorpTestCase class >> isAbstract [
	^self sunitName = #GlorpTestCase
]

{ #category : #'VisualWorks metadata' }
GlorpTestCase class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'XProgramming.SUnit'
	)

]

{ #category : #hacks }
GlorpTestCase >> knownFailure [
	"This does nothing, but makes it easier to search for known failures."
	^self.
]

{ #category : #hacks }
GlorpTestCase >> unfinished [
]
