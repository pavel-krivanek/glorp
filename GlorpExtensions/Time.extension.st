Extension { #name : #Time }

{ #category : #'*GlorpExtensions-printing' }
Time >> glorpPadToTwoDigits: anInteger [
	| string |
	string := anInteger truncated printString.
	^string size = 1 ifTrue: ['0', string] ifFalse: [string].
]

{ #category : #'*GlorpExtensions-printing' }
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
