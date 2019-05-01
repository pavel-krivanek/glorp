Class {
	#name : #GlorpDateType,
	#superclass : #GlorpDatabaseType,
	#category : #GlorpDatabaseTypes
}

{ #category : #converting }
GlorpDateType >> converterForStType: aClass [

	^self platform converterNamed: #date.
]

{ #category : #'exdi specific' }
GlorpDateType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^self platform exdiTypeForDates.
]

{ #category : #converting }
GlorpDateType >> impliedSmalltalkType [
	^Date.
]

{ #category : #initialize }
GlorpDateType >> initialize [
	super initialize.
	typeString := 'date'
]

{ #category : #SQL }
GlorpDateType >> print: aValue on: aStream [
	"SQL in Postgres and other databases supports adding an integer to a date, meaning incrementing the date by that number of days, so we can be presented with an integer value."

	aValue isInteger ifTrue: [^self platform integer print: aValue on: aStream].
	aStream nextPutAll: (self platform printDate: aValue for: self).
]
