Class {
	#name : #GlorpBooleanType,
	#superclass : #GlorpDatabaseType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'VisualWorks metadata' }
GlorpBooleanType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #converting }
GlorpBooleanType >> converterForStType: aClass [
	(aClass includesBehavior: Boolean) ifTrue: [^self platform converterNamed: #booleanToBoolean].
	^self platform nullConverter.
]

{ #category : #'exdi specific' }
GlorpBooleanType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion.
	With Boolean, some platforms implement a Boolean column type (e.g. Postgres), or an acceptable equivalent (e.g. SQLServer provides Bit, requiring integer conversion). MySQLEXDI maps booleans to integers on writing but not on reading (MySQL has no boolean type so the EXDI can only see the column is an int8 when reading).  DB2 and Oracle have no.boolean type and their EXDIs do not support it."

	^self platform exdiTypeForBoolean
]

{ #category : #converting }
GlorpBooleanType >> impliedSmalltalkType [
	^Boolean.
]

{ #category : #SQL }
GlorpBooleanType >> print: aValue on: aStream [
	aStream nextPutAll: (self platform printBoolean: aValue for: self).
]
