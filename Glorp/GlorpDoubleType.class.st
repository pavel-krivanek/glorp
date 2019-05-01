Class {
	#name : #GlorpDoubleType,
	#superclass : #GlorpAbstractNumericType,
	#category : #'Glorp-Types'
}

{ #category : #converting }
GlorpDoubleType >> converterForStType: aClass [

	^self platform converterNamed: #numberToDouble.
]

{ #category : #'exdi specific' }
GlorpDoubleType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#Double.
]

{ #category : #converting }
GlorpDoubleType >> impliedSmalltalkType [
	^Dialect doublePrecisionFloatClass.
]

{ #category : #initialize }
GlorpDoubleType >> initialize [
	super initialize.
	typeString := 'double precision'.
]
