"
An accessor for ObjectStudio.

Instance Variables:
	inTransaction	<Boolean>	Are we in a transaction. We don't have an indicator for this from the database layer, so keep track of it here.


"
Class {
	#name : #ObjectStudioDatabaseAccessor,
	#superclass : #DatabaseAccessor,
	#instVars : [
		'inTransaction'
	],
	#category : #'Glorp-Database'
}

{ #category : #executing }
ObjectStudioDatabaseAccessor >> basicExecuteSQLString: aString [
	| result cursor records |
	result := connection execSql: aString.
	records := result records.
	"Fix up nulls"
	records do: [:each |
		1 to: each size do: [:i |
			(each at: i) == #'(NULL)' ifTrue: [each at: i put: nil]]].
	cursor := self cursorFor: (ReadStream on: result records).
	cursor statement: result.
	^cursor.
]

{ #category : #executing }
ObjectStudioDatabaseAccessor >> basicExecuteSQLString: aString bindingArray: aBindingArray [
	" *** This method was defined by Glorp.DatabaseAccessor as a subclass responsibility.
	Replace its body with a proper implementation. *** "

	self error: 'Subclass responsibility stub not reimplemented'
]

{ #category : #executing }
ObjectStudioDatabaseAccessor >> basicExecuteSQLString: aString returnResult: returnResult binding: aBindingArray doing: aBlock [

	^connection execSql: aString.
]

{ #category : #transactions }
ObjectStudioDatabaseAccessor >> beginTransaction [
	inTransaction := true.
	^connection beginTran.
]

{ #category : #transactions }
ObjectStudioDatabaseAccessor >> commitTransaction [
	inTransaction := false.
	^connection commit.
]

{ #category : #accessing }
ObjectStudioDatabaseAccessor >> connectionClassForLogin: aLogin [
	aLogin database class == OraclePlatform
		ifTrue: [^Smalltalk at: #OracleOCIDatabase ifAbsent: [self error: 'no such driver']].
	aLogin database isODBCPlatform ifTrue: [^Smalltalk at: #ODBCDatabase].
	self error: 'Unknown database: ' , aLogin database name.
]

{ #category : #executing }
ObjectStudioDatabaseAccessor >> externalDatabaseErrorSignal [
	^Error.
]

{ #category : #'initialize-release' }
ObjectStudioDatabaseAccessor >> initialize [
	inTransaction := false.
]

{ #category : #executing }
ObjectStudioDatabaseAccessor >> isInTransaction [
	^inTransaction.
]

{ #category : #login }
ObjectStudioDatabaseAccessor >> isLoggedIn [

	connection isNil ifTrue: [^false].
	^connection isActive
]

{ #category : #login }
ObjectStudioDatabaseAccessor >> loginIfError: aBlock [
	| |
"	connection :=self connectionClass 
		name: currentLogin connectString
		alias: currentLogin connectString
		password: currentLogin password
		drive: 'c'
		comment: currentLogin connectString
		create: false."
	connection := self connectionClass
		logOnServer: currentLogin connectString
		 user: currentLogin username
		 password: currentLogin password
		 alias: currentLogin connectString.
	(connection isKindOf: Message)
		ifTrue: [^self errorBoxMessage: connection asString].
	connection start.
]

{ #category : #login }
ObjectStudioDatabaseAccessor >> logout [
	connection class logOff.
]

{ #category : #executing }
ObjectStudioDatabaseAccessor >> releaseCursor: aCursor in: aPreparedStatement [
]

{ #category : #login }
ObjectStudioDatabaseAccessor >> rollbackTransaction [
	inTransaction := false.
	^connection rollback.
]

{ #category : #executing }
ObjectStudioDatabaseAccessor >> rowCount [
	^connection rowsProcessed.
]

{ #category : #'initialize-release' }
ObjectStudioDatabaseAccessor >> showDialog: aString [
	" *** This method was defined by Glorp.DatabaseAccessor as a subclass responsibility.
	Replace its body with a proper implementation. *** "

	self error: 'Subclass responsibility stub not reimplemented'
]
