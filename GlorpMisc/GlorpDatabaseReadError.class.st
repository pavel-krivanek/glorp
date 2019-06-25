"
This is the error we raise when we encounter an exception inside Glorp's database read code. This is uniform across dialects, so it can be reliably caught. We wrap the underlying exception.

Instance Variables:
	accessor	<DatabaseAccessor>	The accessor we were executing against.
	command	<DatabaseCommand>	The command we were executing
	databaseError	<Exception>	The exception that the system raised.


"
Class {
	#name : #GlorpDatabaseReadError,
	#superclass : #GlorpError,
	#instVars : [
		'command',
		'databaseError',
		'accessor'
	],
	#category : #GlorpMisc
}

{ #category : #'as yet unclassified' }
GlorpDatabaseReadError class >> mayResume [
	^true.
]

{ #category : #accessing }
GlorpDatabaseReadError >> accessor [
	^accessor
]

{ #category : #accessing }
GlorpDatabaseReadError >> accessor: aDatabaseAccessor [
	accessor := aDatabaseAccessor
]

{ #category : #accessing }
GlorpDatabaseReadError >> command [
	^command
]

{ #category : #accessing }
GlorpDatabaseReadError >> command: aDatabaseCommand [
	command := aDatabaseCommand
]

{ #category : #accessing }
GlorpDatabaseReadError >> databaseError [
	^databaseError
]

{ #category : #accessing }
GlorpDatabaseReadError >> databaseError: aDatabaseErrorObject [
	databaseError := aDatabaseErrorObject
]

{ #category : #accessing }
GlorpDatabaseReadError >> session [
	^command session.
]