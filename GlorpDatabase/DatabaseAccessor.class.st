"
This translates between the the general, portable Glorp protocol and whatever needs to be done to access a database in a particular smalltalk dialect. Most of the real work is done in its subclasses.

Subclasses must implement the following messages:
	accessing
		connectionClassForLogin:
	executing
		basicExecuteSQLString:
		externalDatabaseErrorSignal
		rowCount
	login
		loginIfError:
		logout
		showDialog:

Instance Variables
	connection	<varies>	The underlying database connection
	currentLogin	<Login> The glorp-level login we are using
	logging	<Boolean>	(default is false) Is logging on or off
	logOnly <Boolean> (default is false) If logging is true, and logOnly is true, then the commands are ONLY logged and not executed.
	logger <TextCollector> (default is Transcript) The user can put any TextCollector API supporting class in here to collect information. It must support #show: and #cr.
	permittedCommands	<Collection of: DatabaseCommand class>	The list of commands we are permitted to use. This allows us to filter commands, indicating that a particular session should only be doing inserts right now, not updates, deletes, or queries. Or that it should only be doing writes, not reads.
	reusePreparedStatements	<Boolean>	Should we try to reuse prepared statements,that have the same SQL, or just re-prepare each time.


"
Class {
	#name : #DatabaseAccessor,
	#superclass : #Object,
	#instVars : [
		'connection',
		'currentLogin',
		'logging',
		'logger',
		'logOnly',
		'reusePreparedStatements',
		'deniedCommands',
		'mutex',
		'dependents'
	],
	#classVars : [
		'LoggingEnabled'
	],
	#category : #GlorpDatabase
}

