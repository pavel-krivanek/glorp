"
This is an abstract superclass for GLORP exceptions.

"
Class {
	#name : #GlorpError,
	#superclass : #Error,
	#category : #'GlorpMisc-GlorpCore'
}

{ #category : #'exception compatibility' }
GlorpError class >> ancestorOf: anExceptionThingy [
	"VA Compatibility"
	^self exceptionalEvent handles: anExceptionThingy
]

{ #category : #'exception compatibility' }
GlorpError class >> description [
	"For ObjectStudio"
	^super description.
]

{ #category : #testing }
GlorpError class >> mayResume [
	"This is a VisualWorks convention. Reimplement this here so that it will also be found in other dialects that don't have it in the superclass."
	^false
]

{ #category : #ANSI }
GlorpError class >> signal [
	^self new signal.
]

{ #category : #ANSI }
GlorpError class >> signal: aString [
	^self new signal: aString.
]

{ #category : #'VisualWorks metadata' }
GlorpError class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #testing }
GlorpError >> ancestorOf: anExceptionThingy [
	"VA Compatibility"
	^self handles: anExceptionThingy
]

{ #category : #accessing }
GlorpError >> databaseError [
"rh 8/1/2004 21:26 for #getMessageText"

	^self class name
]

{ #category : #printing }
GlorpError >> description [
	"Make sure that we've populated our messageText before calling the superclass implementation."

	self messageText.
	^super description
]

{ #category : #accessing }
GlorpError >> getMessageText [
	
	^self databaseError
]

{ #category : #accessing }
GlorpError >> getVisualAgeMessageText [
	
	| tempTag |
	tempTag := self basicTag.
	^tempTag isNil ifTrue: [self printString] ifFalse: [tempTag errorText].
]

{ #category : #accessing }
GlorpError >> getVisualWorksMessageText [
	"In VisualWorks, we can get arrays of ExternalDatabaseExceptions, whose parameter is an array of ExternalDatabaseError objects. Or we might just get an exception, or we might get nil or something else entirely, in which case we fall back to a default error message."

	| dbError |
	self databaseError isNil ifTrue: [^messageText := self defaultMessageText].
	dbError := self databaseError.
	dbError glorpIsCollection ifTrue: [dbError := dbError first].
	messageText := [dbError dbmsErrorString] on: Error do: [:ex | nil].
	messageText isNil ifFalse: [^messageText].
	messageText := [dbError description] on: Error do: [:anotherEx | self defaultMessageText].
	^messageText
]

{ #category : #testing }
GlorpError >> isResumable [
	^self class mayResume.
]

{ #category : #accessing }
GlorpError >> messageText [
	(messageText isNil or: [messageText isEmpty]) ifTrue: [
		messageText := self getMessageText].
	^messageText.
]

{ #category : #accessing }
GlorpError >> session [
	"We don't know what our session is, return nil by default."
	^nil.
]

{ #category : #ANSI }
GlorpError >> signal [
	"VisualWorks has non-ANSI semantics for this method. Re-implement to do the standard thing"
	^Dialect isVisualWorks ifTrue: [self raise] ifFalse: [super signal].
]

{ #category : #ANSI }
GlorpError >> signal: aString [
	"VisualWorks has non-ANSI semantics for this method. Re-implement to do the standard thing"

	^Dialect isVisualWorks
		ifTrue:
			[self messageText: aString.
			self raise]
		ifFalse: [super signal: aString].
]
