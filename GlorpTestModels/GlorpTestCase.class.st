Class {
	#name : #GlorpTestCase,
	#superclass : #TestCase,
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
GlorpTestCase class >> isAbstract [
	^self sunitName = #GlorpTestCase
]

{ #category : #'as yet unclassified' }
GlorpTestCase class >> sunitName [
	^self name
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
