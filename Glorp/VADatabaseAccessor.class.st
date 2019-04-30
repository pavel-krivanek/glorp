"
An accessor for VisualAge 8.0 and higher. 

Instance Variables
	isInTransaction	<Boolean>	Are we in a transaction. We don't have an indicator for this from the database layer, so keep track of it here.



"
Class {
	#name : #VADatabaseAccessor,
	#superclass : #DatabaseAccessor,
	#instVars : [
		'isInTransaction'
	],
	#classInstVars : [
		'databaseErrorSignal'
	],
	#category : #'Glorp-Database'
}

{ #category : #accessing }
VADatabaseAccessor class >> externalDatabaseErrorSignal [

	databaseErrorSignal isNil ifTrue: [self initializeDatabaseErrorSignal ].
	^databaseErrorSignal
]

{ #category : #initialization }
VADatabaseAccessor class >> initializeDatabaseErrorSignal [

	databaseErrorSignal := ((Smalltalk at: #SystemExceptions) at: 'ExError') newChild.
	databaseErrorSignal markReadOnly: false;
		description: 'Database error';
		resumable: true;
		defaultHandler: nil;
		markReadOnly: true
]

{ #category : #executing }
VADatabaseAccessor >> basicExecuteSQLString: aString [
	^self basicExecuteSQLString: aString binding: nil
]

{ #category : #'As yet unclassified' }
VADatabaseAccessor >> basicExecuteSQLString: aString binding: aBindingArray [
	"VA does not return results for as many statements as VW.  Some calls that take returnResult: true in VW
do not want to return a result in the basic VA RDB framework that we call.  We therefore check the String and
only ask for a return if it is a select statement.  (This is experimental and could be reviewed.)"

	^self
		basicExecuteSQLString: aString
		returnResult: (aString copyFrom: 1 to: (6 min: aString size)) asUppercase = 'SELECT'
		binding: aBindingArray
		doing: []
]

{ #category : #'As yet unclassified' }
VADatabaseAccessor >> basicExecuteSQLString: aString returnResult: returnResult binding: aBindingArray doing: aBlock [
	"^<GlorpCursoredStream | empty readStream> This method executes a general SQL command against the connection.
If a result is requested, it returns a GlorpCursoredStream wrapping an AbtResultTable that (should) hold an AbtCursor.  If
not, it returns self to cursorFor: which returns an empty readStream since along one calling route VA does not provide a
result if the string is not a select whereas VW does in general, and the caller sends upToEnd.
	Later, develop to use GlorpPreparedStatements (c.f. this method in VW) and resultTableFromQuerySpec:withValues:...
VW creates an SQLStringCommand to put in the cursor."

	^self cursorFor:  (returnResult		"was check if aString was SELECT statement, now moved to a caller"
		ifFalse:
			[connection
				executeSQLStatement: aString
				ifError: [:err | GlorpError signalWith: err].
			aBlock value.
			self]					"must return self to be handled in cursorFor:"
		ifTrue:
			[self basicExecuteSQLStringWithResult: aString doing: aBlock])
]

{ #category : #'As yet unclassified' }
VADatabaseAccessor >> basicExecuteSQLStringNoResult: aString doing: aBlock [
	^self basicExecuteSQLString: aString returnResult: false binding: nil doing: aBlock.
]

{ #category : #'As yet unclassified' }
VADatabaseAccessor >> basicExecuteSQLStringWithResult: aString doing: aBlock [
	"^<AbtResultTable | self> This VA-specific method returns an AbtResultTable unless it fails.  Later,
add a binding: parameter and call resultTableFromQuerySpec:withValues:ifError:"

	| resultTable |
	resultTable := connection
		resultTableFromQuerySpec: ((Smalltalk at: #AbtQuerySpec) new statement: aString)
		ifError: [:err | GlorpError signalWith: err].
	^resultTable isAbtError
		ifTrue: 
			[GlorpError signalWith: resultTable.
			#() readStream]
		ifFalse:
			[aBlock value.
			resultTable]
]

{ #category : #transactions }
VADatabaseAccessor >> beginTransaction [
	self log: 'Begin Transaction'.
	isInTransaction := true.
	self logOnly ifTrue: [^self].
	self connection beginUnitOfWork.
]

{ #category : #transactions }
VADatabaseAccessor >> commitTransaction [
	self log: 'Commit Transaction'.
	isInTransaction := false.
	self logOnly ifTrue: [^self].
	self connection commitUnitOfWorkIfError: 
			[:err |
			self log: 'Commit Transaction failed.'. 
			self connection autoCommit: true.
			self todo: 'Need to handle this error somehow....'.
			"errorBlock value: err"].
]

{ #category : #login }
VADatabaseAccessor >> connectionClassForLogin: aLogin [ 
	aLogin database isDB2Platform ifTrue: [^ Smalltalk at: #AbtIbmCliDatabaseManager].
	aLogin database class == OraclePlatform 
		ifTrue: [^Smalltalk at: #AbtOracle10DatabaseManager].
	aLogin database isODBCPlatform 
		ifTrue: [^Smalltalk at: #AbtOdbcDatabaseManager].
	aLogin database isPostgreSQLPlatform 
		ifTrue: [self error: 'PostgreSQL is not yet supported under VA'].
	self error: 'Unknown database platform' , aLogin database printString
]

{ #category : #cursors }
VADatabaseAccessor >> cursorFor: aStream [
	"basicExecuteSQLString: binding: sets returnResult: to false if aString does not begin with 'SELECT' but
its non-VA-specific caller executeSQLString:binding: sends upToEnd to what it returns, expecting the more
usual behaviour of returnResult always being true on that branch.  Thu we return an empty readStream, like
the VW implementation of this method in other no-return cases."

	aStream == self ifTrue: [^#() readStream].
	aStream onFinalizeDo: #close.
	"In V8Beta, the finalize cycle has not always been run by the time the database' databaseMgr has been nilled,
	causing a DNU when trying to get the error block (that it will not run).  If this persists, replace #close above with
		Message selector: #closeIfError: arguments: (Array with: aStream errorBlock)
	so we get the block when we know we can."
	^super cursorFor: aStream.
]

{ #category : #'As yet unclassified' }
VADatabaseAccessor >> databaseName [
	"connect string looks like  hostname:portNumber_db-name. :portNumber is optional.
	If the string is zero, return nil."

	| str dbIndex |
	str := self currentLogin connectString.
	dbIndex := str indexOf: $_.
	^str copyFrom: dbIndex + 1 to: str size
]

{ #category : #executing }
VADatabaseAccessor >> executeCommandUnbound: aCommand [
	| answerStream |
	self log: aCommand sqlString.	"change to self logCommand: aCommand sqlString bound: false."
	self logOnly ifTrue: [^self].
	answerStream := self
		basicExecuteSQLStringWithResult: aCommand sqlString
		doing: [].
	"See new method #answerForCommand:fromDBSession: in VWDatabaseAccessor - it _may_ be advantageous to use something similar here "
	aCommand needsRowCount ifTrue:
		[aCommand rowCount:
			((self platform supportsRowCountFor: aCommand)
				ifTrue: [answerStream rowCount]
				ifFalse: [1])].
	^self cursorFor: answerStream command: aCommand
]

{ #category : #executing }
VADatabaseAccessor >> externalDatabaseErrorSignal [

	^self class externalDatabaseErrorSignal.
]

{ #category : #initialize }
VADatabaseAccessor >> initialize [
	super initialize.
	isInTransaction := false.
]

{ #category : #executing }
VADatabaseAccessor >> innerExceptionFor: exception [
	^exception exception.
]

{ #category : #cursors }
VADatabaseAccessor >> isCursorAtEnd: aCursor [
	"Return true if aCursor is at its end."

	^aCursor actuallyAtEnd.
]

{ #category : #transactions }
VADatabaseAccessor >> isInTransaction [
	^isInTransaction
]

{ #category : #login }
VADatabaseAccessor >> isLoggedIn [

	^connection notNil
]

{ #category : #login }
VADatabaseAccessor >> logStream [
	^Transcript
]

{ #category : #login }
VADatabaseAccessor >> loginIfError: aBlock [ 
	"
		This method creates a NEW database connection.
	"

	| dbMgrClass anAbtDatabaseLogonSpec anAbtDatabaseConnectionSpec aliasNameString baseAliasName |
	self log: 'Login'.
	self logOnly ifTrue: [^self].
	aliasNameString := baseAliasName := currentLogin connectString.

	"
		We try to generate a unique alias name to get a new connection and to 
		prevent the normal VAST behaviour to reuse a connection
	"
	
	[((Smalltalk at: #AbtDbmSystem) 
		activeDatabaseConnectionWithAlias: aliasNameString) notNil] 
			whileTrue: 
				[aliasNameString := baseAliasName , Time millisecondClockValue printString].


	"
		Get the native VA class responsible for doing the work against the
		three special connections available in VA
	"
	dbMgrClass := self connectionClass.

	"
		Get the logon specification for the database ... do not use
		any server information
	"
	anAbtDatabaseLogonSpec := (Smalltalk at: #AbtDatabaseLogonSpec) 
				id: currentLogin username
				password: currentLogin password
				server: self serverName.

	"	
		Get the specification for the connection ... 
   "
	anAbtDatabaseConnectionSpec := (Smalltalk at: #AbtDatabaseConnectionSpec) 
				forDbmClass: dbMgrClass
				dataSourceName: self databaseName.
	connection := anAbtDatabaseConnectionSpec 
				connectUsingAlias: aliasNameString
				logonSpec: anAbtDatabaseLogonSpec
				ifError: 
					[:error | 
					"throw away the connection ..."
					connection := nil.
					aBlock value: error].
	connection isNil ifFalse: [
		connection databaseMgr errorBlock: [:err | self externalDatabaseErrorSignal signalWith: err]].
]

{ #category : #login }
VADatabaseAccessor >> logout [
	self isLoggedIn ifFalse: [^self].
	self log: 'Logout'.
	self logOnly ifTrue: [^self].
	"disconnectIfError: doesn't properly catch errors."
	[
	[connection disconnectIfError: [:ex | self logError: ex]]
		ensure:	[connection := nil]]
		  on: Dialect error
		  do: [:ex | ex return: nil].
	self log: 'Logout finished'
]

{ #category : #cursors }
VADatabaseAccessor >> releaseCursor: aCursor in: aPreparedStatement [
	aCursor close.
]

{ #category : #accessing }
VADatabaseAccessor >> returnRowCount: aBoolean [

	connection isNil ifFalse: [connection queryRowCount: true].
]

{ #category : #transactions }
VADatabaseAccessor >> rollbackTransaction [
	self log: 'Rollback Transaction'.
	isInTransaction := false.
	self logOnly ifTrue: [^self].
	self connection rollbackUnitOfWork.
]

{ #category : #accessing }
VADatabaseAccessor >> rowCount [
	^connection rowCount.
]

{ #category : #'As yet unclassified' }
VADatabaseAccessor >> serverName [
	"connect string looks like  hostname:portNumber_db-name. The :portNumber is optional;
	for the moment, we ignore it.  If the hostName is empty, return nil."

	| str dbIndex "portIndex index" |
	str := self currentLogin connectString.
"	portIndex := index := str indexOf: $:."
	dbIndex := str indexOf: $_.
"	index = 0 ifTrue: [index := dbIndex]."
	^dbIndex = 0 ifFalse: [str copyFrom: 1 to: dbIndex - 1]
]

{ #category : #login }
VADatabaseAccessor >> showDialog: aString [

	(Smalltalk at: #CwMessagePrompter) warn: aString.
]

{ #category : #development }
VADatabaseAccessor >> todo: aString [

	^self
]
