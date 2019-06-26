Class {
	#name : #GlorpChar4Test,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #'GlorpDBTypeTests-GlorpDBTests'
}

{ #category : #'VisualWorks metadata' }
GlorpChar4Test class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpChar4Test >> defaultDatabaseType [
	^self platform char width: 4.
]

{ #category : #tests }
GlorpChar4Test >> testChar4 [

	stType := String.
	self helpTestValue: nil.
	self helpTestValue: '' compareWith: [:read :original |
		self platform usesNullForEmptyStrings ifTrue: [read = nil] ifFalse: [read = original]].
	self helpTestValue: 'a'.
	self helpTestValue: 'ab'.
	self helpTestValue: 'abc'.
	self helpTestValue: 'abcd'.
	self should: [self helpTestInvalidValue: 'abcde'] raise: GlorpDatabaseWriteError.
	stType := Symbol.

	"This overlong-means-invalid check fails on SQLite where column length limits are unenforced."
	self helpTestValue: #abcd.
	
	self assert: (type typeString asUppercase= (self platform char: 4) typeString asUppercase)
]

{ #category : #tests }
GlorpChar4Test >> testTrimmedChar4 [
	| converter |
	stType := String.
	converter := type platform converterNamed: #stringToTrimmedString.
	self assert: (converter convert:  'abc' toDatabaseRepresentationAs: type)
					= ('abc', (Array with: type platform paddingCharacter)).
	self assert: (converter convert:  'abcd' toDatabaseRepresentationAs: type) = 'abcd'.
	self assert: (converter convert:  'abcde' toDatabaseRepresentationAs: type) = 'abcd'.
]
