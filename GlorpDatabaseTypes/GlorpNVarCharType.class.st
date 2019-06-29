"
I model to an NVARCHAR database column. Some databases allow columns to be of type nchar or nvarchar.  The server has two encodings, with all chars and varchars using one, and all nchars and nvarchars using a (potentially) different encoding (usually #UTF16 or related).
"
Class {
	#name : #GlorpNVarCharType,
	#superclass : #GlorpVarCharType,
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpNVarCharType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'exdi specific' }
GlorpNVarCharType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#UnicodeString.
]

{ #category : #initialize }
GlorpNVarCharType >> initialize [
	super initialize.
	typeString := 'nvarchar'.
]

{ #category : #testing }
GlorpNVarCharType >> isNEncoded [
	"Return true if this is an NVARCHAR (or later, NCHAR) type."

	^true
]

{ #category : #testing }
GlorpNVarCharType >> measuresStringFieldWidthsInBytes [
	"I am false for SQLServer, Oracle, DB2 and MySQL.  For now, assume server's encode nvarchars as utf16 on all platforms."

	^false
]
