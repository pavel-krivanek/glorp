Class {
	#name : #GlorpTimeStampType,
	#superclass : #GlorpDatabaseType,
	#category : #'Glorp-Types'
}

{ #category : #converting }
GlorpTimeStampType >> converterForStType: aClass [
	aClass = Date ifTrue: [^self platform converterNamed: #timestampToDate].
	^self platform converterNamed: #timestamp.
]

{ #category : #'exdi specific' }
GlorpTimeStampType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#Timestamp.
]

{ #category : #converting }
GlorpTimeStampType >> impliedSmalltalkType [
	^Dialect timestampClass.
]

{ #category : #SQL }
GlorpTimeStampType >> print: aValue on: aStream [
	"SQL in Oracle and SQLServer (which use type timestamp for dates as well as timestamps) supports adding an integer to a date, meaning incrementing the date by that number of days.  A bound integer value will go directly to the database layer;  an unbound value will go through here."

	aValue isInteger ifTrue: [^self platform integer print: aValue on: aStream].
	self platform printTimestamp: aValue on: aStream for: self.
]
