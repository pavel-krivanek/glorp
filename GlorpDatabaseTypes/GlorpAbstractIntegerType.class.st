Class {
	#name : #GlorpAbstractIntegerType,
	#superclass : #GlorpAbstractNumericType,
	#category : #GlorpDatabaseTypes
}

{ #category : #converting }
GlorpAbstractIntegerType >> converterForStType: aClass [
	(aClass includesBehavior: Boolean) ifTrue: [^self platform converterNamed: #booleanToInteger].
	^self platform converterNamed: #numberToInteger.
]

{ #category : #'exdi specific' }
GlorpAbstractIntegerType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#Integer.
]

{ #category : #converting }
GlorpAbstractIntegerType >> impliedSmalltalkType [
	^Integer.
]

{ #category : #'exdi specific' }
GlorpAbstractIntegerType >> initialize [
	super initialize.
	typeString := 'integer'.
]
