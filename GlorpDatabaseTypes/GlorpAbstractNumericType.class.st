"
Abstract numeric type
"
Class {
	#name : #GlorpAbstractNumericType,
	#superclass : #GlorpDatabaseType,
	#category : #GlorpDatabaseTypes
}

{ #category : #converting }
GlorpAbstractNumericType >> impliedSmalltalkType [
	^Number.
]
