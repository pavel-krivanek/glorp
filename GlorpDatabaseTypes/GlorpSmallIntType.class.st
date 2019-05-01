"
Small int type 
"
Class {
	#name : #GlorpSmallIntType,
	#superclass : #GlorpAbstractIntegerType,
	#category : #GlorpDatabaseTypes
}

{ #category : #initialize }
GlorpSmallIntType >> initialize [
	super initialize.
	typeString := 'smallint'.
]
