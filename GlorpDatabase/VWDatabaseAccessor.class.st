"
An accessor for VisualWorks EXDI connections.

Instance Variables:
	driverSession	<ExternalDatabaseSession>	If we aren't re-using a prepared statement, then we work directly with a single EXDI session that we keep hold of and reuse for each command.
	preparedStatements	<UnmanagedCache>	A cache of prepared statements that we can re-use, if the platform supports such reuse, keyed by their SQL and bindTemplate concatenated.


"
Class {
	#name : #VWDatabaseAccessor,
	#superclass : #DatabaseAccessor,
	#instVars : [
		'driverSession',
		'preparedStatements'
	],
	#category : #GlorpDatabase
}

{ #category : #'exception handling' }
VWDatabaseAccessor class >> errorsToCatch [
	| pgError |
	pgError := Smalltalk at: #PostgreSQLEXDIException ifAbsent: [^Error].
	^Error, pgError.
]

{ #category : #'VisualWorks metadata' }
VWDatabaseAccessor class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
VWDatabaseAccessor >> answerForCommand: aCommand fromDBSession: aSession [
	"This may only be called immediately after execute.  Get the first answer.  If there are no rows returned but the command needa a count of rows affected, set the rowCount.  This may mean sending answer repeatedly if needed (i.e. by batched update or query-delete commands - or insert, but insert commands do not need row counts)."

	| ans |
	ans := aSession answer.
	aCommand needsRowCount ifFalse: [^ans].
	"Do not use optimistic locking if supportsRowCountFor: is false"
	(self platform supportsRowCountFor: aCommand) ifFalse: 
		["aCommand rowCount: nil would make clear it's not a valid value - but value should be nil anyway"
		"aCommand rowCount: aCommand expectedNumberOfModifiedRows would pretend we knew it worked"
		^ans].
	aCommand rowCount: aSession rowCount.
	[(ans := aSession answer) == #noAnswerStream]
		whileTrue: [aCommand rowCount: aCommand rowCount + aSession rowCount].
	^ans
]

{ #category : #executing }
VWDatabaseAccessor >> basicExecuteSQLString: aString [
	^self basicExecuteSQLString: aString binding: nil.
]

{ #category : #executing }
VWDatabaseAccessor >> basicExecuteSQLString: aString binding: aBindingArray [ 
	^self basicExecuteSQLString: aString returnResult: true binding: aBindingArray doing: [].
]

{ #category : #executing }
VWDatabaseAccessor >> basicExecuteSQLString: aString returnResult: returnResult binding: aBindingArray doing: aBlock [
	"Duplicate some of the logic of command execution, primarily because of the need to do special treatment depending if we want a result or not, and to execute the block. Put the statement into the driverSession (ugh) so that we can check the rowCount if necessary."

	| answerStream command statement session |
	answerStream := nil.
	command := SQLStringCommand new.
	command setSQLString: aString.
	command parameters: aBindingArray.
	(aBindingArray isNil or: [aBindingArray class ~= Association and: [aBindingArray isEmpty]]) ifTrue: [command useBinding: false].
	statement := self preparedStatementFor: command.
	session := statement statement.
	driverSession := session.
	command useBinding ifTrue: [
		session bindInput: aBindingArray].
	session execute.
	"Always do this, because at least with ODBC, if we don't ask for the answer, we don't get errors, and subsequent statements get them"
	answerStream := session answer.
	aBlock value.
	returnResult
		ifTrue: [| cursor |
			cursor := self cursorFor: answerStream command: command.
			cursor statement: statement.
			^cursor]
		ifFalse:	"The answer usually, not always, returns #noMoreAnswers, meaning state is #prepared, so the disconnect has less to do, which some EXDIs check"
			[answerStream == #noAnswerStream ifTrue: [session answer].
			session disconnect].
]

{ #category : #executing }
VWDatabaseAccessor >> basicExecuteSQLStringNoResult: aString doing: aBlock [
	^self basicExecuteSQLString: aString returnResult: false binding: nil doing: aBlock.
]

{ #category : #transactions }
VWDatabaseAccessor >> beginTransaction [
	self log: 'Begin Transaction'.
	self logOnly ifTrue: [^self].
	mutex critical: [connection begin]
]

{ #category : #transactions }
VWDatabaseAccessor >> commitTransaction [
	self log: 'Commit Transaction'.
	self logOnly ifTrue: [^self].
	mutex critical: [connection commit]
]

{ #category : #login }
VWDatabaseAccessor >> connectionClassForLogin: aLogin [ 
	^aLogin vwConnectionClass
]

{ #category : #accessing }
VWDatabaseAccessor >> createSession [
	"For Oracle, we set the defaultDisplayLobSize:.
	For DB2, set the sesssion's setDataChunkSize:"

	| session |
	session := connection getSession.
	(session respondsTo: #defaultDisplayLobSize:) ifTrue: [
		session defaultDisplayLobSize: DatabaseCommand new maximumLobSizeToRetrieveDirectly]. 
	(session respondsTo: #setDataChunkSize:) ifTrue: [
		session setDataChunkSize: DatabaseCommand new maximumLobSizeToRetrieveDirectly]. 
	session blockFactor: 100.  "We don't know, so make it big"
	^session.
]

{ #category : #accessing }
VWDatabaseAccessor >> createSessionFor: aCommand [
	"For Oracle, we set the defaultDisplayLobSize:.
	For DB2, set the sesssion's setDataChunkSize:"

	| session types |
	session := connection getSession.
	(session respondsTo: #defaultDisplayLobSize:) ifTrue: [
		session defaultDisplayLobSize: aCommand maximumLobSizeToRetrieveDirectly]. 
	(session respondsTo: #setDataChunkSize:) ifTrue: [
		session setDataChunkSize: DatabaseCommand new maximumLobSizeToRetrieveDirectly]. 
	session blockFactor: aCommand blockFactor.
	types := aCommand bindingTypesForEXDI.
	types isEmpty ifFalse: [session bindTemplate: types].
	^session.
]

{ #category : #accessing }
VWDatabaseAccessor >> currentLogin: aLogin [
	self reusePreparedStatements: aLogin database reusePreparedStatements.
	super currentLogin: aLogin.
]

{ #category : #cursors }
VWDatabaseAccessor >> cursorFor: answerStream [

	answerStream == #noAnswerStream ifTrue: [^#() readStream].
	answerStream == #noMoreAnswers ifTrue: [^#() readStream].

	^ super cursorFor: answerStream
]

{ #category : #cursors }
VWDatabaseAccessor >> cursorFor: answerStream command: aCommand [
	| stream |
	stream := answerStream.
	answerStream == #noAnswerStream ifTrue: [stream := #() readStream].
	answerStream == #noMoreAnswers ifTrue: [stream := #() readStream].
	^ super cursorFor: stream command: aCommand
]

{ #category : #executing }
VWDatabaseAccessor >> disconnect [

	self reset.
	^connection disconnect
]

{ #category : #accessing }
VWDatabaseAccessor >> driverSession [
	driverSession isNil ifTrue: [driverSession := self createSession].
	^driverSession.
]

{ #category : #accessing }
VWDatabaseAccessor >> encoding [
	^connection encoding.
]

{ #category : #executing }
VWDatabaseAccessor >> errorsToCatch [
	^self class errorsToCatch.
]

{ #category : #executing }
VWDatabaseAccessor >> executeCommand: aCommand inDBSession: aSession [
	"Execute the command, given a database session which has already been prepared for this command."

	| answerStream cursor |
	aSession execute.
	answerStream := self answerForCommand: aCommand fromDBSession: aSession.
	cursor := self cursorFor: answerStream command: aCommand.
	cursor statement: (GlorpPreparedStatement new statement: aSession).
	^cursor
]

{ #category : #executing }
VWDatabaseAccessor >> executeCommandBound: aCommand [
	| statement cursor time block |
	self logCommand: aCommand bound: true.
	self logOnly ifTrue: [^#() readStream].
	block := [
		statement := self statementFor: aCommand.
		statement statement bindInput: aCommand bindings.
		cursor := self executeCommand: aCommand inDBSession: statement statement.
		cursor statement: statement].
	time := Time millisecondsToRun: block.
	self logTime: time.
	^cursor.
]

{ #category : #executing }
VWDatabaseAccessor >> executeCommandUnbound: aCommand [
	| statement cursor block time |
	self logCommand: aCommand bound: false.
	self logOnly ifTrue: [^self].
	block := [
		statement := self statementFor: aCommand.
		cursor := self executeCommand: aCommand inDBSession: statement statement.
		cursor statement: statement].
	time := Time millisecondsToRun: block.
	self logTime: time.
	^cursor.
]

{ #category : #executing }
VWDatabaseAccessor >> executeSQLStringsNoResult: aString [
	"Executing an empty string returns an empty result, which then DNUs when sent #first, arguably a bug but while it exists we must avoid it.  We therefore check the supplied parameter size (to check for nil or empty) and exit quietly if so."

	aString size = 0 ifTrue: [^self].
	(aString tokensBasedOn: $;)
		do: [:each | each notEmpty ifTrue: [self executeSQLStringNoResult: each]].
]

{ #category : #executing }
VWDatabaseAccessor >> externalDatabaseErrorSignal [

	^connection class externalDatabaseErrorSignal.
]

{ #category : #'initialize-release' }
VWDatabaseAccessor >> initialize [
	super initialize.
	reusePreparedStatements := true.
	self initializePreparedStatementCache.
]

{ #category : #executing }
VWDatabaseAccessor >> innerExceptionFor: exception [
	(exception parameter isKindOf: GenericException) ifTrue: [^exception parameter].
	^exception.
]

{ #category : #transactions }
VWDatabaseAccessor >> isInTransaction [
	"This needs a logOnly guard but what the appropriate return value should be is less obvious than for the other guards in this class.  Returning true avoids code that would otherwise seek to create a transaction."

	self logOnly ifTrue: [^true].
	^connection inTransactionMode
]

{ #category : #login }
VWDatabaseAccessor >> isLoggedIn [

	connection isNil ifTrue: [^false].
	^connection isConnected
]

{ #category : #login }
VWDatabaseAccessor >> loginIfError: aBlock [
	"If the Login is secure, call the connection in its equivalent pattern (#connect:), otherwise set its password and call via #connect."

	self log: 'Login'.
	self logOnly ifTrue: [^self].
	connection := self connectionClass new.
	currentLogin preLoginInitializeFromAccessor: self.
	self
		execute:
			[self currentLogin secure
				ifTrue: [connection connect: currentLogin password]
				ifFalse: [connection connect].
			currentLogin postLoginInitializeFromAccessor: self]
		ifError: aBlock.
	self log: 'Login finished'
]

{ #category : #login }
VWDatabaseAccessor >> logout [
	self isLoggedIn ifFalse: [^self].
	self log: 'Logout'.
	self logOnly ifTrue: [^self].
	self execute: [connection disconnect. self reset] ifError: [:ex | ex return: nil].
	self log: 'Logout finished'
]

{ #category : #executing }
VWDatabaseAccessor >> newPreparedStatementFor: aCommand [
	| newSession |
	newSession := self createSessionFor: aCommand.
	aCommand useBinding
		ifTrue: [newSession prepare: aCommand sqlString]
		ifFalse: [newSession prepareWithoutBinding: aCommand sqlString].
	^(GlorpPreparedStatement new)
		signature: aCommand signature;
		statement: newSession;
		busy: true.
]

{ #category : #accessing }
VWDatabaseAccessor >> numberOfPreparedStatements [
	^preparedStatements numberOfElements.
]

{ #category : #copying }
VWDatabaseAccessor >> postCopy [
	super postCopy.
	self initializePreparedStatementCache.
]

{ #category : #executing }
VWDatabaseAccessor >> preparedStatementFor: aCommand [
	| wasMarkedBusyForUs statement |
	wasMarkedBusyForUs := false.
	statement := preparedStatements
		at: aCommand signature
		ifAbsentPut:
			[wasMarkedBusyForUs := true.
			self newPreparedStatementFor: aCommand].
	(wasMarkedBusyForUs not and: [statement busy])
		ifTrue: [statement := self newPreparedStatementFor: aCommand].
	^statement
]

{ #category : #cursors }
VWDatabaseAccessor >> releaseCursor: aCursor in: aPreparedStatement [
	"Release the cursor. We're trapping exceptions, so return true or false to indicate success/failure"
	aCursor isNil ifTrue: [^self].
	aPreparedStatement isNil ifTrue: [
		 ^(aCursor class ~~ ReadStream) ifTrue: [self halt] ifFalse: [self]].
	[aPreparedStatement statement isNil or: [aPreparedStatement statement answer == #noMoreAnswers]] whileFalse.
	^[aCursor close. true] on: Dialect error do: [:ex | ex return: false].
]

{ #category : #'initialize-release' }
VWDatabaseAccessor >> reset [
	super reset.
	preparedStatements release.
	self initializePreparedStatementCache.
	driverSession := nil.
]

{ #category : #transactions }
VWDatabaseAccessor >> rollbackTransaction [
	self log: 'Rollback Transaction'.
	self logOnly ifTrue: [^self].
	mutex critical: [connection rollback]
]

{ #category : #accessing }
VWDatabaseAccessor >> rowCount [
	"BE AWARE:  firstly, we no longer protect this call with a check of whether the driver supports it - callers now do that;  scondly, this assumes we know that we've executed no SQL since the last statement."

	^self driverSession rowCount
]

{ #category : #login }
VWDatabaseAccessor >> showDialog: aString [

	(Smalltalk at: #Dialog) warn: aString.
]

{ #category : #executing }
VWDatabaseAccessor >> statementFor: aCommand [
	^self reusePreparedStatements
		ifTrue: [self preparedStatementFor: aCommand]
		ifFalse: [self newPreparedStatementFor: aCommand].
]

{ #category : #cursors }
VWDatabaseAccessor >> upToEndOfResultSet: aGlorpCursoredStream [
	"The statement may have multiple result sets.  If the caller sends #upToEnd, the aggressive releasing of the cursor in #atEnd will lose any remaining result sets.  We therefore read the current result set and advance the underlying cursor to the next result set, releasing the Glorp cursor if we're called on the last result set.  (N.B. 'the next result set' does not necessarily mean the return of the next statement;  in a sequence of statements, some may return result sets while others return #noAnswerStream and these will be skipped).
	When releasing a non-nil underlying cursor, #release loops until #noMoreAnswers is returned;  it would loop forever if we called #release after receiving that result and without nilling the underlying cursor."

	| nextUnderlyingCursor resultSetContents |
	resultSetContents := aGlorpCursoredStream cursor upToEnd.
	[nextUnderlyingCursor := aGlorpCursoredStream statement statement answer.
	nextUnderlyingCursor == #noAnswerStream] whileTrue.
	nextUnderlyingCursor == #noMoreAnswers
		ifTrue: [aGlorpCursoredStream cursor: nil; release]
		ifFalse: [aGlorpCursoredStream cursor: nextUnderlyingCursor].
	^resultSetContents
]
