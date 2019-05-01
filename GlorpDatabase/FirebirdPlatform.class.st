"
This is a Glorp platform for the InterBase and Firebird databases.  It is currently subclassed from Ocelot because both claim to be highly standard-compliant.  It would probably be better if both inherited from some sort of abstract SQL92Platform.

Firebird/InterBase supports binding in all statements (indeed its EXDI appears to require it for blobs) and can also reuse SELECT statements, but reuse of RowBasedCommands (INSERT, DELETE, UPDATE) for blobs is unreliable although binding of such statements is essential.  Set
	reusePreparedStatements: false
on Logins that have an instance of this class as their platform.

"
Class {
	#name : #FirebirdPlatform,
	#superclass : #OcelotPlatform,
	#category : #GlorpDatabase
}

{ #category : #accessing }
FirebirdPlatform class >> kind [
	^'Firebird'
]

{ #category : #constants }
FirebirdPlatform >> areSequencesExplicitlyCreated [
	^true
]

{ #category : #binding }
FirebirdPlatform >> bindingsForGroupWritingFor: aCommand [
	"Return the bindings array for a group write. This can be in different formats, depending on the database and perhaps the mechanism in place."
	^aCommand batchStatementBindings.
]

{ #category : #conversion }
FirebirdPlatform >> blobDataToStreamConverter [
	^DelegatingDatabaseConverter
		named: #blobDataToStream
		hostedBy: self
		fromStToDb: #convertBlobData:for:
		fromDbToSt: #nullConversion:for:.
]

{ #category : #types }
FirebirdPlatform >> clob [

	^self typeNamed: #clob ifAbsentPut: [GlorpClobType new typeString: 'blob sub_type text'].
]

{ #category : #conversion }
FirebirdPlatform >> convertBlobData: aData for: aType [
	"From standard Store getBlobData called in writeSession;  Firebird seems to need it.  Glorp needs to think that two such streams on the same data are equal."

	^EqualOnContentReadStream on: aData
]

{ #category : #sequences }
FirebirdPlatform >> databaseSequenceClass [
	^FirebirdSequence.
]

{ #category : #functions }
FirebirdPlatform >> initializeFunctions [
	"Firebird 2.5 and later supports the ANSI SQL 'SIMILAR TO' form of regex, in which the % and _ of SQL's LIKE predicate replace the corresponding * and ? of regex."

	super initializeFunctions.
	functions at: #similarTo: put: (InfixFunction named: 'SIMILAR TO').
]

{ #category : #constants }
FirebirdPlatform >> initializeReservedWords [
	reservedWords := Set new.
	reservedWords 
		add: 'type';
		add: 'value';
		add: 'password';
		add: 'unique';
		add: 'date';
		add: 'current';
		add: 'order';
		add: 'active';
		add: 'action';
		add: 'database';
		add: 'table';
		add: 'timestamp';
		add: 'position'.
]

{ #category : #testing }
FirebirdPlatform >> isODBCPlatform [
	"IBEXDI defines an EXDI connection class, not an ODBC one."
 
	^false
]

{ #category : #constants }
FirebirdPlatform >> maximumLengthOfColumnName [
	"^<Integer> I return the maximum length of a column name.  (I am not sent at present;  I am here so that if I and #maximumLengthOfTableName (which is sent) should ever differ on some database platform, I can be used in revised truncation logic.)"

	^31
]

{ #category : #constants }
FirebirdPlatform >> maximumLengthOfTableName [
	"^<Integer> I return the max. length of a table name"

	^31
]

{ #category : #testing }
FirebirdPlatform >> measuresStringFieldWidthsInBytes [
	^true
]

{ #category : #'services tables' }
FirebirdPlatform >> printSqlStatementToListTablesInSchema: schemaString on: aStream [
	"Firebird uses the same table for tables, views and possibly other stuff.  It does not support schemas within a database "

	aStream
		nextPutAll: 'SELECT rdb$relation_name as table_name FROM rdb$relations ';
		nextPutAll: 'WHERE rdb$view_blr is null and (rdb$system_flag is null or rdb$system_flag = 0);'
]

{ #category : #'services tables' }
FirebirdPlatform >> printSqlStatementToTestExistenceOfTable: tableName inSchema: schemaString on: aStream [
	"Firebird uses the same table for tables, views and possibly other stuff, does NOT support schemas. 
	As currently written, this query will not test for existence of views OR system tables."

	aStream
		nextPutAll: 'SELECT count(*) FROM rdb$relations ';
		nextPutAll: 'WHERE rdb$relation_name = ';
		nextPut: $';
		nextPutAll: tableName;
		nextPut: $';
		nextPutAll: ' AND rdb$view_blr is null AND (rdb$system_flag is null OR rdb$system_flag = 0);'
]

{ #category : #constants }
FirebirdPlatform >> requiresTransactionForTableOperations [
	"Return true if we need a transaction in order to do table creation, deletion, and so forth. Some databases require it. Others don't like it"
	^false.
]

{ #category : #testing }
FirebirdPlatform >> reusePreparedStatements [
	"Firebird/InterBase supports binding of parameters (i.e. instead of printing them as strings within the SQL statement);  indeed, when handling Blobs, the current IBEXDI implementation demands it.  However if RowBasedCommands (INSERT, DELETE, UPDATE) attempt to reuse bound statements, there are failures;  every 79th or 358th or whatever reuse of such a statement returns bad data.  (SELECT statements are fine.)  This was hidden when failure to release the GlorpCursor in RowBasedCommands left statements busy, so unreusable;  the fix (first made in Glorp 0.3.181) revealed it.  We return false here so that reusePreparedStatements is initialized to false for any accessor whose login uses this platform."

	^false

"To study further:  is it that prepared-statement-signature-matching needs to distingush the types of the contents of an EqualOnContentsReadStream, or does the database need a bug fix, or does the IBEXDI need to handle Blobs differently?  If the problems with RowBaseCommands cannot be resolved, can we / should we distinguish between reusing them and reusing SELECT statements?"
]

{ #category : #types }
FirebirdPlatform >> sequence [

	^self typeNamed: #sequence ifAbsentPut: [GlorpSerialType new typeString: (self integer typeString)].
]

{ #category : #testing }
FirebirdPlatform >> supportsBinding [
	"Firebird/InterBase supports binding in all statements (indeed its EXDI appears to require it for blobs) and can also reuse SELECT statements, but reuse of RowBasedCommands (INSERT, DELETE, UPDATE) for Blobs is unreliable although binding of such statements is essential (see my #reusePreparedStatementsIfSupported method comment)."

	^true
]

{ #category : #constants }
FirebirdPlatform >> supportsMillisecondsInTimes [
	^false.
]

{ #category : #accessing }
FirebirdPlatform >> vwEXDIConnectionClass [
	^'InterBaseConnection' asQualifiedReference valueIfUndefinedLoadFrom: 'IBEXDI'
]
