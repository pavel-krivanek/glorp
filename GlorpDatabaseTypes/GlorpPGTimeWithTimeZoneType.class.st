Class {
	#name : #GlorpPGTimeWithTimeZoneType,
	#superclass : #GlorpDatabaseType,
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpPGTimeWithTimeZoneType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'converting-times' }
GlorpPGTimeWithTimeZoneType >> converterForStType: aClass [
	"Convert as though we were a regular time field, since our Smalltalk object has no time zone information."

	^self platform converterNamed: #time.
]

{ #category : #'exdi specific' }
GlorpPGTimeWithTimeZoneType >> exdiType [
	^#Timetz
]

{ #category : #converting }
GlorpPGTimeWithTimeZoneType >> impliedSmalltalkType [
	^Time
]

{ #category : #initialize }
GlorpPGTimeWithTimeZoneType >> initialize [
	super initialize.
	typeString := 'TIME WITH TIME ZONE'.
]

{ #category : #SQL }
GlorpPGTimeWithTimeZoneType >> print: aValue on: aStream [
	"Print as though we were a regular time field, since our Smalltalk object has no time zone information."

	self platform time print: aValue on: aStream.
]
