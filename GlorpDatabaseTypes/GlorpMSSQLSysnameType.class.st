Class {
	#name : #GlorpMSSQLSysnameType,
	#superclass : #GlorpDatabaseType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'VisualWorks metadata' }
GlorpMSSQLSysnameType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'exdi specific' }
GlorpMSSQLSysnameType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#String.
]

{ #category : #converting }
GlorpMSSQLSysnameType >> impliedSmalltalkType [
	^String.
]

{ #category : #testing }
GlorpMSSQLSysnameType >> isStringType [
	^true.
]

{ #category : #SQL }
GlorpMSSQLSysnameType >> typeString [

	^'sysname'.
]