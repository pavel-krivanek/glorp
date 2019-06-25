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
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#Boolean.
]

{ #category : #converting }
GlorpBooleanType >> impliedSmalltalkType [
	^Boolean.
]

{ #category : #SQL }
GlorpBooleanType >> print: aValue on: aStream [
	aStream nextPutAll: (self platform printBoolean: aValue for: self).
]
