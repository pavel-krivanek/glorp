Class {
	#name : #GlorpAbstractStringType,
	#superclass : #GlorpDatabaseType,
	#instVars : [
		'width',
		'queryType'
	],
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpAbstractStringType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #comparing }
GlorpAbstractStringType >> = aType [
	super = aType ifFalse: [^false].
	self width = aType width ifFalse: [^false].
	self queryType == self ifFalse: [
		self queryType = aType queryType ifFalse: [^false]].
	^true.
]

{ #category : #converting }
GlorpAbstractStringType >> converterForStType: aClass [
	(aClass includesBehavior: Boolean) ifTrue: [^self platform converterNamed: #booleanToStringTF].
	(aClass includesBehavior: Symbol) ifTrue: [^self platform converterNamed: #symbolToString].
	width isNil ifFalse: [
		(aClass includesBehavior: String) ifTrue: [^self platform converterNamed: #stringToString]].
	(aClass includesBehavior: Integer) ifTrue: [^self platform converterNamed: #integerToString].
	^super converterForStType: aClass.
]

{ #category : #'exdi specific' }
GlorpAbstractStringType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#String.
]

{ #category : #testing }
GlorpAbstractStringType >> hasParameters [
	"Return true if this has modifiable parameters. That is, when we return one of these, should we return a copy rather than trying to save space be re-using instances"
	^true.
]

{ #category : #testing }
GlorpAbstractStringType >> hasWidth [
	"Return true if this type has a width attribute - basically meaning it's a string or LOB type. Note that this is different from the isVariableWidth test, which tells us if a field has fixed vs. varying width. So a CHAR field hasWidth=>true, but isVariableWidth=>false, while a VARCHAR field hasWidth=>true isVariableWidth=>false, and a NUMBER has both false."
	^true.
]

{ #category : #comparing }
GlorpAbstractStringType >> hash [
	^self queryType == self
		ifTrue: [super hash bitXor: self width hash]
		ifFalse: [(super hash bitXor: self width hash) bitXor: self queryType hash]
]

{ #category : #converting }
GlorpAbstractStringType >> impliedSmalltalkType [
	^String.
]

{ #category : #testing }
GlorpAbstractStringType >> isNEncoded [
	"Return true if this is an NVARCHAR or NCHAR (or, later, an NTEXT, NCLOB, etc.) type."

	^false
]

{ #category : #testing }
GlorpAbstractStringType >> isStringType [
	^true.
]

{ #category : #testing }
GlorpAbstractStringType >> isVariableWidth [
	self subclassResponsibility.
]

{ #category : #testing }
GlorpAbstractStringType >> measuresStringFieldWidthsInBytes [
	"Return true if we measure the width of a char or varchar string in bytes rather than characters, i.e. if a 255-character field can hold 255 bytes worth of string, not 255 characters when some of them and non-ascii and encode to two bytes (UTF16 and UTF8) or three or four bytes(UTF8).  This is important when using a converter to trim a string to fit within a field's length.  (See GlorpN{Var}CharType>>measuresStringFieldWidthsInBytes for n{var}char lengths.)"

	^true
]

{ #category : #accessing }
GlorpAbstractStringType >> queryType [
	queryType isNil ifTrue: [^self].
	^queryType.
]

{ #category : #accessing }
GlorpAbstractStringType >> queryType: aType [
	queryType := aType
]

{ #category : #private }
GlorpAbstractStringType >> typeName [
	^typeString.
]

{ #category : #private }
GlorpAbstractStringType >> typeName: aString [
	typeString := aString.
]

{ #category : #SQL }
GlorpAbstractStringType >> typeString [
	typeString isNil
		ifTrue:
			[typeString := self typeName.
			width isNil
				ifFalse: [typeString := typeString , '(' , width printString , ')']].
	^typeString.
]

{ #category : #SQL }
GlorpAbstractStringType >> typeString: aString [
	"If we set the typeString, we are presumably setting it to the non-parameterized name as well"
	typeString := aString.
	super typeString: aString.
]

{ #category : #accessing }
GlorpAbstractStringType >> width [
	^width.
]

{ #category : #accessing }
GlorpAbstractStringType >> width: anInteger [

	width := anInteger = 0 ifTrue: [nil] ifFalse: [anInteger]
]
