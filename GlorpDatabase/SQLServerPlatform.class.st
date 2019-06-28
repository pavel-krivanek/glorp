"
This is a platform for the Microsoft SQL Server database.  SQLServer uses type Bit (values 0 and 1) to represent booleans in the database.

Instance Variables:
	canRecurse	<Boolean>	is recursive SQL supported
	supportsGroupWritingValues	<Boolean>	can a single INSERT statement be followed by multiple VALUES
	supportsUnboundRowCount	<Boolean>	can unbound SQL INSERT/UPDATE return the number of rows actually written/updated (this matters when using lock keys; to tell whether lock keys clashed, we must be able to tell that an update did not affect all the rows expected
"
Class {
	#name : #SQLServerPlatform,
	#superclass : #DatabasePlatform,
	#instVars : [
		'supportsGroupWritingValues',
		'supportsUnboundRowCount',
		'canRecurse'
	],
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #accessing }
SQLServerPlatform class >> kind [
	^'Microsoft SQL Server'
]

{ #category : #constants }
SQLServerPlatform class >> reservedWords [

	^#('@@identity' 'add' 'all' 'alter' 'and' 'any' 'as' 'asc' 'authorization' 'avg' 'backup' 'begin' 'between' 'break' 'browse' 'bulk' 'by' 'cascade' 'case' 'check' 'checkpoint' 'close' 'clustered' 'coalesce' 'collate' 'column' 'commit' 'compute' 'constraint' 'contains' 'containstable' 'continue' 'convert' 'count' 'create' 'cross' 'current' 'current_date' 'current_time' 'current_timestamp' 'current_user' 'cursor' 'database' 'databasepassword' 'dateadd' 'datediff' 'datename' 'datepart' 'dbcc' 'deallocate' 'declare' 'default' 'delete' 'deny' 'desc' 'disk' 'distinct' 'distributed' 'double' 'drop' 'dump' 'else' 'encryption' 'end' 'errlvl' 'escape' 'except' 'exec' 'execute' 'exists' 'exit' 'expression' 'fetch' 'file' 'fillfactor' 'for' 'foreign' 'freetext' 'freetexttable' 'from' 'full' 'function' 'goto' 'grant' 'group' 'having' 'holdlock' 'identity' 'identity_insert' 'identitycol' 'if' 'in' 'index' 'inner' 'insert' 'intersect' 'into' 'is' 'join' 'key' 'kill' 'left' 'like' 'lineno' 'load' 'max' 'min' 'national' 'nocheck' 'nonclustered' 'not' 'null' 'nullif' 'of' 'off' 'offsets' 'on' 'open' 'opendatasource' 'openquery' 'openrowset' 'openxml' 'option' 'or' 'order' 'outer' 'over' 'percent' 'plan' 'precision' 'primary' 'print' 'proc' 'procedure' 'public' 'raiserror' 'read' 'readtext' 'reconfigure' 'references' 'replication' 'restore' 'restrict' 'return' 'revoke' 'right' 'rollback' 'rowcount' 'rowguidcol' 'rule' 'save' 'schema' 'select' 'session_user' 'set' 'setuser' 'shutdown' 'some' 'statistics' 'sum' 'system_user' 'table' 'textsize' 'then' 'to' 'top' 'tran' 'transaction' 'trigger' 'truncate' 'tsequal' 'union' 'unique' 'update' 'updatetext' 'use' 'user' 'values' 'varying' 'view' 'waitfor' 'when' 'where' 'while' 'with' 'writetext')
		asSet
]

{ #category : #'VisualWorks metadata' }
SQLServerPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #constants }
SQLServerPlatform >> areSequencesExplicitlyCreated [

^false
]

{ #category : #binding }
SQLServerPlatform >> bindingsForGroupWritingFor: aCommand [
	^aCommand arrayBindings
]

{ #category : #types }
SQLServerPlatform >> bit [
	"An integer whose values can only be 1 or 0.  No case for this type unless something like INSERT 0 INTO bitcol can be parsed by SQLServer."

	^self typeNamed: #bit ifAbsentPut: [GlorpIntegerType new typeString: 'bit']
]

{ #category : #types }
SQLServerPlatform >> blob [

	^self typeNamed: #blob ifAbsentPut: [GlorpBlobType new typeString: 'varbinary(max)'; queryType: (self varbinary)].
]

{ #category : #types }
SQLServerPlatform >> boolean [
	"A boolean can be read from a type BIT column because ODBCEXDI knows the type of the column it reads _from_ and does the conversion.  But it cannot tell the type of the column it is writing _to_, unlike Glorp, so Glorp must do the conversion INSERT CONVERT(BIT, 0) INTO columnOfTypeBIT.  See my #printBoolean:for: and #booleanToBooleanConverter for details."

	^self typeNamed: #boolean ifAbsentPut: [GlorpBooleanType new typeString: 'bit']
]

{ #category : #testing }
SQLServerPlatform >> canRecurse [
	^canRecurse
]

{ #category : #constants }
SQLServerPlatform >> capitalWritingOfTableName [
	^false
]

{ #category : #types }
SQLServerPlatform >> char [
	^self typeNamed: #char ifAbsentPut: [GlorpCharType new].
]

{ #category : #'conversion-strings' }
SQLServerPlatform >> charactersThatNeedEscaping [
	"There seem to be all kind of contradictory bits of information about what sql server does/requires for escaped characters, all of which differ from standard sql. Empirically the only thing that requires escaping appears to be single quote"
	^#($' ).
]

{ #category : #types }
SQLServerPlatform >> clob [

	^self typeNamed: #clob ifAbsentPut: [GlorpClobType new typeString: 'varchar(max)'].
]

{ #category : #'database-specific' }
SQLServerPlatform >> compoundOperationFor: aSymbol [
	"Return the platform specific version of a compound statement symbol"
	aSymbol == #INTERSECT ifTrue: [^'WHERE EXISTS'].
	aSymbol == #MINUS ifTrue: [^'WHERE NOT EXISTS'].
	^aSymbol.
]

{ #category : #'conversion-boolean' }
SQLServerPlatform >> convertBooleanToDBBoolean: aBoolean for: aType [
	"I use the bivalued type BIT to hold booleans."

	aBoolean isNil ifTrue: [^nil].	"Is this nil-check needed?  I believe yes it is."
	^aBoolean ifTrue: [1] ifFalse: [0]

"SQLServer also accepts TRUE' and 'FALSE' but it is simpler to use 1 and 0"
]

{ #category : #'conversion-boolean' }
SQLServerPlatform >> convertDBBooleanToBoolean: aBit for: aType [
	"I map database type BIT (values 1 and 0) to image type boolean (values true and false).  ODBCEXDI knows the source is a BIT column type, and has already converted to the bit to a Boolean."

	aBit isNil ifTrue: [^nil].	
	^aBit "= 1"
]

{ #category : #'services columns' }
SQLServerPlatform >> createAlterColumnStatement: aField newType: aType usingExpression: expression [

	| sqlStatementStream |
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
		nextPutAll:  'ALTER TABLE';
		space.
	self printDDLTableNameFor: aField table on: sqlStatementStream.

	sqlStatementStream
		nextPutAll:  ' ALTER COLUMN';
		space;
		nextPutAll: (self nameForColumn: aField name);
		space;
		nextPutAll: aType typeString.
	expression ifNotNil: [ sqlStatementStream nextPutAll: ' USING ', expression ].

	^sqlStatementStream contents
]

{ #category : #'services columns' }
SQLServerPlatform >> createAlterColumnStatement: aField setDefault: anObject [
	| sqlStatementStream |
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
		nextPutAll:  'ALTER TABLE';
		space.
	self printDDLTableNameFor: aField table on: sqlStatementStream.
	sqlStatementStream
		nextPutAll:  ' ALTER COLUMN';
		space;
		nextPutAll: (self nameForColumn: aField name);
		space;
		nextPutAll:  'DEFAULT';
		space.
	anObject printOn: sqlStatementStream.
	sqlStatementStream
		space;
		nextPutAll:  'WITH VALUES'.
	^sqlStatementStream contents
]

{ #category : #'services columns' }
SQLServerPlatform >> createAlterColumnStatementDropDefault: aField [
	| sqlStatementStream |
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
		nextPutAll:  'ALTER TABLE';
		space.
		self printDDLTableNameFor: aField table on: sqlStatementStream.

	sqlStatementStream
		nextPutAll:  ' ALTER COLUMN';
		space;
		nextPutAll: (self nameForColumn: aField name);
		space;
		nextPutAll:  'DEFAULT NULL'.

	^sqlStatementStream contents
]

{ #category : #'services columns' }
SQLServerPlatform >> createAlterColumnStatementDropNotNull: aField [
	| sqlStatementStream |
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
		nextPutAll:  'ALTER TABLE';
		space.
		self printDDLTableNameFor: aField table on: sqlStatementStream.

	sqlStatementStream
		nextPutAll:  ' ALTER COLUMN';
		space;
		nextPutAll: (self nameForColumn: aField name);
		space;
		nextPutAll: aField type typeString;
		space;
		nextPutAll:  'NULL'.

	
	^sqlStatementStream contents
]

{ #category : #'services columns' }
SQLServerPlatform >> createAlterColumnStatementSetNotNull: aField [
	| sqlStatementStream |
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
		nextPutAll:  'ALTER TABLE';
		space.
		self printDDLTableNameFor: aField table on: sqlStatementStream.

	sqlStatementStream
		nextPutAll:  ' ALTER COLUMN';
		space;
		nextPutAll: (self nameForColumn: aField name);
		space;
		nextPutAll: aField type typeString;
		space;
		nextPutAll:  self sqlTextForNOTNULLAttributeConstraint.

	
	^sqlStatementStream contents
]

{ #category : #'services constraints' }
SQLServerPlatform >> createConstraintAddStatement: aConstraint [
	| sqlStatementStream strings |
	aConstraint shouldCreateInDatabase ifFalse: [^''].
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
		nextPutAll: 'ALTER TABLE';
		space.
	self printDDLTableNameFor: aConstraint table on: sqlStatementStream.
	strings := aConstraint creationStringFor: self.
	sqlStatementStream nextPutAll: ' ADD ' , strings first.
	(strings allButFirst: 1) do:
		[:each |
		sqlStatementStream
			nextPut: $,;
			nextPutAll: each].
	^sqlStatementStream contents
]

{ #category : #'services constraints' }
SQLServerPlatform >> createConstraintDropStatement: aConstraint [
	"On SQLServerPlatform, if aConstraint is a primary key constraint then there will also be a unique constraint."

	| nonPkConstraintDropString |
	nonPkConstraintDropString := super createConstraintDropStatement: aConstraint.
	nonPkConstraintDropString isEmpty ifTrue: [^nonPkConstraintDropString].
	"If it's not a primary key, we're done."
	aConstraint isPrimaryKeyConstraint ifFalse: [^nonPkConstraintDropString].
	^(String new: 32) writeStream
		nextPutAll: nonPkConstraintDropString;
		nextPutAll: ', CONSTRAINT ';
		nextPutAll: aConstraint table name;
		nextPutAll: '_UNIQ';
		contents
]

{ #category : #sequences }
SQLServerPlatform >> databaseSequenceClass [
	"My AccessPlatform subclass has a hardcoded check in StoreDescriptorSystem>>sequenceFor: to ignore this method in favour of calling #justSelectTheMaximumCurrentValueAndAddOneSequenceFor: for AccessPlatform.  Can we retire that?"

	^SQLServerSequence
]

{ #category : #types }
SQLServerPlatform >> date [
	"SQL Server does not compare a timestamp that's cast to a date as being equal to a date, which is the behaviour we expect. Its dates are really timestamps internally, so just treat date and timestamp as the same."
	^self timestamp.
]

{ #category : #'conversion-times' }
SQLServerPlatform >> dateConverter [
	"SQL server doesn't have plain dates, and doesn't accept them"
	^DelegatingDatabaseConverter
		named: #date
		hostedBy: self
		fromStToDb: #dateToTimestampConversion:for:
		fromDbToSt: #readDate:for:.	"#printDate:for:"
]

{ #category : #'conversion-times' }
SQLServerPlatform >> dateToTimestampConversion: aDate for: aType [
	aDate isNil ifTrue: [^aDate].
	^aDate asTimestamp.
]

{ #category : #types }
SQLServerPlatform >> decimal [
	^self numeric.
]

{ #category : #types }
SQLServerPlatform >> double [
	^self float.
]

{ #category : #'conversion-strings' }
SQLServerPlatform >> escapeFor: aCharacter [
	^String with: $' with: aCharacter.
"	^'\', (aCharacter asInteger printStringRadix: 16)."
]

{ #category : #'exdi specific' }
SQLServerPlatform >> exdiTypeForDate [
	^#Timestamp
]

{ #category : #types }
SQLServerPlatform >> float [

	^self typeNamed: #float ifAbsentPut: [GlorpMSSQLFloatType new].
]

{ #category : #types }
SQLServerPlatform >> float4 [
	^self float.
]

{ #category : #types }
SQLServerPlatform >> float8 [
	^self float.
]

{ #category : #'initialize-release' }
SQLServerPlatform >> initialize [
	"SQL Server began supporting group writing with the VALUES clause in version 10.0, and recursion in version 10.5.  For safety, we initialize to false, resetting in postLoginInitializeFromAccessor:."

	super initialize.
	canRecurse := false.
	supportsGroupWritingValues := false.
]

{ #category : #functions }
SQLServerPlatform >> initializeFunctions [
	| baseExists dbSpecificExists selectList baseNotExists dbSpecificNotExists |
	super initializeFunctions.
	functions
		at: #, put: (InfixFunction named: '+');
		at: #copyFrom:to: put: (SubstringFunction named: 'SUBSTRING');
		at: #objectId put: (PrefixFunction named: 'OBJECT_ID');
		at: #columnPropertySchema:property: put: ((PrefixFunction named: 'COLUMNPROPERTY') type: self integer);
		"SQLServer does not support TO_CHAR, but a cast to a large varchar has the same effect."
		at: #toChar: put: ((Cast named: 'CAST') separator: 'AS'; arguments: (Array with: (self varchar: 2048)));
		at: #convertTo: put: ((PrefixFunction named: 'CONVERT')); "CONVERT(toType, aThing)"
		at: #prepend: put: (ReversingFunction named: '+').

	"Like Oracle, SQL Server doesn't allow functions like EXISTS in a field list, but will allow a select there as an argument to a function, such as CASE, so print it that way if we're in the select list."

	baseExists := functions at: #exists:.
	dbSpecificExists := DualRoleFunction new.
	dbSpecificExists function: '#exists:'.
	dbSpecificExists whereClauseVersion: baseExists.
	selectList := Case new argumentTypes: (Array with: (self varchar: 1) with: self boolean with: self boolean).
	selectList argumentModifierBlock:	"the argument 'x' synchronises with 'x' at the end of #existenceCheck:as:"
		[:function :args |
		function base: args first.
		Array with: 'x' with: true with: false].
	dbSpecificExists selectListVersion: selectList.
	dbSpecificExists type: self boolean.
	functions at: #exists: put: dbSpecificExists.

	"And similarly NOT EXISTS"
	baseNotExists := functions at: #notExists:.
	dbSpecificNotExists := DualRoleFunction new.
	dbSpecificNotExists function: '#notExists:'.
	dbSpecificNotExists whereClauseVersion: baseNotExists.
	selectList := Case new argumentTypes: (Array with: (self varchar: 1) with: self boolean with: self boolean).
	selectList argumentModifierBlock:	"the argument 'x' synchronises with 'x' at the end of #existenceCheck:as:"
		[:function :args |
		function base: args first.
		Array with: 'x' with: false with: true].
	dbSpecificNotExists selectListVersion: selectList.
	dbSpecificNotExists type: self boolean.
	functions at: #notExists: put: dbSpecificNotExists.
	"Overwrite existing LENGTH() function as LEN()."
	functions at: #length put: ((PrefixFunction named: 'LEN') type: self integer).
]

{ #category : #constants }
SQLServerPlatform >> initializeReservedWords [
	super initializeReservedWords.
	reservedWords add: 'key'.
]

{ #category : #commands }
SQLServerPlatform >> insertCommandForRows: aCollectionOfDatabaseRows binding: aBoolean session: aSession [
	"I can group ;-separated INSERT statements or (if I am new enough - version 10 or later) ,-separated values following a single INSERT statement.  When bound, the same applies but I can also bind an array of values to a single INSERT statement. As array binding is fastest, use an array of values when bound, a sequence of values when unbound.  I answer true to usesIdentityColumns;  if I am writing to a serial type (an identity column), the server will assign the value(s) which I retrieve in the same round-trip (when the round trip has multiple rows, retrieving assigned values in the same round trip is the only way I can retrieve them)."

	^(aBoolean or: [self supportsGroupWritingValues])
		ifTrue: [InsertSelectRowsCommand
				forRows: aCollectionOfDatabaseRows
				useBinding: aBoolean
				session: aSession
				ifNoIdentityColumn: InsertMultiValuesCommand]
		ifFalse: [InsertSelectRowCommand
				forRows: aCollectionOfDatabaseRows
				useBinding: aBoolean
				session: aSession
				ifNoIdentityColumn: InsertCommand]
]

{ #category : #types }
SQLServerPlatform >> int [
	^self integer.
]

{ #category : #types }
SQLServerPlatform >> int2 [
	^self smallint.
]

{ #category : #types }
SQLServerPlatform >> int4 [

	^self integer.
]

{ #category : #types }
SQLServerPlatform >> int8 [

	^self numeric.
]

{ #category : #types }
SQLServerPlatform >> integer [

	^self typeNamed: #integer ifAbsentPut: [GlorpIntegerType new typeString: 'int'].
]

{ #category : #testing }
SQLServerPlatform >> isODBCPlatform [

	^true
]

{ #category : #testing }
SQLServerPlatform >> isSQLServerPlatform [

	^true
]

{ #category : #types }
SQLServerPlatform >> maxVarCharSize [
	"The maximum value of n allowed in an SQLServer declaration varchar(n) is 8000."

	^8000

"SQLServer also allows varchar(max), indicating that the maximum storage size is 2147483647 (2^31-1 bytes , i.e. 2 GB).  For now, we restrict to the numerical form used by Glorp;  support for varchar(max) will be added in Glorp 9.0."
]

{ #category : #constants }
SQLServerPlatform >> maximumLengthOfColumnName [
	"^<Integer> I return the maximum length of a column name.  (I am not sent at present;  I am here so that if I and #maximumLengthOfTableName (which is sent) should ever differ on some database platform, I can be used in revised truncation logic.)"

	^128
]

{ #category : #constants }
SQLServerPlatform >> maximumLengthOfTableName [
	"^<Integer> I return the max. length of a table name"

	^128
]

{ #category : #binding }
SQLServerPlatform >> maximumSizeToGroupWriteFor: aRowBasedCommand [
	^250 min: (super maximumSizeToGroupWriteFor: aRowBasedCommand)
]

{ #category : #types }
SQLServerPlatform >> nchar [
	^self typeNamed: #nchar ifAbsentPut: [GlorpCharType new typeString: 'nchar']
]

{ #category : #types }
SQLServerPlatform >> nclob [

	^self typeNamed: #nclob ifAbsentPut: [GlorpClobType new typeString: 'nvarchar(max)'].
]

{ #category : #types }
SQLServerPlatform >> ntext [
	^self typeNamed: #ntext ifAbsentPut: [GlorpClobType new typeString: 'ntext']
]

{ #category : #types }
SQLServerPlatform >> numeric [
	^self typeNamed: #numeric ifAbsentPut: [GlorpNumericType new].
]

{ #category : #types }
SQLServerPlatform >> nvarchar [
	^self typeNamed: #nvarchar ifAbsentPut: [GlorpNVarCharType new typeString: 'nvarchar'].
]

{ #category : #login }
SQLServerPlatform >> postLoginInitializeFromAccessor: aDatabaseAccessor [
	"SQL Server began supporting group writing with the VALUES clause in version 10.0, and recursion in version 10.5.  We began supporting ODBC 3.0 in VisualWorks 8.2.1."

	| dbmsVersion dbAccessorConnection |
	dbAccessorConnection := aDatabaseAccessor connection.
	dbmsVersion := dbAccessorConnection dbmsVersion tokensBasedOn: $..
	supportsGroupWritingValues := dbmsVersion first asNumber > 9.
	supportsUnboundRowCount := dbAccessorConnection odbcVersion > 2.
	canRecurse := self isVersion: #(10 5) notNewerThan: dbmsVersion	"10.5 is 2008 R2"
]

{ #category : #'conversion-strings' }
SQLServerPlatform >> printBlob: aByteArray on: aStream for: aType [
	aByteArray isNil ifTrue: [^aStream nextPutAll: 'NULL'].
	aStream nextPutAll: '0x'.
	aByteArray do: [:each |
		each printOn: aStream paddedWith: $0 to: 2 base: 16].
]

{ #category : #'conversion-boolean' }
SQLServerPlatform >> printBoolean: aBoolean for: aType [
	"If the platform is MS SQL Server, a boolean object in a SELECT needs to be converted to  BIT type, since T, Y, or true make SQLServer complain."
	
	| string |
	aBoolean isNil ifTrue: [^'NULL'].
	"We may be getting passed something that's already 1 or 0, or something else instead of a boolean. That probably shouldn't be happening, but let's handle it gracefully. We define gracefully to mean 1 is true, and everything else is false"
	string := (aBoolean == 1 or: [aBoolean = true]) 
		ifTrue: ['1'] 
		ifFalse: ['0'].
	^'CONVERT( BIT, ' , string , ' )'.

"SQLServer also accepts CONVERT(BIT, 'TRUE')"
]

{ #category : #'conversion-times' }
SQLServerPlatform >> printDate: aDate for: aType [
	"Print a date (or timestamp) as yyyy-mm-dd"
	| stream |
	aDate isNil ifTrue: [^'NULL'].
	stream := WriteStream on: String new.
	stream nextPutAll: '{ d '''.
	self
		printDate: aDate
		isoFormatOn: stream.
	stream nextPutAll: ''' }'.
	^stream contents.
]

{ #category : #'database-specific' }
SQLServerPlatform >> printPreLimit: anInteger on: aCommand [
	aCommand
		nextPutAll: ' TOP '.
	anInteger printOn: aCommand.
	aCommand nextPutAll: ' '.
]

{ #category : #'database-specific' }
SQLServerPlatform >> printReturningFieldsOn: aCommand [
	"Return current field value from an UPDATE statement, e.g.
		UPDATE my_able SET field = field + 10 OUTPUT INSERTED.field WHERE id=2
returns the post-update (incremented by 10) value of field."

	aCommand nextPutAll: ' OUTPUT '.
	GlorpHelper
		do: [:nextField | aCommand nextPutAll: 'INSERTED.', nextField name]
		for: aCommand relativeFields
		separatedBy: [aCommand nextPut: $,; space].
]

{ #category : #'services tables' }
SQLServerPlatform >> printSqlStatementToListTablesInSchema: schemaString on: aStream [
	"Not standardized"

	| schema |
	self usesInformationSchema
		ifFalse: [^self subclassResponsibility].

	schema := (schemaString isNil or: [schemaString isEmpty])
		ifTrue: ['']
		ifFalse: [schemaString, '.'].
	aStream
		nextPutAll: 'SELECT TABLE_NAME FROM ' ;
		nextPutAll: schema;
		nextPutAll: 'INFORMATION_SCHEMA.TABLES ';
		nextPut: $;
]

{ #category : #'services tables' }
SQLServerPlatform >> printSqlStatementToTestExistenceOfSQLServerDatabase: schemaString on: aStream [
	"This query will check only for the existence of a database that the logged on user has access to (eg., NEWBERN1)."

	aStream
		nextPutAll: 'SELECT count(*) FROM ';
		nextPutAll: 'sys.databases WHERE name = ';
		nextPut: $';
		nextPutAll: schemaString;
		nextPut: $'
]

{ #category : #'services tables' }
SQLServerPlatform >> printSqlStatementToTestExistenceOfTable: tableName inSchema: schemaString on: aStream [
	"This query will test only for tables that the logged on user has access to..  Glorp supports case-preserving creation of tables in SQLServer (see capitalWritingOfTableName) but this tests case-insensitively, compatibly with its polymorphs in this hierarchy."

	| lowerTableName schema |
	lowerTableName := tableName asLowercase.
	schema := schemaString isNil
		ifTrue: ['']
		ifFalse: [schemaString, '.'].
	aStream
		nextPutAll: 'SELECT count(*) FROM ' ;
		nextPutAll: schema;
		nextPutAll: 'INFORMATION_SCHEMA.TABLES ';
		nextPutAll: 'WHERE lower(TABLE_NAME) = ';
		nextPut: $';
		nextPutAll: lowerTableName;
		nextPut: $';
		nextPut: $;
]

{ #category : #'conversion-times' }
SQLServerPlatform >> printTime: aTime for: aType [
	"Print a time (or timestamp) as hh:mm:ss.fff"
	| stream |
	aTime isNil ifTrue: [^'NULL'].
	stream := WriteStream on: String new.
	stream nextPutAll: '{ t '''.
	self
		printTime: aTime
		isoFormatOn: stream
		milliseconds: self supportsMillisecondsInTimes.
	stream nextPutAll: ''' }'.
	^stream contents.
]

{ #category : #'conversion-times' }
SQLServerPlatform >> printTimestamp: aTimestamp on: stream for: aType [
	aTimestamp isNil ifTrue: [stream nextPutAll: 'NULL'. ^self].
	stream nextPutAll: '{ ts '''.
	self
		printDate: aTimestamp
		isoFormatOn: stream.
	stream nextPutAll: ' '.
	self
		printTime: aTimestamp
		isoFormatOn: stream.
	stream nextPutAll: ''' }'.
]

{ #category : #'database-specific' }
SQLServerPlatform >> queryWithUnsupportedOperationsEliminatedFrom: aQuery do: aBlock [
	"If aQuery has operations that we don't support, rewrite it to do them in terms of lower level operations. In particular, rewrite INTERSECT/EXCEPT operations into EXISTS clauses in a single query. Pass the new query to aBlock."
	| newQuery |
	newQuery := aQuery rewriteIntersect.
	newQuery := newQuery rewriteExcept.
	newQuery == aQuery ifFalse: [aBlock value: newQuery].
]

{ #category : #types }
SQLServerPlatform >> real [
	^self float.
]

{ #category : #commands }
SQLServerPlatform >> relativeUpdateCommand [
	"SQLServer inserts 'OUTPUT ...' before its WHERE clause to return the updated value, unlike the more common approach of RETURNING after rest of the update statement, so its relative-update-and-return command is not ReturningUpdateCommand."

	^OutputUpdateCommand
]

{ #category : #'conversion-strings' }
SQLServerPlatform >> removeNestedParensFromString: aString [
	"Return a Smalltalk instance of the type indicated by aGlorpType.  SQL-Server wraps aString in parentheses, so uwrap it first.  If aString is nil, ensure we return nil."

	| debracket |
	aString size < 2 ifTrue: [^aString].	"relies on nil size = 0"
	debracket := aString copy.
	[debracket first = $( and: [debracket last = $)]]
		whileTrue: [debracket := debracket copyFrom: 2 to: debracket size - 1].
	^debracket
]

{ #category : #constants }
SQLServerPlatform >> requiresTransactionForTableOperations [
	"SQL Server, over ODBC doesn't support DDL transactions reliably, since the current transaction can be rolled back without notice. So we avoid this."
	^false.
]

{ #category : #testing }
SQLServerPlatform >> reusePreparedStatements [
	^false
]

{ #category : #types }
SQLServerPlatform >> sequence [
	^self serial.
]

{ #category : #types }
SQLServerPlatform >> serial [

	^self typeNamed: #serial ifAbsentPut: [GlorpSerialType new typeString: 'int  IDENTITY (1, 1) '].
]

{ #category : #'services tables' }
SQLServerPlatform >> sqlStatementToTestExistenceOfSchema: schemaString [
	"Although the method name indicates 'schema', the equivalent in SQL Server is called a 'database', and yet there is also a schema concept in SQL Server, which is more like 'owner', and can include mutliple databases. For example, BERN might be the owner and also the schema, which would include databases NEWBERN1, NEWBERN2.  This method presumes that the sender is interested in databases, and the query will test only for databases that the logged on user has access to."

	| stream |
	stream := WriteStream on: String new.
	self printSqlStatementToTestExistenceOfSQLServerDatabase: schemaString on: stream.
	^stream contents
]

{ #category : #constants }
SQLServerPlatform >> sqlTextCurrentServerUTCTimestamp [

	^'SELECT GETUTCDATE()'
]

{ #category : #constants }
SQLServerPlatform >> startColumnAddString [
	"The string we use as a prefix when adding a colum.
	Override the superclass default because MS doesn't use COLUMN."
	^' '.
]

{ #category : #testing }
SQLServerPlatform >> supportsANSIJoins [
	"Do we support the JOIN <tableName> USING <criteria> syntax. Currently hard-coded, but may also vary by database version"
	^true.
]

{ #category : #testing }
SQLServerPlatform >> supportsBinding [
	"Binding works only with VW EXDI so far.  Reuse of prepared statements is set to false by default (see my class-side)."

	^Dialect isVisualWorks.
]

{ #category : #testing }
SQLServerPlatform >> supportsDecimalsOnAllNumerics [
	"Return true if a general 'numeric' type will allow numbers after the decimal place"
	^false.
]

{ #category : #testing }
SQLServerPlatform >> supportsDuplicateFieldNamesInCompoundQueries [
	"Absurdly, Oracle, SQLServer and MySQL will not tolerate two unaliased fields in different tables but of the same name in a compound query, so the second (and subsequent) such fields must be aliased."

	^false
]

{ #category : #testing }
SQLServerPlatform >> supportsGroupWritingFor: aCommand [
	^aCommand supportsGroupWriting and:
		[self useBinding or: [aCommand needsRowCount not]]
]

{ #category : #testing }
SQLServerPlatform >> supportsGroupWritingValues [
	"I support it in version 10 and after."

	^supportsGroupWritingValues ifNil: [false]
]

{ #category : #testing }
SQLServerPlatform >> supportsLimit [
	"Do we support anything analogous to the postgresql LIMIT, returning only the first N rows"
	^true.
]

{ #category : #constants }
SQLServerPlatform >> supportsMillisecondsInTimes [
	"I'm guessing here"
	^true.
]

{ #category : #testing }
SQLServerPlatform >> supportsMultipleOpenCursors [
	"Can this database support multiple open cursors at once"
	^false.
]

{ #category : #testing }
SQLServerPlatform >> supportsRowCountFor: aRowBasedCommand [
	"SQLServer can send batched or array-bound insert and update statements to the server but if it is not bound then ODBC 2.0 will only return the result set and rowCount of the last statement in the batch, whereas ODBC 3.0 will return multiple result sets and the session can be asked its rowCount after each, and the result used only for the relevant statement or summed as desired.
	When it sends batched selects, both ODBC 2.0 and ODBC 3.0 can recover the answer sets for each select _but_ this rowCount is the total of rows read so far from the answer stream, not the total of rows found.  Only after the answer stream has been exhausted will the row count equal the number of matching rows that the select found to return.  Before any rows are read, the rowCount is -1, not zero;  it will be zero if the first attempt to read shows no rows were found.  (This typically showed as he last select in the batch having -1 rowCount, having been reached by Glorp processing and then the session queried for rowCount before that answer stream was read.)
	Thus this platform's rowCount is unreliable when unbound if being accessed over ODBC 2.0 and more than one batched statement is involved: a batch of several attempted UPDATEs will return a rowCount of 0 or 1 for the last UPDATE only, and will return #noMoreAnswers if #answer is sent again.  In ODBC 3.0 it is reliable."

	^(self useBinding and: [aRowBasedCommand useBinding])
		or: [self supportsUnboundRowCount
			or: [aRowBasedCommand expectedNumberOfModifiedRows < 2]]
]

{ #category : #testing }
SQLServerPlatform >> supportsTableOwners [
	"Return true if this platform supports table owners, i.e. expects table names of the form Bern.TW_* rather than just TW_* in its SQL."
"Access, Firebird and PostGreSQL do not, Oracle does, others I know not."

	^true
]

{ #category : #testing }
SQLServerPlatform >> supportsUnboundRowCount [
	"I support it in ODBC 3.0 and after."

	^supportsUnboundRowCount ifNil: [false]
]

{ #category : #types }
SQLServerPlatform >> text [
	^super text queryType: self varchar.
]

{ #category : #types }
SQLServerPlatform >> time [
	^self typeNamed: #time ifAbsentPut: [GlorpTimeType new typeString: 'datetime'].
]

{ #category : #types }
SQLServerPlatform >> timeStampTypeString [
	^'datetime'.
]

{ #category : #types }
SQLServerPlatform >> timestamp [
	^self typeNamed: #timestamp ifAbsentPut: [GlorpTimeStampType new typeString: 'datetime'].
]

{ #category : #types }
SQLServerPlatform >> tinyint [
	^self typeNamed: #tinyInt ifAbsentPut: [GlorpIntegerType new typeString: 'tinyint'].
]

{ #category : #'conversion-strings' }
SQLServerPlatform >> toGlorpType: aGlorpType fromString: aString [
	"Since SQL-Server wraps the string in parentheses, uwrap it first."

	^super
		toGlorpType: aGlorpType
		fromString: (self removeNestedParensFromString: aString)
]

{ #category : #types }
SQLServerPlatform >> typeWithDatabaseName: aString characterWidth: aNumber extraInformation: extraValue [
	"Return our type which matches the database name for the type. Assumes all variable width fields are strings right now."
	extraValue = 'IDENTITY' ifTrue: [^self serial].
	^super typeWithDatabaseName: aString characterWidth: aNumber.
]

{ #category : #'type helpers' }
SQLServerPlatform >> typesWithValues [
	self nvarchar.
	self nchar.
	self ntext.
	^super typesWithValues
]

{ #category : #testing }
SQLServerPlatform >> useMicrosoftOuterJoins [
	"Return true if we use the Microsoft x *= y syntax for outer joins"
	^false.
]

{ #category : #testing }
SQLServerPlatform >> usesArrayBindingToGroupWrite [
	"SQLServer supports array binding to group-write when bound.  As it is the most performant way to group-write, we use it in that case."

	^true
]

{ #category : #testing }
SQLServerPlatform >> usesIdentityColumns [
	^true.
]

{ #category : #testing }
SQLServerPlatform >> usesInformationSchema [

	^true
]

{ #category : #testing }
SQLServerPlatform >> usesLengthNotEndPosInSubstring [
	^true
]

{ #category : #types }
SQLServerPlatform >> varbinary [
	^self typeNamed: #varbinary ifAbsentPut: [GlorpVarBinaryType new].
]

{ #category : #types }
SQLServerPlatform >> varchar [
	^self typeNamed: #varchar ifAbsentPut: [GlorpVarCharType new].
]
