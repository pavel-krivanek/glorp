Class {
	#name : #GlorpMSSQLFloatType,
	#superclass : #GlorpAbstractNumericType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'VisualWorks metadata' }
GlorpMSSQLFloatType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #SQL }
GlorpMSSQLFloatType >> converterForStType: aClass [

	^self platform converterNamed: #numberToDouble.
]

{ #category : #'exdi specific' }
GlorpMSSQLFloatType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#Float.
]

{ #category : #converting }
GlorpMSSQLFloatType >> impliedSmalltalkType [
	^Float.
]

{ #category : #initialize }
GlorpMSSQLFloatType >> initialize [
	super initialize.
	typeString := 'float'.
]

{ #category : #SQL }
GlorpMSSQLFloatType >> typeString [
	^'float'.
]
