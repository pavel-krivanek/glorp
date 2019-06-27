Class {
	#name : #GlorpVarchar4Test,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #'GlorpDBTypeTests-GlorpDBTests'
}

{ #category : #'VisualWorks metadata' }
GlorpVarchar4Test class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpVarchar4Test >> defaultDatabaseType [
	^self platform varchar: 4.
]

{ #category : #tests }
GlorpVarchar4Test >> testTrimmedChar4 [
	| converter |
	stType := String.
	converter := type platform converterNamed: #stringToTrimmedString.
	self assert: (converter convert:  'abc' toDatabaseRepresentationAs: type) = 'abc'.
	self assert: (converter convert:  'abcd' toDatabaseRepresentationAs: type) = 'abcd'.
	self assert: (converter convert:  'abcde' toDatabaseRepresentationAs: type) = 'abcd'.
]

{ #category : #tests }
GlorpVarchar4Test >> testVarChar4 [
	self platform isUDBCSQLite3Platform ifTrue: [ ^ self skip. ].
	stType := String.
	self helpTestValue: nil.
	self helpTestValue: '' compareWith: [:read :original |
		self platform usesNullForEmptyStrings ifTrue: [read = nil] ifFalse: [read = original]].
	self helpTestValue: 'a'.
	self helpTestValue: 'ab'.
	self helpTestValue: 'abc'.
	self helpTestValue: 'abcd'.
	stType := Symbol.
	self helpTestValue: #abcd.
	stType := nil.

	"This overlong-means-invalid check fails on SQLite where column length limits are unenforced."
	self should: [self helpTestInvalidValue: 'abcde'] raise: GlorpDatabaseWriteError.
]
