Class {
	#name : #GlorpDateType,
	#superclass : #GlorpDatabaseType,
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpDateType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #converting }
GlorpDateType >> converterForStType: aClass [

	^self platform converterNamed: #date.
]

{ #category : #'exdi specific' }
GlorpDateType >> exdiType [
	"VisualWorks EXDI assigns different symbols to dates on different platforms."

	^self platform exdiTypeForDate
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
