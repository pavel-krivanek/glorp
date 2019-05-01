Extension { #name : #Time }

{ #category : #'*GlorpExtensions' }
Time >> glorpPadToTwoDigits: anInteger [
	| string |
	string := anInteger truncated printString.
	^string size = 1 ifTrue: ['0', string] ifFalse: [string].
]

{ #category : #'*GlorpExtensions' }
Time >> glorpPrintSQLOn: aCommand [
	"Print as 24 hour time"

	aCommand 
		nextPut: $';
		nextPutAll: 	(self glorpPadToTwoDigits: self hours);
		nextPut: $:;
		nextPutAll: (self glorpPadToTwoDigits: self minutes);
		nextPut: $:;
		nextPutAll: (self glorpPadToTwoDigits: self seconds);
		nextPut: $'.
]

{ #category : #'*GlorpExtensions' }
Time >> millisecond: anInteger [ 

	nanos := (anInteger rem: 1000) * 1000000

]

{ #category : #'*GlorpExtensions' }
Time >> milliseconds [
	^ (nanos / 1000000.0)truncated 
]
