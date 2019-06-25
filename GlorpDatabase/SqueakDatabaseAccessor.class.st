"
A database accessor for Squeak.

Instance Variables:
	isInTransaction	<Boolean>	Are we in a transaction. We don't have an indicator for that from the database layer, so keep track of it here.


"
Class {
	#name : #SqueakDatabaseAccessor,
	#superclass : #DatabaseAccessor,
	#instVars : [
		'isInTransaction'
	],
	#category : #GlorpDatabase
}

{ #category : #'VisualWorks metadata' }
SqueakDatabaseAccessor class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
SqueakDatabaseAccessor >> basicExecuteSQLString: aString [
	| result rowCollection |
	self log: aString.
	self logOnly ifTrue: [^self].
	result := connection execute: aString.
	result errorResponse notNil
		ifTrue:
			[self externalDatabaseErrorSignal signal: result errorResponse value].
	rowCollection := OrderedCollection new.
	result rows do: [:ea | rowCollection add: ea data asArray].
 	^rowCollection asArray
]

{ #category : #executing }
SqueakDatabaseAccessor >> basicExecuteSQLStringNoResult: aString doing: aBlock [

	| a |
	a := self basicExecuteSQLString: aString.
	aBlock value.
	^a
]

{ #category : #transactions }
SqueakDatabaseAccessor >> beginTransaction [
	self log: 'Begin Transaction'.
	isInTransaction := true.
	self logOnly ifTrue: [^self].
	connection execute: 'BEGIN TRANSACTION'
]

{ #category : #transactions }
SqueakDatabaseAccessor >> commitTransaction [
	self log: 'Commit Transaction'.
	isInTransaction := false.
	self logOnly ifTrue: [^self].
	connection execute: 'COMMIT TRANSACTION'
]

{ #category : #login }
SqueakDatabaseAccessor >> connectionArgsFromCurrentLogin [

	"connect string looks like  hostname:portNumber_db-name. :portNumber is optional"
	| str portIndex index dbIndex |
	str := self currentLogin connectString.
	portIndex := index := str indexOf: $:.
	dbIndex := str indexOf: $_.
	index = 0 ifTrue: [index := dbIndex].
	^(Dialect smalltalkAt: #PGConnectionArgs)
		hostname: (str copyFrom: 1 to: index - 1)
		portno: (portIndex = 0 ifTrue: [5432] ifFalse: [(str copyFrom: portIndex + 1 to: dbIndex - 1) asNumber])
		databaseName: (str copyFrom: dbIndex + 1 to: str size)
		userName: self currentLogin username
		password: self currentLogin password
]

{ #category : #login }
SqueakDatabaseAccessor >> connectionClassForLogin: aLogin [ 
	aLogin database class == PostgreSQLPlatform
		ifTrue: [^ Smalltalk at: #PGConnection].
	self error: 'Unknown database: ' , aLogin database
]

{ #category : #executing }
SqueakDatabaseAccessor >> disconnect [
	^ connection disconnect
]

{ #category : #executing }
SqueakDatabaseAccessor >> executeCommandUnbound: aCommand [
	| answerStream |
	self log: aCommand sqlString.
	self logOnly ifTrue: [^self].
	answerStream := ReadStream on: (self basicExecuteSQLString: aCommand sqlString).
	"See new method #answerForCommand:fromDBSession: in VWDatabaseAccessor - it _may_ be advantageous to use something similar here "
	aCommand needsRowCount ifTrue:
		[aCommand rowCount:
			((self platform supportsRowCountFor: aCommand)
				ifTrue: [answerStream rowCount]
				ifFalse: [1])].
	^self cursorFor: answerStream command: aCommand
]

{ #category : #executing }
SqueakDatabaseAccessor >> externalDatabaseErrorSignal [
	^ Dialect error
]

{ #category : #initialize }
SqueakDatabaseAccessor >> initialize [
	super initialize.
	isInTransaction := false
]

{ #category : #executing }
SqueakDatabaseAccessor >> innerExceptionFor: exception [
	"I don't know how to get the inner error in Squeak"
	^exception messageText.
]

{ #category : #transactions }
SqueakDatabaseAccessor >> isInTransaction [
	^ isInTransaction
]

{ #category : #login }
SqueakDatabaseAccessor >> isLoggedIn [
	connection isNil
		ifTrue: [^ false].
	^ connection isConnected
]

{ #category : #login }
SqueakDatabaseAccessor >> loginIfError: aBlock [ 
	self log: 'Login'.
	self logOnly ifTrue: [^self].
	connection := self connectionClass new.
	connection connectionArgs: self connectionArgsFromCurrentLogin.
	self
		execute: [connection startup]
		ifError: aBlock.
	self log: 'Login finished'
]

{ #category : #login }
SqueakDatabaseAccessor >> logout [
	self isLoggedIn ifFalse: [^self].
	self log: 'Logout'.
	self logOnly ifTrue: [^self].
	self execute: [connection terminate].
	self log: 'Logout finished'
]

{ #category : #executing }
SqueakDatabaseAccessor >> releaseCursor: aCursor in: aPreparedStatement [
	"Release the cursor. We're trapping exceptions, so return true or false to indicate success/failure"
	aCursor isNil ifTrue: [^self].
	^[aCursor close. true] on: Dialect error do: [:ex | ex return: false].
]

{ #category : #transactions }
SqueakDatabaseAccessor >> rollbackTransaction [
	self log: 'Rollback Transaction'.
	isInTransaction := false.
	self logOnly ifTrue: [^self].
	connection execute: 'ROLLBACK TRANSACTION'
]

{ #category : #executing }
SqueakDatabaseAccessor >> rowCount [

	|count|
	count := 0.
	connection result resultSets
		do: [:each| count := count + 
			(each completedResponse value subStrings: (Array with: Character space)) last asInteger].
	^count
]

{ #category : #login }
SqueakDatabaseAccessor >> showDialog: aString [ 
	"Do 'Smalltalk at: #PopUpMenu' so that the code will compile in other dialects, even if it won't run"

	(Smalltalk at: #PopUpMenu) inform: aString
]
