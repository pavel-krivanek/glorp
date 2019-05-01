"
This is a Glorp platform for DB2 databases.

"
Class {
	#name : #DB2Platform,
	#superclass : #DatabasePlatform,
	#instVars : [
		'supportsGroupWritingValues'
	],
	#category : #'Glorp-Database'
}

{ #category : #accessing }
DB2Platform class >> kind [
	^'DB2'
]

{ #category : #constants }
DB2Platform class >> reservedWords [
	
	^#('add' 'after' 'all' 'allocate' 'allow' 'alter' 'and' 'any' 'as' 'asensitive' 'associate' 'asutime' 'at' 'audit' 'aux' 'auxiliary' 'before' 'begin' 'between' 'bufferpool' 'by' 'call' 'capture' 'cascaded' 'case' 'cast' 'ccsid' 'char' 'character' 'check' 'clone' 'close' 'cluster' 'collection' 'collid' 'column' 'comment' 'commit' 'concat' 'condition' 'connect' 'connection' 'constraint' 'contains' 'content' 'continue' 'create' 'current' 'current_date' 'current_lc_ctype' 'current_path' 'current_schema' 'current_time' 'current_timestamp' 'cursor' 'data' 'database' 'day' 'days' 'dbinfo' 'declare' 'default' 'delete' 'descriptor' 'deterministic' 'disable' 'disallow' 'distinct' 'do' 'document' 'double' 'drop' 'dssize' 'dynamic' 'editproc' 'else' 'elseif' 'encoding' 'encryption' 'end' 'end-exec2' 'ending' 'erase' 'escape' 'except' 'exception' 'execute' 'exists' 'exit' 'explain' 'external' 'fenced' 'fetch' 'fieldproc' 'final' 'first' 'for' 'free' 'from' 'full' 'function' 'generated' 'get' 'global' 'go' 'goto' 'grant' 'group' 'handler' 'having' 'hold' 'hour' 'hours' 'if' 'immediate' 'in' 'inclusive' 'index' 'inherit' 'inner' 'inout' 'insensitive' 'insert' 'intersect' 'into' 'is' 'isobid' 'iterate' 'jar' 'join' 'keep' 'key' 'label' 'language' 'last' 'lc_ctype' 'leave' 'left' 'like' 'local' 'locale' 'locator' 'locators' 'lock' 'lockmax' 'locksize' 'long' 'loop' 'maintained' 'materialized' 'microsecond' 'microseconds' 'minute' 'minutes' 'modifies' 'month' 'months' 'next' 'nextval' 'no' 'none' 'not' 'null' 'nulls' 'numparts' 'obid' 'of' 'old' 'on' 'open' 'optimization' 'optimize' 'or' 'order' 'organization' 'out' 'outer' 'package' 'padded' 'parameter' 'part' 'partition' 'partitioned' 'partitioning' 'path' 'period' 'piecesize' 'plan' 'precision' 'prepare' 'prevval' 'prior' 'priqty' 'privileges' 'procedure' 'program' 'psid' 'public' 'query' 'queryno' 'reads' 'references' 'refresh' 'release' 'rename' 'repeat' 'resignal' 'restrict' 'result' 'result_set_locator' 'return' 'returns' 'revoke' 'right' 'role' 'rollback' 'round_ceiling' 'round_down' 'round_floor' 'round_half_down' 'round_half_even' 'round_half_up' 'round_up' 'row' 'rowset' 'run' 'savepoint' 'schema' 'scratchpad' 'second' 'seconds' 'secqty' 'security' 'select' 'sensitive' 'sequence' 'session_user' 'set' 'signal' 'simple' 'some' 'source' 'specific' 'standard' 'statement' 'static' 'stay' 'stogroup' 'stores' 'style' 'summary' 'synonym' 'sysfun' 'sysibm' 'sysproc' 'system' 'table' 'tablespace' 'then' 'to' 'trigger' 'truncate' 'type' 'undo' 'union' 'unique' 'until' 'update' 'user' 'using' 'validproc' 'value' 'values' 'variable' 'variant' 'vcat' 'view' 'volatile' 'volumes' 'when' 'whenever' 'where' 'while' 'with' 'wlm' 'xmlcast' 'xmlexists' 'xmlnamespaces' 'year' 'years' 'zone') asSet.
]

{ #category : #constants }
DB2Platform >> areSequencesExplicitlyCreated [

	^true
]

{ #category : #binding }
DB2Platform >> bindingsForGroupWritingFor: aCommand [
	^aCommand arrayBindings.
]

{ #category : #types }
DB2Platform >> blob [
	^self typeNamed: #blob ifAbsentPut: [GlorpBlobType new typeString: 'BLOB'].
]

{ #category : #'conversion-boolean' }
DB2Platform >> booleanToBooleanConverter [
	^DelegatingDatabaseConverter
		named: #booleanToBoolean
		hostedBy: self
		fromStToDb: #convertBooleanToInteger:for:
		fromDbToSt: #convertDBBooleanToBoolean:for:.
]

{ #category : #testing }
DB2Platform >> canUseInWhereClause: aValue type: aType [
	"This is mostly for test support purposes. If we know we can't use a particular kind of value in the where clause on some database, don't try."

	(super canUseInWhereClause: aValue type: aType) ifFalse: [^false].
	"In DB2 we don't seem to be able to compare lobs against anything.
	But if you convert the lob itself, that works sometimes. Eg.,
		... WHERE CHAR(clb) = 'abcdefghijklmnop'.
		... WHERE SUBSTR(clb,1, 16) LIKE 'abcdefghijklmnop'.
		... WHERE CHAR(SUBSTR(clb,1, 16)) = 'abcdefghijklmnop'.
	Note that LIKE works with SUBSTR(), but = works with CHAR()."
	((Set with: (self blob) with: (self clob) with: (self nclob)) includes: aType) ifTrue: [^false].
	^true.
]

{ #category : #types }
DB2Platform >> char [
	^self typeNamed: #char ifAbsentPut: [GlorpCharType new typeString: 'CHARACTER'].
]

{ #category : #'conversion-strings' }
DB2Platform >> charactersThatNeedEscaping [
	"There seem to be all kind of contradictory bits of information about what sql server does/requires for escaped characters, all of which differ from standard sql. Empirically the only thing that requires escaping appears to be single quote"
	^#($' ).
]

{ #category : #types }
DB2Platform >> clob [

	^self typeNamed: #clob ifAbsentPut: [GlorpClobType new typeString: 'CLOB'].
]

{ #category : #'database-specific' }
DB2Platform >> compoundOperationFor: aSymbol [
	"Return the platform specific version of a compound statement symbol"
	aSymbol == #INTERSECT ifTrue: [^'WHERE EXISTS'].
	aSymbol == #MINUS ifTrue: [^'WHERE NOT EXISTS'].
	^aSymbol.
]

{ #category : #'services columns' }
DB2Platform >> createAlterColumnStatement: aField newType: aType usingExpression: expression [

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
		nextPutAll:  ' SET DATA TYPE ';
		nextPutAll: aType typeString.
	expression ifNotNil: [ sqlStatementStream nextPutAll: ' USING ', expression ].

	^sqlStatementStream contents
]

{ #category : #'services constraints' }
DB2Platform >> createConstraintAddStatement: aConstraint [
	| sqlStatementStream |
	aConstraint shouldCreateInDatabase ifFalse: [^''].
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
		nextPutAll: 'ALTER TABLE';
		space.
	self printDDLTableNameFor: aConstraint table on: sqlStatementStream.
	(aConstraint creationStringFor: self)
		do: [:each | sqlStatementStream nextPutAll: ' ADD ' , each]
		separatedBy: [sqlStatementStream nextPut: Character space].
	^sqlStatementStream contents
]

{ #category : #constants }
DB2Platform >> databaseIdentitySequenceClass [
	"Uses the IDENTITY column mechanism."

	^DB2IdentitySequence
]

{ #category : #sequences }
DB2Platform >> databaseSequenceClass [
	"Use the SEQUENCE generator instead of the IDENTITY column mechanism."

	^DB2Sequence
]

{ #category : #types }
DB2Platform >> date [
	"Return the type we use to represent dates."
	^self typeNamed: #date ifAbsentPut: [GlorpDateType new].
]

{ #category : #types }
DB2Platform >> decimal [
	^self numeric.
]

{ #category : #types }
DB2Platform >> double [
	^self typeNamed: #double ifAbsentPut: [GlorpDoubleType new typeString: 'DOUBLE' ].
]

{ #category : #'conversion-strings' }
DB2Platform >> escapeFor: aCharacter [
	^String with: $' with: aCharacter.
"	^'\', (aCharacter asInteger printStringRadix: 16)."
]

{ #category : #types }
DB2Platform >> float [
	^self typeNamed: #float ifAbsentPut: [GlorpFloatType new typeString: 'REAL' ].
]

{ #category : #types }
DB2Platform >> float4 [
	^self float.
]

{ #category : #types }
DB2Platform >> float8 [
	^self double.
]

{ #category : #functions }
DB2Platform >> initializeFunctions [
	"DB2 doesn't allow CAST(date AS timestamp), but it does have a TIMESTAMP function."

	| baseExists dbSpecificExists selectList baseNotExists dbSpecificNotExists |
	super initializeFunctions.
	functions
		at: #, put: (InfixFunction named: '+');
		at: #timestamp: put: ((PrefixFunction named: 'TIMESTAMP') type: self timestamp); "TIMESTAMP(date, time)"
		at: #time0 put: ((StandaloneFunction named: 'TIME(''00:00:00'')') type: self time);
		at: #castTo: put: ((PrefixFunction named: 'CAST') separator: ' AS '). "CAST(aThing AS aType)"
		"at: #like: put: (InfixFunction named: 'LIKE').
		at: #copyFrom:to: put: (SubstringFunction named: 'SUBSTRING');"

	"Like Oracle, DB2 doesn't allow functions like EXISTS in a field list,
	but will allow a select there as an argument to a function, such as CASE.
	So print it that way if we're in the select list."

	baseExists := functions at: #exists:.
	dbSpecificExists := DualRoleFunction new.
	dbSpecificExists function: '#exists:'.
	dbSpecificExists whereClauseVersion: baseExists.
	selectList := Case new argumentTypes: (Array with: (self varchar: 1) with: self integer with: self integer).
	selectList argumentModifierBlock: [:function :args | 
		function base: args first.
		Array with: 'x' asGlorpExpression with: 1 asGlorpExpression with: 0 asGlorpExpression].
	dbSpecificExists selectListVersion: selectList.
	dbSpecificExists type: self integer.
	functions at: #exists: put: dbSpecificExists.

	"And similarly NOT EXISTS"
	baseNotExists := functions at: #notExists:.
	dbSpecificNotExists := DualRoleFunction new.
	dbSpecificNotExists function: '#notExists:'.
	dbSpecificNotExists whereClauseVersion: baseNotExists.
	selectList := Case new argumentTypes: (Array with: (self varchar: 1) with: self integer with: self integer).
	selectList argumentModifierBlock: [:function :args | 
		function base: args first.
		Array with: 'x' asGlorpExpression with: 0 asGlorpExpression with: 1 asGlorpExpression].
	dbSpecificNotExists selectListVersion: selectList.
	dbSpecificNotExists type: self integer.
	functions at: #notExists: put: dbSpecificNotExists.

"Duration arithmetic functions - DB2 does not tolerate direct combinations of integers and dates / timestamps.  First we list the functions that extract integers from summed or differences dates, e.g.
	(each endDate - each startDate) year > 3
would return rows where the difference exceeded three years."
	functions
		at: #microsecond put: ((PrefixFunction named: 'MICROSECOND') type: self integer);
		at: #second put: ((PrefixFunction named: 'SECOND') type: self integer);
		at: #minute put: ((PrefixFunction named: 'MINUTE') type: self integer);
		at: #hour put: ((PrefixFunction named: 'HOUR') type: self integer);
		at: #day put: ((PrefixFunction named: 'DAY') type: self integer);
		at: #month put: ((PrefixFunction named: 'MONTH') type: self integer);
		at: #year put: ((PrefixFunction named: 'YEAR') type: self integer).
"If a column holds integers which in fact signify durations, use the following functions to convert to durations in expressions, e.g.
	each startDate + each daysToBonus days < Date today
would return rows where elapsed time from start exceeded the bonus duration."
	functions
		at: #microseconds put: ((PostfixFunction named: 'MICROSECONDS') type: (self date));
		at: #seconds put: ((PostfixFunction named: 'SECONDS') type: self date);
		at: #minutes put: ((PostfixFunction named: 'MINUTES') type: self date);
		at: #hours put: ((PostfixFunction named: 'HOURS') type: self date);
		at: #days put: ((PostfixFunction named: 'DAYS') type: self date);
		at: #months put: ((PostfixFunction named: 'MONTHS') type: self date);
		at: #years put: ((PostfixFunction named: 'YEARS') type: self date).
]

{ #category : #constants }
DB2Platform >> initializeReservedWords [
	super initializeReservedWords.
]

{ #category : #commands }
DB2Platform >> insertCommandForRows: aCollectionOfDatabaseRows binding: aBoolean session: aSession [
	"I cannot group ;-separated INSERT statements but (if I am new enough - version 8 or later) I can group ,-separated values following a single INSERT statement when unbound.  When bound, the same applied but I can also bind an array of values to a single INSERT statement. As array binding is fastest, I use it when bound, values when unbound."

	^(aBoolean
		ifTrue: [InsertCommand]
		ifFalse: [self supportsGroupWritingValues
				ifFalse: [InsertCommand]
				ifTrue: [InsertMultiValuesCommand]])
		forRows: aCollectionOfDatabaseRows
		useBinding: aBoolean
		session: aSession
]

{ #category : #types }
DB2Platform >> int [
	^self integer.
]

{ #category : #types }
DB2Platform >> int2 [
	^self smallint.
]

{ #category : #types }
DB2Platform >> int4 [

	^self integer.
]

{ #category : #types }
DB2Platform >> int8 [
	^self typeNamed: #int8 ifAbsentPut: [GlorpIntegerType new typeString: 'BIGINT'].
]

{ #category : #testing }
DB2Platform >> isDB2Platform [

	^true
]

{ #category : #constants }
DB2Platform >> maximumLengthOfColumnName [
	"^<Integer> I return the max. length of a column name"

	^128
]

{ #category : #constants }
DB2Platform >> maximumLengthOfTableName [
	"^<Integer> I return the max. length of a table name"

	^128
]

{ #category : #testing }
DB2Platform >> maximumQueryValueSize [
	"If there's a limit on how big a bound input parameter can be for a query, return it here.
	For literal strings and lobs, at least, the DB2 limit is 32K. Not sure about bound objects.
	If those can be larger, then we can indicate that fact by introducing a companion method
	later. Note that we write literal LOBs as 2-byte hex chars per byte. So, the limit is
	actually 16384-9-1, eg., blob(X'0A41') makes 9 extras."
	^16374
]

{ #category : #binding }
DB2Platform >> maximumSizeToGroupWriteFor: aRowBasedCommand [
	^250 min: (super maximumSizeToGroupWriteFor: aRowBasedCommand)
]

{ #category : #api }
DB2Platform >> migrationExceptionBlockFor: aMigrationOperation accessor: anAccessor [
	"This method should return a new copy of the block(s), with a new copy of #first method var.
	The #first var changes to False after innerBlock has executed once, and stays that way to prevent an endless loop.
	The outer block (the thing we actually return) expects one parameter, the exception object."

	| first innerBlock |
	first := ValueHolder with: true.
	innerBlock :=
			[:ex :accessor :isFirst :operation |
			(isFirst value and: [self isDB2TableReorgException: ex])
				ifTrue: 
					[accessor doDDLOperation: 
							[accessor
								executeSQLStringNoResult: 'Call Sysproc.admin_cmd(''REORG TABLE '
										, (operation tableName copyWithout: $') , ''')'].
					isFirst value: false.
					ex retry]
				ifFalse: [operation exceptionBlock value: ex]].
	^[:ex| innerBlock valueWithArguments: (Array with: ex with: anAccessor with: first with: aMigrationOperation)].
]

{ #category : #types }
DB2Platform >> nclob [

	^self typeNamed: #nclob ifAbsentPut: [GlorpClobType new typeString: 'dbclob'].
]

{ #category : #types }
DB2Platform >> number [
	"DB2 NUMERIC columns default to precision=5, scale=0."
	
	^self typeNamed: #number ifAbsentPut: [GlorpNumericType new typeString: 'DECIMAL']
]

{ #category : #types }
DB2Platform >> nvarchar [
	^self typeNamed: #nvarchar ifAbsentPut: [GlorpVarCharType new typeString: 'nvarchar'].
]

{ #category : #login }
DB2Platform >> postLoginInitializeFromAccessor: aDatabaseAccessor [
	"DB2 has been supporting group writing with the VALUES clause at least since version 8.0"

	| dbmsVersion |
	dbmsVersion := aDatabaseAccessor connection dbmsVersion tokensBasedOn: $..
	supportsGroupWritingValues := dbmsVersion first asNumber > 7.
]

{ #category : #'conversion-strings' }
DB2Platform >> printBlob: aByteArray on: aStream for: aType [
	aByteArray isNil ifTrue: [^aStream nextPutAll: 'NULL'].
	aStream nextPutAll: 'BLOB(X'''.
	aByteArray do: [:each |
		each printOn: aStream paddedWith: $0 to: 2 base: 16].
	aStream nextPutAll: ''') '.
"	aStream nextPutAll: 'CAST(X'''.
	aByteArray do: [:each |
		each printOn: aStream paddedWith: $0 to: 2 base: 16].
	aStream nextPutAll: ''' AS BLOB) '."
]

{ #category : #'conversion-boolean' }
DB2Platform >> printBoolean: aBoolean for: aType [
	"If the platform is MS SQL Server, a boolean object in a SELECT needs to be converted to  BIT type, since T, Y, or true make SQLServer complain. "
	
	| string |
	aBoolean isNil ifTrue: [^'NULL'].
	"We may be getting passed something that's already 1 or 0, or something else instead of a boolean. That probably shouldn't be happening, but let's handle it gracefully. We define gracefully to mean 1 is true, and everything else is false"
	string := (aBoolean == 1 or: [aBoolean = true]) 
		ifTrue: ['1'] 
		ifFalse: ['0'].
	^'CONVERT( BIT, ' , string , ' )'.
]

{ #category : #'conversion-times' }
DB2Platform >> printDate: aDate for: aType [
	"Print a date (or timestamp) as yyyy-mm-dd"
	| stream |
	aDate isNil ifTrue: [^'NULL'].
	stream := WriteStream on: String new.
	stream nextPut: $'.
	self
		printDate: aDate
		isoFormatOn: stream.
	stream nextPut: $'.
	^stream contents.
]

{ #category : #'database-specific' }
DB2Platform >> printPostLimit: anInteger on: aCommand [
	
	aCommand nextPutAll: ' FETCH FIRST  '.
	anInteger printOn: aCommand.
	aCommand nextPutAll: ' ROWS ONLY '
]

{ #category : #'services tables' }
DB2Platform >> printSqlStatementToListTablesInSchema: schemaString on: aStream [
	"Not standardized"

	| lowerSchema |
	lowerSchema := schemaString isNil
		ifTrue: [schemaString]
		ifFalse: [schemaString asLowercase].
	aStream nextPutAll: 'SELECT table_name FROM sysibm.tables '.
	(lowerSchema notNil and: [lowerSchema notEmpty]) ifTrue:
		[aStream
			nextPutAll: 'WHERE lower(table_schema) = ';
			nextPut: $';
			nextPutAll: lowerSchema;
			nextPut: $']
]

{ #category : #'services tables' }
DB2Platform >> printSqlStatementToRenameTable: aDatabaseTable to: newTableName on: aStream [
	" The DB2 SQL statement is
	RENAME TABLE <oldTableName> TO <newTableName>."

	aStream
		nextPutAll: 'RENAME TABLE ';
		nextPutAll: (self ddlTableNameFor: aDatabaseTable);
		nextPutAll: ' TO ';
		nextPutAll: newTableName
]

{ #category : #'services tables' }
DB2Platform >> printSqlStatementToTestExistenceOfTable: tableName inSchema: schemaString on: aStream [
	" This query will test only for tables that the logged on user has access to... "

	| lowerTableName lowerSchema |
	lowerTableName := tableName asLowercase.
	lowerSchema := schemaString isNil
		ifTrue: [schemaString]
		ifFalse: [schemaString asLowercase].
	aStream
		nextPutAll: 'SELECT count(*) FROM sysibm.tables ';
		nextPutAll: 'WHERE lower(table_name) = ';
		nextPut: $';
		nextPutAll: lowerTableName;
		nextPut: $'.
	(lowerSchema notNil and: [lowerSchema notEmpty]) ifTrue:
		[aStream
			nextPutAll: ' AND lower(table_schema) = ';
			nextPut: $';
			nextPutAll: lowerSchema;
			nextPut: $']
]

{ #category : #'conversion-times' }
DB2Platform >> printTime: aTime for: aType [
	"Print a time (or timestamp) as hh:mm:ss.fff"
	| stream |
	aTime isNil ifTrue: [^'NULL'].
	stream := WriteStream on: String new.
	stream nextPutAll: 'TIME( '''.
	self
		printTime: aTime
		isoFormatOn: stream
		milliseconds: self supportsMillisecondsInTimes.
	stream nextPutAll: ''' )'.
	^stream contents.
]

{ #category : #'conversion-times' }
DB2Platform >> printTimestamp: aTimestamp on: stream for: aType [
	"In DB2, we could use TIMESTAMP for up to microseconds;  (Times do not even support milliseconds in DB2.)"

	aTimestamp isNil ifTrue:
		[stream nextPutAll: 'NULL'.
		^self].
	stream nextPut: $'.
	self printDate: aTimestamp isoFormatOn: stream.
	stream nextPutAll: ' '.
	self
		printTime: aTimestamp
		isoFormatOn: stream
		milliseconds: true.
	stream nextPut: $'.
]

{ #category : #'database-specific' }
DB2Platform >> queryWithUnsupportedOperationsEliminatedFrom: aQuery do: aBlock [
	"If aQuery has operations that we don't support, rewrite it to do them in terms of lower level operations. In particular, rewrite INTERSECT/EXCEPT operations into EXISTS clauses in a single query. Pass the new query to aBlock."
	| newQuery |
	newQuery := aQuery rewriteIntersect.
	newQuery := newQuery rewriteExcept.
	newQuery == aQuery ifFalse: [aBlock value: newQuery].
]

{ #category : #types }
DB2Platform >> real [
	^self float.
]

{ #category : #testing }
DB2Platform >> requiresCastsForNullsInUnions [
	"If we have explicit nulls in a query which is unioned, do we need to cast them to the appropriate type in order to keep the database happy."
	^true.
]

{ #category : #types }
DB2Platform >> sequence [
	^self serial.
]

{ #category : #types }
DB2Platform >> serial [
	"This is the sequence based type used by Glorp."

	^self typeNamed: #serial ifAbsentPut: [GlorpSerialType new typeString: (self integer typeString)].
]

{ #category : #types }
DB2Platform >> serialIdentity [
	"This is the identity column type used by DB2, but not supported by Glorp. It is here just
	so that we can recognize identity columns when they are encountered."

	^self typeNamed: #serialIdentity ifAbsentPut: [DB2IdentityType new typeString: 'integer generated always as identity '].
]

{ #category : #constants }
DB2Platform >> sqlTextForNULLAttributeConstraint [
	"^<String>"

	^''
]

{ #category : #testing }
DB2Platform >> supportsANSIJoins [
	"Do we support the JOIN <tableName> USING <criteria> syntax. Currently hard-coded, but may also vary by database version"
	^true.
]

{ #category : #testing }
DB2Platform >> supportsBinding [
	"Binding works only with VW EXDI so far"
	^Dialect isVisualWorks.
]

{ #category : #testing }
DB2Platform >> supportsCompositeKeyArgsForOperand: aSymbol [
	"In DB2,
		composite-row IN subquery LIMIT 1
is OK but it rejects composite
		composite-row = subquery LIMIT 1
with error
	[IBM][CLI Driver][DB2/NT64] SQL0412N  Multiple columns are returned from a subquery that is allowed only one column. SQLSTATE=42823
I take this to mean that DB2 supports LIMIT in subquery - it does not _say_ it does not - so it _should_ accept
		composite-row = subquery LIMIT 1
since it allows the semantically identical
		composite-row IN subquery LIMIT 1
The fact that it does not allow it _may_ means they implement = or IN error-checking code in an overly crude way. (We could raise a bug report to DB2.)  Obviously, since IN ... LIMIT 1 is allowed, we could in theory handle all cases, including #readOneOf:, by giving the RelationExpression a composite LHS, the IN operator, and rewriting the subquery of required;  in practise, for now, we return false for = (and for <> - the assumption is that it will fail there too, not yet tested) and so get the longhand solution: ANDed single-key queries."

	^aSymbol == #IN
]

{ #category : #testing }
DB2Platform >> supportsCorrelatedSubqueriesInOrderBy [
	"DB2 doesn't support correlated subqueries in the ORDER BY clause."

	^false
]

{ #category : #testing }
DB2Platform >> supportsDecimalsOnAllNumerics [
	"Return true if a general 'numeric' type will allow numbers after the decimal place.
	NUMERIC(5) will not store 321.12 (it'll keep 321.)."
	^false.
]

{ #category : #testing }
DB2Platform >> supportsGroupWritingFor: aCommand [
	"DB2 does not support batched statements, i.e. cannot do INSERT ...; INSERT ...; INSERT... , but since version 8.0 it does support value sequences, i.e. it can do INSERT INTO table (id, c) VALUES (1,'1'), (2,'2'), (3,'3')."

	^aCommand supportsGroupWriting and:
		[self useBinding or: [aCommand supportsGroupWritingValues]]
]

{ #category : #testing }
DB2Platform >> supportsGroupWritingValues [
	"I support it in version 8 and after."

	^supportsGroupWritingValues ifNil: [false]
]

{ #category : #testing }
DB2Platform >> supportsLimit [
	"Do we support anything analogous to the postgresql LIMIT, returning only the first N rows"
	^true.
]

{ #category : #constants }
DB2Platform >> supportsMillisecondsInTimes [
	"Use TIMESTAMP for up to microseconds;  Times do not even support milliseconds in DB2."

	^false
]

{ #category : #testing }
DB2Platform >> supportsTableOwners [
	"Return true if this platform supports table owners, i.e. expects table names of the form Bern.TW_* rather than just TW_* in its SQL."
"Access, Firebird and PostGreSQL do not, Oracle does, others I know not."

	^true
]

{ #category : #types }
DB2Platform >> text [
	^super text queryType: self varchar.
]

{ #category : #types }
DB2Platform >> time [
	^self typeNamed: #time ifAbsentPut: [GlorpTimeType new typeString: 'TIME'].
]

{ #category : #types }
DB2Platform >> timeStampTypeString [
	^'datetime'.
]

{ #category : #types }
DB2Platform >> timestamp [
	^self typeNamed: #timestamp ifAbsentPut: [GlorpTimeStampType new typeString: 'TIMESTAMP'].
]

{ #category : #types }
DB2Platform >> tinyint [
	^self typeNamed: #tinyInt ifAbsentPut: [GlorpIntegerType new typeString: 'SMALLINT'].
]

{ #category : #testing }
DB2Platform >> typeWithDatabaseName: aString characterWidth: aNumber extraInformation: extraValue [
	"Return our type which matches the database name for the type. Assumes all variable width fields are strings right now."
	extraValue = 'IDENTITY' ifTrue: [^self serialIdentity].
	^super typeWithDatabaseName: aString characterWidth: aNumber.
]

{ #category : #'type helpers' }
DB2Platform >> typesWithValues [
	"Return our types list, but makes sure it has at least basic types in it"

	self date.
	self double.
	self int8.
	self decimal.
	self real.
	^super typesWithValues
]

{ #category : #testing }
DB2Platform >> useMicrosoftOuterJoins [
	"Return true if we use the Microsoft x *= y syntax for outer joins"
	^false.
]

{ #category : #testing }
DB2Platform >> usesArrayBindingToGroupWrite [
	"DB2 supports array binding to group-write when bound.  As it is the most performant way to group-write, we use it in that case."

	^true
]

{ #category : #testing }
DB2Platform >> usesIdentityColumns [
	^false
]

{ #category : #testing }
DB2Platform >> usesLengthNotEndPosInSubstring [
	^true
]

{ #category : #types }
DB2Platform >> varbinary [
	^self typeNamed: #varbinary ifAbsentPut: [GlorpVarBinaryType new].
]

{ #category : #types }
DB2Platform >> varchar [
	^self typeNamed: #varchar ifAbsentPut: [GlorpVarCharType new typeString: 'VARCHAR'].
]

{ #category : #accessing }
DB2Platform >> vwEXDIConnectionClass [
	^'DB2Connection' asQualifiedReference valueIfUndefinedLoadFrom: 'DB2EXDI'
]
