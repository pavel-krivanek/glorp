Class {
	#name : #GlorpPGTimestampWithTimeZoneType,
	#superclass : #GlorpDatabaseType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'exdi specific' }
GlorpPGTimestampWithTimeZoneType >> exdiType [
	^#Timestamptz
]

{ #category : #converting }
GlorpPGTimestampWithTimeZoneType >> impliedSmalltalkType [
	^Dialect timestampClass
]

{ #category : #accessing }
GlorpPGTimestampWithTimeZoneType >> initialize [
	super initialize.
	typeString := 'TIMESTAMP WITH TIME ZONE'.
]

{ #category : #SQL }
GlorpPGTimestampWithTimeZoneType >> print: aValue on: aStream [
	"Print as though we were a regular timestamp field, since we have no time zone information."

	self platform timestamp print: aValue on: aStream.
]
