Class {
	#name : #GlorpClobType,
	#superclass : #GlorpAbstractStringType,
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpClobType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'exdi specific' }
GlorpClobType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#LargeString.
]

{ #category : #testing }
GlorpClobType >> hasParameters [
	"Return true if this has modifiable parameters. That is, when we return one of these, should we return a copy rather than trying to save space be re-using instances"
	^false.
]

{ #category : #initialize }
GlorpClobType >> initialize [
	super initialize.
	typeString := 'text'.
	width := nil.
]

{ #category : #testing }
GlorpClobType >> isVariableWidth [
	^true.
]

{ #category : #testing }
GlorpClobType >> requiresCast [
	^(self platform isPostgreSQLPlatform) or: [self platform isSQLServerPlatform]
]
