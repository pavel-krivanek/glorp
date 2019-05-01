Class {
	#name : #GlorpDecimalType,
	#superclass : #GlorpNumericType,
	#category : #GlorpDatabaseTypes
}

{ #category : #converting }
GlorpDecimalType >> converterForStType: aClass [

	^self platform converterNamed: #numberToDecimal.
]

{ #category : #initialize }
GlorpDecimalType >> initialize [

	super initialize.
	typeString := 'decimal'.
]
