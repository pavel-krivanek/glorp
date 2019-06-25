Class {
	#name : #GlorpFloatType,
	#superclass : #GlorpAbstractNumericType,
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpFloatType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #converting }
GlorpFloatType >> converterForStType: aClass [

	^self platform converterNamed: #numberToFloat.
]

{ #category : #'exdi specific' }
GlorpFloatType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#Float.
]

{ #category : #converting }
GlorpFloatType >> impliedSmalltalkType [
	^Float.
]

{ #category : #initialize }
GlorpFloatType >> initialize [
	super initialize.
	typeString := 'float4'.
]
