"
This is a platform for the socket protocol 2 API of the PostgreSQL database.
"
Class {
	#name : #PostgreSQLPlatform,
	#superclass : #PostgresPlatform,
	#category : #GlorpDatabase
}

{ #category : #accessing }
PostgreSQLPlatform class >> kind [
	^'Postgres via old Socket I/F'
]

{ #category : #'VisualWorks metadata' }
PostgreSQLPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #testing }
PostgreSQLPlatform >> canBind: aValue to: aType [
	"In 7.10, the Postgres protocol 2.0 EXDI can accept Timestamp and Number formats for binding.  Date and time formats have not yet been handled."

	aType = self date ifTrue: [^false].
	aType = self time ifTrue: [^false].
	aType = self timetz ifTrue: [^false].
	^super canBind: aValue to: aType
]

{ #category : #'conversion-strings' }
PostgreSQLPlatform >> printBlob: aByteArray on: aStream for: aType [
	| encoderStream base64String |
	aByteArray isNil ifTrue: [^aStream nextPutAll: 'NULL'].
	Dialect isSqueak ifTrue: [^self squeakPrintBlob: aByteArray on: aStream for: aType].

	base64String := String new: (aByteArray size * 3/2) rounded.
	encoderStream := Dialect	"briefly set the encoderStream to its class"
		smalltalkAt: #Base64EncodingWriteStream
		ifAbsent: [nil].
	encoderStream isNil
		ifTrue:	"VisualWorks base:  set the encoder's lineLength to ensure no line breaks added to base64 string."
			[encoderStream := (base64String withEncoding: 'Base64') writeStream.
			encoderStream encoder  lineLength: aByteArray size * 3.
			encoderStream nextPutAll: aByteArray; close.
			aStream nextPutAll: encoderStream encodedContents printString]
		ifFalse:
			[encoderStream := encoderStream on: base64String.
			encoderStream disableLineBreaks.
			encoderStream nextPutAll: aByteArray.
			encoderStream close.
			aStream nextPutAll: encoderStream contents printString].
]

{ #category : #accessing }
PostgreSQLPlatform >> vwEXDIConnectionClass [
	^'PostgreSQLEXDIConnection' asQualifiedReference valueIfUndefinedLoadFrom: 'PostgreSQLEXDI'
]
