Class {
	#name : #GlorpDatabaseLoginResource,
	#superclass : #TestResource,
	#instVars : [
		'accessor',
		'login'
	],
	#classVars : [
		'DefaultLogin'
	],
	#category : #'GlorpDBTests-GlorpTest'
}

{ #category : #accessing }
GlorpDatabaseLoginResource class >> constructEventsTriggered [
	^(super constructEventsTriggered)
		add: #changedDefaultLogin;
		yourself
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultAccessLogin [
	"To set the default database login for Access, execute the following statement."
	"self defaultAccessLogin."

	^DefaultLogin := (Login new)
		database: AccessPlatform new;
		username: 'whatever';
		password: '';
		connectString: 'access'
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultDB2Login [
	"To set the default database login to Oracle, execute the following statement."
	"self defaultDB2Login."

	^DefaultLogin := (Login new)
		database: DB2Platform new;
		username: 'sames';
		password: 'sames';
		connectString: 'store'
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultFirebirdLogin [
	"To set the default database login to Firebird, execute the following statement."
	"self defaultFirebirdLogin."

	^DefaultLogin := (Login new)
		database: FirebirdPlatform new;
		username: 'MyName';
		password: 'MyPassword';
		connectString: 'firebirdGlorpTestDB'
]

{ #category : #accessing }
GlorpDatabaseLoginResource class >> defaultLogin [
	"Return the default Login. Whether it binds is determined by UseBindingIfSupported if that is set, otherwise by the login platform's preference."

	DefaultLogin isNil ifTrue: [^DefaultLogin := self defaultPostgreSQLLoginForVPN].
	DefaultLogin database useBinding: DefaultLogin database class useBindingIfSupported.
	^DefaultLogin
]

{ #category : #accessing }
GlorpDatabaseLoginResource class >> defaultLogin: aLogin [
	DefaultLogin = aLogin ifFalse: [GlorpDemoTablePopulatorResource invalidateSetup].
	DefaultLogin := aLogin.
	self triggerEvent: #changedDefaultLogin.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultMysqlLogin [
	"To set the default database login to MySQL, execute the following statement."
	"self defaultMysqlLogin."

	^DefaultLogin := (Login new)
		database: MySQLPlatform new;
		username: '';
		password: '';
		connectString: 'test'.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultOracleLiteLogin [
	"To set the default database login to Oracle, execute the following statement."
	"self defaultOracleLiteLogin."

	^DefaultLogin := (Login new)
		database: OraclePlatform new;
		username: 'System';
		password: 'password';
		connectString: 'odbc:polite'
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultOracleLogin [
	"To set the default database login to Oracle, execute the following statement."
	"self defaultOracleLogin."

	^DefaultLogin := (Login new)
		database: OraclePlatform new;
		username: 'System';
		password: 'manager';
		connectString: ''
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultOracleLogin2 [
	"To set the default database login to Oracle, execute the following statement."
	"self defaultOracleLogin2."

	^DefaultLogin := (Login new)
		database: OraclePlatform new;
		username: 'system';
		password: 'password';
		connectString: ''
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultOracleODBCLogin [
	"To set the default database login to Oracle, execute the following statement."
	"self defaultOracleODBCLogin."

	^DefaultLogin := (Login new)
		database: OracleODBCPlatform new;
		username: 'System';
		password: 'manager';
		connectString: 'oracle'
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultPersonalOracleLogin [
	"To set the default database login to Oracle, execute the following statement."
	"self defaultPersonalOracleLogin."

	^DefaultLogin := (Login new)
		database: OraclePlatform new;
		username: 'system';
		password: 'manager';
		connectString: ''
]

{ #category : #accessing }
GlorpDatabaseLoginResource class >> defaultPlatform [
	^self defaultLogin database.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultPostgreSQL3LibpqLocalLogin [
	"Execute the following statement to set the default database login to PostgreSQL protocol 3.0 via the C API (not socket, so, as for Oracle and other databases, the local client library must be on the path).  The setting of a schema is not needed for GlorpTest tests but is needed for ActiveRecordTest tests."
	"self defaultPostgreSQL3LibpqLocalLogin."

	^DefaultLogin := (Login new)
		database: PostgresLibpqPlatform new;
		schema: 'public';
		username: 'MyName';
		password: 'MyPassword';
		connectString: 'localhost:5432_GlorpTestDB'.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultPostgreSQL3SocketLocalLogin [
	"To set the default database login to PostgreSQL protocol 3.0, execute the following statement.  The setting of a schema is not needed for GlorpTest tests but is needed for ActiveRecordTest tests."
	"self defaultPostgreSQL3SocketLocalLogin."

	^DefaultLogin := (Login new)
		database: PostgresSocketPlatform new;
		schema: 'public';
		username: 'MyName';
		password: 'MyPassword';
		connectString: 'localhost:5432_GlorpTestDB'.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultPostgreSQLInternetLogin [
	"To set the default database login to  PostgreSQL protocol 2.0 via socket, execute the following statement."
	"self defaultPostgreSQLInternetLogin."

	^DefaultLogin := (Login new)
		database: PostgreSQLPlatform new;
		username: 'guest';
		password: 'guest';
		connectString: 'store.cincomsmalltalk.com:5432_glorptest'.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultPostgreSQLLocalLogin [
	"To set the default database login to PostgreSQL protocol 2.0 via socket, execute the following statement.  The setting of a schema is not needed for GlorpTest tests but is needed for ActiveRecordTest tests."
	"self defaultPostgreSQLLocalLogin."

	^DefaultLogin := (Login new)
		database: PostgreSQLPlatform new;
		schema: 'public';
		username: 'MyName';
		password: 'MyPassword';
		connectString: 'localhost:5432_GlorpTestDB'.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultPostgreSQLLogin [
	"To set the default database login to  PostgreSQL protocol 2.0 via socket, execute the following statement."
	"self defaultPostgreSQLLogin."

	^DefaultLogin := (Login new)
		database: PostgreSQLPlatform new;
		username: 'glorp-test';
		password: 'simple';
		connectString: '192.168.0.18_glorp-test'.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultPostgreSQLLoginForGlorpStore [
	"To set the default database login to  PostgreSQL protocol 2.0 via socket, execute the following statement."
	"self defaultPostgreSQLLoginForGlorpStore."

	^DefaultLogin := (Login new)
		database: PostgreSQLPlatform new;
		username: 'store-glorp-test';
		password: 'simple';
		connectString: '192.168.0.18_store-glorp-test'.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultPostgreSQLLoginForVPN [
	"To set the default database login to  PostgreSQL protocol 2.0 via socket, execute the following statement."
	"self defaultPostgreSQLLoginForVPN."

	^DefaultLogin := (Login new)
		database: PostgreSQLPlatform new;
		username: 'dbadmin';
		password: 'dbadmin';
		connectString: 'curly.parcplace.com:5432_template1'.
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultSQLServerLogin [
	"To set the default database login for Dolphin, execute the following statement."
	"self defaultSQLServerLogin."

	^DefaultLogin := (Login new)
		database: SQLServerPlatform new;
		username: 'glorptest';
		password: 'password';
		connectString: 'glorptest'
]

{ #category : #data }
GlorpDatabaseLoginResource class >> defaultSQLiteLocalLogin [
	"To set the default database login to SQLite, change the connectString to an appropriate path and execute the following statement."
	"self defaultSQLiteLocalLogin."

	^DefaultLogin := (Login new)
		database: SQLite3Platform new;
		username: '';
		password: '';
		connectString: 'C:\somePath\someData\glorpTestSQLite.db'.
]

{ #category : #'VisualWorks metadata' }
GlorpDatabaseLoginResource class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'XProgramming.SUnit'
	)

]

{ #category : #accessing }
GlorpDatabaseLoginResource >> accessor [
	^accessor
]

{ #category : #accessing }
GlorpDatabaseLoginResource >> accessor: anObject [
	accessor := anObject
]

{ #category : #accessing }
GlorpDatabaseLoginResource >> login [
	^login
]

{ #category : #accessing }
GlorpDatabaseLoginResource >> login: anObject [
	"We don't attempt to be secure on logins being used for tests. Make sure we don't surprise someone by modifying the original instance."

	login := anObject copy.
	login secure: false.
]

{ #category : #accessing }
GlorpDatabaseLoginResource >> platform [
	^login database
]

{ #category : #'initialize/release' }
GlorpDatabaseLoginResource >> setUp [
	Transcript show: self class name asString, ' setUp'; cr.
	super setUp.
	self login: self class defaultLogin.
	accessor := DatabaseAccessor forLogin: login.
	accessor login.
]

{ #category : #'initialize/release' }
GlorpDatabaseLoginResource >> tearDown [

	Transcript show: self class name asString, ' tearDown'; cr.
	accessor notNil ifTrue: [[accessor logout] on: Dialect error do: [:ex | ]].
]