{ #category : #'instance creation' }
DatabaseAccessor class >> classForThisPlatform [

	Dialect isVisualWorks ifTrue: [^Dialect smalltalkAt: #'Glorp.VWDatabaseAccessor'].
	Dialect isObjectStudio ifTrue: [^Dialect smalltalkAt: #ObjectStudioDatabaseAccessor].
	Dialect isGNU ifTrue: [^Dialect smalltalkAt: #JdmDatabaseAccessor].
	Dialect isSqueak ifTrue: [^Dialect smalltalkAt: #SqueakDatabaseAccessor].
	Dialect isVisualAge ifTrue: [^Dialect smalltalkAt: #VADatabaseAccessor].
	Dialect isDolphin ifTrue: [^Dialect smalltalkAt: #DolphinDatabaseAccessor].
	self error: 'unknown dialect'.
	^self
]

{ #category : #'instance creation' }
DatabaseAccessor class >> forLogin: aLogin [ 
	^self classForThisPlatform new currentLogin: aLogin
]

{ #category : #accessing }
DatabaseAccessor class >> loggingEnabled [
	LoggingEnabled isNil ifTrue: [LoggingEnabled := false].
	^LoggingEnabled
]

{ #category : #accessing }
DatabaseAccessor class >> loggingEnabled: aBoolean [ 
	LoggingEnabled := aBoolean
]

{ #category : #'instance creation' }
DatabaseAccessor class >> new [

	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
DatabaseAccessor class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #executing }
DatabaseAccessor >> addConstraint: aConstraint [ 
	
	^self 
		addConstraint: aConstraint
		ifError: [ :ex | 	| msg|
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Add constraint <1s> ERROR: (<2s>) ' expandMacrosWith: aConstraint name with: msg).
				ex return: nil].
]

{ #category : #executing }
DatabaseAccessor >> addConstraint: aConstraint ifError: aBlock [
	| addString |
	addString := self platform createConstraintAddStatement: aConstraint.
	addString isEmpty ifTrue: [^self].	"If platform does not support constraints, silently do nothing."
	^self
		executeInDDLOperation: [self executeSQLStringNoResult: addString]
		ifError: aBlock
]

{ #category : #executing }
DatabaseAccessor >> addFields: aCollection [ 

	self 
		addFields: aCollection 
		ifError: [ :ex  | 	| msg |
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Add field ERROR: (<2s>) ' expandMacrosWith: msg).
				ex return: nil]
]

{ #category : #executing }
DatabaseAccessor >> addFields: aCollection ifError: aBlock [

	aCollection
		do: 	[:aField | 
			self execute: [self executeSQLStringNoResult: (self platform createAddColumnStatementFor: aField)]
				ifError: aBlock ].
]

{ #category : #permissions }
DatabaseAccessor >> allowCommand: aCommand during: aBlock [
	"If deniedCommands is nil, everything is already permitted;  just evaluate the block.  Otherwise, permit the command and any subclasses, evaluate the block, then revert."

	| oldCommands |
	oldCommands := deniedCommands ifNil: [^aBlock value].
	aCommand withAllSubclasses do:
		[:each |
		(deniedCommands includes: each) ifTrue:
			[deniedCommands := deniedCommands copyWithout: aCommand]].
	^aBlock ensure: [deniedCommands := oldCommands]
]

{ #category : #permissions }
DatabaseAccessor >> alsoDenyCommand: aCommand [
	"Use this method, not denyCommand: when you want to add to, not override, the current permissions state."

	self deniedCommands isNil
		ifTrue: [self denyCommand: aCommand]
		ifFalse: [deniedCommands := deniedCommands , aCommand withAllSubclasses].
]

{ #category : #executing }
DatabaseAccessor >> alterField: aField newType: aType [ 

	^self 
		alterField: aField 
		newType: aType 
		ifError: [ :ex | 	| msg|
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Alter column <1s> to set new type <2s> ERROR: (<3s>) ' expandMacrosWith: aField name with: aType sqlString with: msg).
				ex return: nil].
]

{ #category : #executing }
DatabaseAccessor >> alterField: aField newType: aType ifError: aBlock [

	^self doDDLOperation: [
		self 
			execute: [self executeSQLStringNoResult: 
						(self platform createAlterColumnStatement: aField newType: aType)]
			ifError: aBlock ]
]

{ #category : #executing }
DatabaseAccessor >> alterField: aField setDefault: aType [

	self 
		alterField: aField 
		setDefault: aType 
		ifError: [ :ex | 	| msg|
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Alter column  <1s> to set default <2s>  ERROR: (<2s>) ' expandMacrosWith: aField name with: aType sqlString with: msg).
				ex return: nil].
]

{ #category : #executing }
DatabaseAccessor >> alterField: aField setDefault: anObject ifError: aBlock [

	^self doDDLOperation: [
		self 
			execute: [self executeSQLStringNoResult: 
						(self platform createAlterColumnStatement: aField setDefault: anObject )]
			ifError: aBlock ]
]

{ #category : #executing }
DatabaseAccessor >> alterFieldDropDefault: aField [

	self 
		alterFieldDropDefault: aField 
		ifError: [ :ex | 	| msg|
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Alter column  <1s> to drop default ERROR: (<2s>) ' expandMacrosWith: aField name  with: msg).
				ex return: nil].
]

{ #category : #executing }
DatabaseAccessor >> alterFieldDropDefault: aField ifError: aBlock [

	^self doDDLOperation: [
		self 
			execute: [self executeSQLStringNoResult: 
						(self platform createAlterColumnStatementDropDefault: aField)]
			ifError: aBlock ]
]

{ #category : #executing }
DatabaseAccessor >> alterFieldDropNotNull: aField [

	self 
		alterFieldDropNotNull: aField 
		ifError: [ :ex | 	| msg|
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Alter column  <1s> to drop not null ERROR: (<2s>) ' expandMacrosWith: aField name  with: msg).
				ex return: nil].
]

{ #category : #executing }
DatabaseAccessor >> alterFieldDropNotNull: aField ifError: aBlock [

	^self doDDLOperation: [
		self 
			execute: [self executeSQLStringNoResult: 
						(self platform createAlterColumnStatementDropNotNull: aField)]
			ifError: aBlock ]
]

{ #category : #executing }
DatabaseAccessor >> alterFieldSetNotNull: aField [	

	self 
		alterFieldSetNotNull: aField
		ifError: [ :ex | 	| msg|
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Alter column  <1s> to set not null ERROR: (<2s>) ' expandMacrosWith: aField name  with: msg).
				ex return: nil].
]

{ #category : #executing }
DatabaseAccessor >> alterFieldSetNotNull: aField ifError: aBlock [

	^self doDDLOperation: [
		self 
			execute: [self executeSQLStringNoResult: 
						(self platform createAlterColumnStatementSetNotNull: aField)]
			ifError: aBlock ]
]

{ #category : #executing }
DatabaseAccessor >> basicExecuteSQLString: aString [
	self subclassResponsibility.
]

{ #category : #executing }
DatabaseAccessor >> basicExecuteSQLString: aString bindingArray: aBindingArray [
	self subclassResponsibility.
]

{ #category : #executing }
DatabaseAccessor >> basicExecuteSQLString: aString returnResult: returnResult binding: aBindingArray doing: aBlock [
	^self subclassResponsibility
]

{ #category : #executing }
DatabaseAccessor >> basicExecuteSQLStringNoResult: aString doing: aBlock [
	^self basicExecuteSQLString: aString returnResult: false binding: nil doing: aBlock.
]

{ #category : #permissions }
DatabaseAccessor >> beReadOnly [
	self denyWrites.
]

{ #category : #transactions }
DatabaseAccessor >> beginTransaction [
	^self subclassResponsibility.
]

{ #category : #permissions }
DatabaseAccessor >> checkPermissionFor: command [
	deniedCommands isNil ifTrue: [^self].
	(deniedCommands includes: command class)
		ifTrue: [(GlorpIllegalCommand new command: command) signal].
]

{ #category : #transactions }
DatabaseAccessor >> commitTransaction [
	^self subclassResponsibility.
]

{ #category : #cursors }
DatabaseAccessor >> completedCommand: aCommand [
	"Indicate that we've completed the command. Release associated resources."
	^self.
]

{ #category : #accessing }
DatabaseAccessor >> connection [
	^connection
]

{ #category : #accessing }
DatabaseAccessor >> connection: aPlatformDatabaseConnection [
	connection := aPlatformDatabaseConnection
]

{ #category : #accessing }
DatabaseAccessor >> connectionClass [
	^self connectionClassForLogin: currentLogin
]

{ #category : #accessing }
DatabaseAccessor >> connectionClassForLogin: aLogin [
	^self subclassResponsibility.
]

{ #category : #copying }
DatabaseAccessor >> copy [

	^self shallowCopy postCopy.
]

{ #category : #executing }
DatabaseAccessor >> copyDataFromField: fromField toField: toField ifError: errorBlock [

	self
		executeInDDLOperation: [ self executeSQLStringNoResult: (self platform sqlStatementToCopyDataFromColumn: fromField to: toField )]
		ifError: errorBlock
]

{ #category : #executing }
DatabaseAccessor >> copyDataFromTable: fromTable toTable: anotherTable ifError: errorBlock [

	self
		executeInDDLOperation: [ self executeSQLStringNoResult: (self platform sqlStatementToCopyDataFromTable: fromTable to: anotherTable) ]
		ifError: errorBlock
]

{ #category : #executing }
DatabaseAccessor >> createIndex: aGlorpDatabaseIndex forTable: aGlorpDatabaseTable ifError: aBlock [
	self 
		execute:
			[self executeSQLStringNoResult:
				(self platform 
					createTableIndexStatementStringFor: aGlorpDatabaseTable
					index: aGlorpDatabaseIndex)]
		ifError: aBlock.
]

{ #category : #executing }
DatabaseAccessor >> createSequence: aDatabaseSequence ifError: aBlock [ 

	self
		executeInDDLOperation: [ self executeSQLStringNoResult: aDatabaseSequence creationString]
		ifError: aBlock
]

{ #category : #executing }
DatabaseAccessor >> createTable: aGlorpDatabaseTable ifError: aBlock [ 
	"This method should be used to create a database table from aTable"
	aGlorpDatabaseTable isImaginary ifTrue: [^self].
	self
		executeInDDLOperation: [
			self executeSQLStringNoResult: (self platform createTableStatementStringFor: aGlorpDatabaseTable)]
		ifError: aBlock
]

{ #category : #executing }
DatabaseAccessor >> createTableFKConstraints: aGLORBDatabaseTable ifError: aBlock [ 
	"This method should be used to define foreign key constraints for a database table from aTable"

	aGLORBDatabaseTable foreignKeyConstraintsForCreation
		do: [ :each | self addConstraint: each ifError: aBlock ].
]

{ #category : #executing }
DatabaseAccessor >> createTableIndexes: aGlorpDatabaseTable ifError: aBlock [
	"Create all indexes for this table"

	aGlorpDatabaseTable indexes do: 
		[:eachIndex |
		self createIndex: eachIndex forTable: aGlorpDatabaseTable ifError: aBlock].
]

{ #category : #accessing }
DatabaseAccessor >> currentLogin [
	^currentLogin
]

{ #category : #accessing }
DatabaseAccessor >> currentLogin: aLogin [ 
	currentLogin := aLogin
]

{ #category : #cursors }
DatabaseAccessor >> cursorFor: aStream [
	^GlorpCursoredStream on: aStream accessor: self.
]

{ #category : #cursors }
DatabaseAccessor >> cursorFor: answerStream command: aCommand [
	^aCommand isNil
		ifTrue: [self cursorFor: answerStream]
		ifFalse: [GlorpCursoredStream on: answerStream for: aCommand accessor: self].
]

{ #category : #accessing }
DatabaseAccessor >> deniedCommands [
	^deniedCommands.
]

{ #category : #permissions }
DatabaseAccessor >> denyCommand: aCommand [
	"Use this method, not alsoDenyCommand: when you want to override, not just add to, the current permissions state."

	self denyCommands: aCommand withAllSubclasses.
]

{ #category : #permissions }
DatabaseAccessor >> denyCommands: aCollection [
	deniedCommands := aCollection asArray.
]

{ #category : #transactions }
DatabaseAccessor >> doDDLOperation: aBlock [
	"Execute DDL SQL - something which creates/drops/modifies tables or other schema information. The main reason for this method is that some databases require a transaction, while others don't require it, and still others don't allow it. Try to do the right thing."
	
	^self platform requiresTransactionForTableOperations
		ifTrue: [self inTransactionDo: aBlock]
		ifFalse: aBlock.
]

{ #category : #executing }
DatabaseAccessor >> dropConstraint: aConstraint [
	^self 
		dropConstraint: aConstraint 
		ifError: [ :ex || msg |
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'no error message provided for top level exception'].
				self log: ('Drop constraint <1s> ERROR: (<2s>'  expandMacrosWith: aConstraint name with: msg).
				ex return: nil].
]

{ #category : #executing }
DatabaseAccessor >> dropConstraint: aConstraint ifError: aBlock [
	| dropString |
	dropString := self platform createConstraintDropStatement: aConstraint.
	dropString isEmpty ifTrue: [^self].
	self
		executeInDDLOperation: [ self executeSQLStringNoResult: dropString ]
		ifError:aBlock
]

{ #category : #executing }
DatabaseAccessor >> dropFields: aCollection [ 

	self 
		dropFields: aCollection 
		ifError: [ :ex  | 	| msg |
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Drop field ERROR: (<2s>) ' expandMacrosWith: msg).
				ex return: nil]
]

{ #category : #executing }
DatabaseAccessor >> dropFields: aCollection ifError: aBlock [

	aCollection
		do: 	[:aField | 
			self execute: [self executeSQLStringNoResult: (self platform createDropColumnStatementFor: aField)]
				ifError: aBlock ].
]

{ #category : #executing }
DatabaseAccessor >> dropForeignKeyConstraintsForTable: aTable ifError: aBlock [ 
	aTable isImaginary ifTrue: [^self].
	aTable foreignKeyConstraints do: [:each | self dropConstraint: each ifError: [ :ex | aBlock value: ex]].
]

{ #category : #executing }
DatabaseAccessor >> dropSequence: aDatabaseSequence ifAbsent: aBlock [ 
	self
		executeInDDLOperation: [ self executeSQLStringNoResult: aDatabaseSequence dropString ]
		ifError: aBlock
]

{ #category : #executing }
DatabaseAccessor >> dropSequences: anArray [
	anArray do:
		[:each |
		self
			dropSequence: each
			ifAbsent:
				[:ex | 
				self log: (ex messageText ifNil: [ex printString]).
				ex return: nil]].
]

{ #category : #executing }
DatabaseAccessor >> dropTable: aTable ifError: aBlock [ 
	aTable isImaginary ifTrue: [^self].
	self dropForeignKeyConstraintsForTable: aTable ifError: aBlock.
	self dropTableDefinition: aTable ifError: aBlock.
]

{ #category : #executing }
DatabaseAccessor >> dropTableDefinition: aTable ifError: aBlock [
	"The dropping of the primary key constraints (a singular object not a collection, despite its name) is probably not needed before dropping the table by any database platform.  If 'platform supportsConstraints' is false then it will not be done, since dropConstraint:ifError: assumes it is called on a foreign key constraint (the case in all other callers) and does nothing if the platform does not support them."

	aTable isImaginary ifTrue: [^self].
	aTable hasPrimaryKeyConstraints ifTrue: [self dropConstraint: aTable  primaryKeyConstraints ifError: [:ex | aBlock value: ex]].
	self dropTableNamed: aTable qualifiedName ifAbsent: aBlock.
]

{ #category : #executing }
DatabaseAccessor >> dropTableNamed: aString [ 
	self 
		dropTableNamed: aString 
		ifAbsent: [:ex | 	| msg|
				msg := ex messageText.
				msg isEmpty ifTrue: [msg := 'No error message provided for top level exception.'].
				Transcript cr; show: ('Drop table <1s> ERROR: (<2s>) ' expandMacrosWith: aString with: msg).
				ex return: nil]
]

{ #category : #executing }
DatabaseAccessor >> dropTableNamed: aString ifAbsent: aBlock [ 
	self doDDLOperation: [
		self 
			execute: [self executeSQLStringNoResult: (self platform createDropTableStatementFor: aString )]
			ifError: aBlock].
]

{ #category : #executing }
DatabaseAccessor >> dropTables: anArray [
	anArray do: [:eachTable |
				eachTable foreignKeyConstraints
					do: [:eachConstraint | self dropConstraint: eachConstraint]].
	anArray do: [:each |
				self dropTableDefinition: each
					ifError: [ :ex || msg |
							msg := ex messageText.
							msg isEmpty ifTrue: [msg := 'no error message provided for top level exception'].
							self log: 'ERROR : (', msg, ' )'.
							ex return: nil]].
]

{ #category : #accessing }
DatabaseAccessor >> encoding [
	"The connection is specific to the dialect;  some dialects will need to override this method."

	^connection encoding
]

{ #category : #accessing }
DatabaseAccessor >> encoding: aSymbol [
	"The platform is a Glorp databasePlatform, so its setter code is generic across all dialects.  The connection is specific to the dialect;  some dialects will need to override how its encoding is set.  In the hope that most dialects will find this works for them, and that coders porting to dialects in which it does not will benefit from seeing the walkback and knowing they have something to do, we attempt to set both at top level."

	self platform characterEncoding: aSymbol.
	connection encoding: aSymbol.
]

{ #category : #logging }
DatabaseAccessor >> endLogging [
	self logger: nil.
	self logging: false.
	self logOnly: false.
]

{ #category : #executing }
DatabaseAccessor >> errorsToCatch [
	^Dialect error.
]

{ #category : #executing }
DatabaseAccessor >> execute: aBlock [

	^self execute: aBlock ifError: [:ex | ex pass].
]

{ #category : #executing }
DatabaseAccessor >> execute: aBlock ifError: errorBlock [

	^aBlock on: self errorsToCatch do: errorBlock.
]

{ #category : #executing }
DatabaseAccessor >> executeCommand: command [
	^self executeCommand: command returnCursor: false.
]

{ #category : #executing }
DatabaseAccessor >> executeCommand: command returnCursor: aBoolean [
	^mutex
		critical:
			[| result |
			self checkPermissionFor: command.
			result := [(self useBinding and: [command useBinding])
				ifTrue: [command executeBoundIn: self]
				ifFalse: [command executeUnboundIn: self]]
				on: Dialect error
				do: [:ex | self handleError: ex for: command].
			aBoolean ifTrue: [result] ifFalse: [result upToEnd]].
]

{ #category : #executing }
DatabaseAccessor >> executeCommandBound: command [
	"By default, we don't handle binding"
	^command executeUnboundIn: self.
]

{ #category : #executing }
DatabaseAccessor >> executeCommandUnbound: aCommand [
	| cursor |
	self logCommand: aCommand sqlString bound: false.
	self logOnly ifTrue: [^self].
	cursor := self basicExecuteSQLString: aCommand sqlString.
	cursor command: aCommand.
	^cursor.
]

{ #category : #transactions }
DatabaseAccessor >> executeInDDLOperation: aBlock ifError: errorBlock [
	"Execute DDL SQL - something which creates/drops/modifies tables or other schema information. The main reason for this method is that some databases require a transaction, while others don't require it, and still others don't allow it. Try to do the right thing."

	^ self doDDLOperation: [
		self
			execute: aBlock
			ifError: errorBlock ]
]

{ #category : #executing }
DatabaseAccessor >> executeSQLString: aString [
	| result block time |
	self log: aString.
	self logOnly ifTrue: [^self].
	block := [result := (self basicExecuteSQLString: aString) upToEnd].
	time := self logging
		ifTrue: [Time millisecondsToRun: block]
		ifFalse:
			[block value.
			0].
	self logTime: time.
	^result.
]

{ #category : #executing }
DatabaseAccessor >> executeSQLString: aString binding: aBindingArray [
	| result block time |
	self log: aString.
	self logOnly ifTrue: [^self].
	block := [ 
		result := (self basicExecuteSQLString: aString binding: aBindingArray) upToEnd].
	time := self logging
		ifTrue: [Time millisecondsToRun: block]
		ifFalse:
			[block value.
			0].
	self logTime: time.
	^result.
]

{ #category : #executing }
DatabaseAccessor >> executeSQLStringNoResult: aString [
	^self
		executeSQLStringNoResult: aString
		doing: []
		forCommand: nil.
]

{ #category : #executing }
DatabaseAccessor >> executeSQLStringNoResult: aString doing: aBlock forCommand: aCommand [
	"Execute the string and discard the result. Evaluate aBlock before releasing the statement's answer stream"

	| block time |
	aCommand isNil ifTrue: [self log: aString] ifFalse: [self logCommand: aCommand bound: false].
	self logOnly ifTrue: [^self].
	block := [self basicExecuteSQLStringNoResult: aString doing: aBlock].
	time := self logging
		ifTrue: [Time millisecondsToRun: block]
		ifFalse:
			[block value.
			0].
	self logTime: time.
]

{ #category : #executing }
DatabaseAccessor >> externalDatabaseErrorSignal [

	self subclassResponsibility.
]

{ #category : #executing }
DatabaseAccessor >> handleError: exception for: command [
	"Signal a GlorpDatabase... error.  If it is handled to return true (any handler or defaultAction had better not return true in response to an error that logging in or logging out could reraise and on which it would again return true) and we have a reusable login, try to logout and in again and restart, otherwise exit."

	| errorClass error |
	errorClass := command isReadCommand
		ifTrue: [GlorpDatabaseReadError]
		ifFalse: [GlorpDatabaseWriteError].
	error := errorClass new.
	error command: command.
	error databaseError: (self innerExceptionFor: exception).
	error accessor: self.
	(error signal ~~ true or: [currentLogin isNil or: [currentLogin secure]])
		ifTrue: [exception return: nil]
		ifFalse:
			[self reset.
			self logout.
			self reLogin.
			exception restart].
]

{ #category : #transactions }
DatabaseAccessor >> inTransactionDo: aBlock [
	"Execute aBlock in a database transaction. If one is already in progress, just continue. If not, start a transaction."

	| alreadyInTransaction result |
	[ 
	alreadyInTransaction := self isInTransaction.
	alreadyInTransaction ifFalse: [self beginTransaction].
	result := aBlock numArgs = 1 ifTrue: [aBlock value: self] ifFalse: [aBlock value].
	alreadyInTransaction ifFalse: [self commitTransaction]]
		ifCurtailed:
			[alreadyInTransaction ifFalse: [self rollbackTransaction]].
	^result.
]

{ #category : #'initialize-release' }
DatabaseAccessor >> initialize [
	deniedCommands := nil.
	mutex := Semaphore forMutualExclusion.
]

{ #category : #executing }
DatabaseAccessor >> innerExceptionFor: exception [
	^exception parameter.
]

{ #category : #cursors }
DatabaseAccessor >> isCursorAtEnd: aCursor [
	"Return true if aCursor is at its end. This implementation may not work for all, but it seems like a reasonable default"

	^aCursor atEnd.
]

{ #category : #testing }
DatabaseAccessor >> isExistingTable: tableName inSchema: schemaName [
	"When the platform is SQL Server, the statement returned is of the form

SELECT count(*) FROM schema_name.INFORMATION_SCHEMA.TABLES WHERE lower(table_name) = 'tw_databaseidentifier';

If schema_name is absent, the above statement produces an error (e.g. an unableToExecuteSQLSignal in VW).  The correct and dialect-neutral fix is for this method to guard-test for owner/schema existence where used."

	| databasePlatform sqlStatement result targetSchemaName |
	databasePlatform := self currentLogin platform.
	targetSchemaName := databasePlatform supportsInformationSchema
		ifTrue: [schemaName]
		ifFalse: [''].
	databasePlatform isSQLServerPlatform ifTrue:
		[sqlStatement := databasePlatform sqlStatementToTestExistenceOfSchema: schemaName.	
		result := self executeSQLString: sqlStatement.
		result notEmpty ifTrue:
			[result first first > 0 ifFalse: [^false]]].
	sqlStatement := databasePlatform sqlStatementToTestExistenceOfTable: tableName inSchema: targetSchemaName.
	result := self executeSQLString: sqlStatement.
	^result notEmpty
		ifTrue: [result first first > 0]
		ifFalse: [false]
]

{ #category : #transactions }
DatabaseAccessor >> isInTransaction [
	^self subclassResponsibility.
]

{ #category : #login }
DatabaseAccessor >> isLoggedIn [
	^self subclassResponsibility
]

{ #category : #'queries metadata' }
DatabaseAccessor >> listTableNamesInSchemaNamed: schemaString [

	| databasePlatform sqlStatement result |
	databasePlatform := self currentLogin platform.
	sqlStatement := databasePlatform sqlStatementToListTablesInSchema: schemaString.
	result := self executeSQLString: sqlStatement.
	^result isEmpty
		ifTrue: [#()]
		ifFalse: [result collect: [:ea| ea first]]
]

{ #category : #logging }
DatabaseAccessor >> log: aStringOrBlock [
	"Log an arbitrary string"
	| string |
	self logging ifFalse: [^self].
	string := aStringOrBlock isString
		ifTrue: [aStringOrBlock]
		ifFalse: [aStringOrBlock value].
	self logString: string.
]

{ #category : #logging }
DatabaseAccessor >> logCommand: aDatabaseCommand bound: aBoolean [

	"Log the execution of a command"
	| string |
	self changed: #command: with: aDatabaseCommand.
	self logging ifFalse: [^self].
	string := aDatabaseCommand sqlString.
 	aBoolean ifTrue: [string := string , '  ' , aDatabaseCommand bindings printString].
	self logString: string.
]

{ #category : #logging }
DatabaseAccessor >> logError: anErrorObject [ 
	self log: anErrorObject printString
]

{ #category : #logging }
DatabaseAccessor >> logOnly [

	logOnly ifNil: [logOnly := false].
	^logOnly and: [self logging]
]

{ #category : #logging }
DatabaseAccessor >> logOnly: aBoolean [

	logOnly := aBoolean
]

{ #category : #logging }
DatabaseAccessor >> logOnlyOn: aTextCollector [
	"logOnly implies you're logging and that you have a logger, so combine setting them into a single method (inverse is #endLogging)."

	self logger: aTextCollector.
	self logging: true.
	self logOnly: true.
]

{ #category : #private }
DatabaseAccessor >> logString: aString [

	| stringToLog |
	stringToLog := aString size > 4000 
		ifTrue: [aString copyFrom: 1 to: 4000]
		ifFalse: [aString].
	self logger
		cr;
		show: stringToLog.
	(self logOnly and: [stringToLog notEmpty and: [stringToLog last ~= $;]])
		ifTrue: [self logger show: ';'].
]

{ #category : #logging }
DatabaseAccessor >> logTime: aTimeOrBlock [
	| time |
	self logOnly ifTrue: [^self].
	self changed: #time: with: aTimeOrBlock.
	self logging ifFalse: [^self].
	time := (Dialect isBlock: aTimeOrBlock)
		ifTrue: [aTimeOrBlock value]
		ifFalse: [aTimeOrBlock].
	self logString: '(' , (time / 1000.0) printString , ' s)'.
]

{ #category : #logging }
DatabaseAccessor >> logger [

	^logger ifNil: [Transcript]
]

{ #category : #logging }
DatabaseAccessor >> logger: aTextCollector [

	logger := aTextCollector
]

{ #category : #logging }
DatabaseAccessor >> logging [
	logging isNil ifTrue: [^self class loggingEnabled].
	^logging.
]

{ #category : #logging }
DatabaseAccessor >> logging: aBoolean [ 
	logging := aBoolean
]

{ #category : #login }
DatabaseAccessor >> login [
	"In 8.1 and earlier, this return nil.  It now returns self, as #loginIfError: does."

	self loginIfError: [:ex | ex pass].
]

{ #category : #login }
DatabaseAccessor >> loginIfError: aBlock [

	self subclassResponsibility.
]

{ #category : #login }
DatabaseAccessor >> logout [
	^self subclassResponsibility.
]

{ #category : #notification }
DatabaseAccessor >> myDependents [
	^dependents.
]

{ #category : #notification }
DatabaseAccessor >> myDependents: aCollection [
	dependents := aCollection.
]

{ #category : #accessing }
DatabaseAccessor >> numberOfPreparedStatements [
	^0
]

{ #category : #accessing }
DatabaseAccessor >> platform [
	^currentLogin database.
]

{ #category : #executing }
DatabaseAccessor >> populateField: aDatabaseField with: aValue ifError: errorBlock [

	self
		executeInDDLOperation: [
			self executeSQLStringNoResult: (self platform sqlStatementToPopulateColumn: aDatabaseField with: aValue) ]
		ifError: errorBlock
]

{ #category : #copying }
DatabaseAccessor >> postCopy [
]

{ #category : #login }
DatabaseAccessor >> reLogin [
	"Attempt to re-login to a database that's not responding. Give it a maximum of 5 attempts."

	| attempts |
	attempts := 0.
	[attempts < 5 and: [self isLoggedIn not]] whileTrue: [
		attempts := attempts + 1.
		self loginIfError: [:ex | nil]].
]

{ #category : #executing }
DatabaseAccessor >> renameField: aDatabaseField to: nameString ifError: errorBlock [

	self
		executeInDDLOperation: [ self executeSQLStringNoResult: (self platform sqlStatementToRenameColumn: aDatabaseField to: nameString) ]
		ifError: errorBlock
]

{ #category : #executing }
DatabaseAccessor >> renameTable: aDatabaseTable to: newTableName inPlatform: aDatabasePlatform ifError: errorBlock [

	| sqlStatement |
	sqlStatement := aDatabasePlatform sqlStatementToRenameTable: aDatabaseTable to: newTableName.	
	self
		executeInDDLOperation: [ self executeSQLStringNoResult: sqlStatement ]
		ifError: errorBlock
]

{ #category : #'initialize-release' }
DatabaseAccessor >> reset [
	"Don't reset the permissions, because the replicator wants to reset sessions without changing their characteristics"
"	self permitEverything."
]

{ #category : #permissions }
DatabaseAccessor >> resetPermissions [
	self permitEverything.
]

{ #category : #accessing }
DatabaseAccessor >> returnRowCount: aBoolean [
	^self.
]

{ #category : #accessing }
DatabaseAccessor >> reusePreparedStatements [
	^reusePreparedStatements and: [self useBinding]
]

{ #category : #accessing }
DatabaseAccessor >> reusePreparedStatements: aBoolean [
	reusePreparedStatements := aBoolean.
]

{ #category : #transactions }
DatabaseAccessor >> rollbackTransaction [
	^self subclassResponsibility.
]

{ #category : #executing }
DatabaseAccessor >> rowCount [
	^self subclassResponsibility
]

{ #category : #accessing }
DatabaseAccessor >> schema [

	^ self currentLogin schema
]

{ #category : #login }
DatabaseAccessor >> showDialog: aString [

	self subclassResponsibility.
]

{ #category : #cursors }
DatabaseAccessor >> upToEndOfResultSet: aGlorpCursoredStream [
	"The statement may have multiple result sets.  If the caller sends #upToEnd, the aggressive releasing of the cursor in #atEnd will lose any remaining result sets.  We therefore read the current result set and advance the underlying cursor to the next result set, releasing the Glorp cursor if we're called on the last result set.  (N.B. 'the next result set' does not necessarily mean the return of the next statement;  in a sequence of statements, some may return result sets while others return #noAnswerStream and these will be skipped)."

	^self subclassResponsibility
]

{ #category : #accessing }
DatabaseAccessor >> useBinding [
	^self platform useBinding.
]
