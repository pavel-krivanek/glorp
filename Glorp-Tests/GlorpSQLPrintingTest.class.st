Class {
	#name : #GlorpSQLPrintingTest,
	#superclass : #GlorpTestCase,
	#category : #'Glorp-Tests'
}

{ #category : #'utilities-update' }
GlorpSQLPrintingTest >> assertGroupUpdatingOnPlatform: platform printsSQLs: sqlStrings [
	"The parameter platform instance is configured to allow group writing.  Verify that a five-row UpdateCommand created from it will group-write by evaluating the relevant code in RowBasedCommand>>execute{Bound|Unbound}In:, which is
	self hasMultipleRows and: [self shouldUseGroupWriting not] ...
(as we know our test command has multiple rows, we only check #shouldUseGroupWriting).  Then check the command's SQL.  The update command may subgroup its rows according to the SQL command, so we get the SQL string for each subgroup."

	| command actualStrings |
	command := self sixRowUpdateCommandForPlatform: platform.
	self assert: command shouldUseGroupWriting
		description: ('<1s> <2?Bound:Unbound> cannot group-write multi-row <3s>'
					expandMacrosWith: platform class name
					with: platform useBinding
					with: command class name).
	actualStrings := OrderedCollection new.
	command allRowsGrouped: 1000 evaluate:
		[actualStrings add: command sqlString].
	sqlStrings with: actualStrings do:
		[:sqlString :actualString |
		self assert: actualString = sqlString
			description: ('<1s> <2?Bound:Unbound> wrote <3s> instead of expected <4s>'
						expandMacrosWith: platform class name
						with: platform useBinding
						with: actualString
						with: sqlString)
		resumable: true].
]

{ #category : #'utilities-insert' }
GlorpSQLPrintingTest >> assertGroupWritingIdentityOnPlatform: platform printsSQL: aString [
	| command actualString |
	command := self twoRowIdentityInsertCommandForPlatform: platform.
	self assert: command shouldUseGroupWriting
		description: ('<1s> <2?Bound:Unbound> cannot group-write multi-row <3s>'
				expandMacrosWith: platform class name
				with: platform useBinding
				with: command class name).
	actualString := command sqlString.
	self
		assert: actualString = aString
		description: ('<1s> <2?Bound:Unbound> wrote <3s> instead of expected <4s>'
				expandMacrosWith: platform class name
				with: platform useBinding
				with: actualString
				with: aString)
		resumable: true.
]

{ #category : #utilities }
GlorpSQLPrintingTest >> assertGroupWritingOnPlatform: platform [
	| system row1 row2 command string session |
	session := GlorpDemoDescriptorSystem sessionForLogin: (Login new database: platform).
	system := session system.
	row1 := DatabaseRow newForTable: (system tableNamed: 'GR_ADDRESS').
	row1 atFieldNamed: 'ID' put: 1.
	row2 := DatabaseRow newForTable: (system tableNamed: 'GR_ADDRESS').
	row2 atFieldNamed: 'ID' put: 2.
	command := InsertCommand forRows: (Array with: row1 with: row2) useBinding: false session: session.
	string := command sqlString.
	self assert: (string includes: $;).
	self assert: string = 'INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (1,NULL,NULL); INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (2,NULL,NULL)'.
]

{ #category : #'utilities-insert' }
GlorpSQLPrintingTest >> assertGroupWritingOnPlatform: platform printsSQL: aString [
	"The parameter platform instance is configured to allow group writing.  Verify that a two-row InsertCommand created from it will group-write by evaluating the relevant code in RowBasedCommand>>execute{Bound|Unbound}In:, which is
	self hasMultipleRows and: [self shouldUseGroupWriting not] ...
(as we know our test command has two rows, we only check #shouldUseGroupWriting).  Then check the command's SQL."

	| command actualString |
	command := self twoRowInsertCommandForPlatform: platform.
	self assert: command shouldUseGroupWriting
		description: ('<1s> <2?Bound:Unbound> cannot group-write multi-row <3s>'
					expandMacrosWith: platform class name
					with: platform useBinding
					with: command class name).
	actualString := command sqlString.
	self assert: actualString = aString
		description: ('<1s> <2?Bound:Unbound> wrote <3s> instead of expected <4s>'
					expandMacrosWith: platform class name
					with: platform useBinding
					with: actualString
					with: aString)
		resumable: true.
]

{ #category : #'utilities-update' }
GlorpSQLPrintingTest >> assertNonGroupUpdatingOnPlatform: aDatabasePlatform [
	"The parameter platform instance is not configured to allow group writing.  Verify that a multi-row UpdateCommand created from it will not group-write by evaluating the relevant code in UpdateCommand>>execute{Bound|Unbound}In:, which is
	self hasMultipleRows and: [self shouldUseGroupWriting not] ...
(as we know our test command has multiple rows, we only check #shouldUseGroupWriting).  Then check each row's SQL under the
		self allRowsSinglyEvaluate: [ ... self sqlString ...]
follow-on code of those methods."

	| command requiredStrings actualStrings |
	command := self sixRowUpdateCommandForPlatform: aDatabasePlatform.
	self deny: command shouldUseGroupWriting
		description: ('<1s> <2?Bound:Unbound> should not group-write multi-row <3s>'
					expandMacrosWith: aDatabasePlatform class name
					with: aDatabasePlatform useBinding
					with: command class name).
	requiredStrings := command useBinding
		ifFalse: [#('UPDATE GR_ADDRESS SET STREET = ''Privet Drive'',HOUSE_NUM = ''4'' WHERE ID = 1'
				'UPDATE GR_ADDRESS SET STREET = ''Baker Street'' WHERE ID = 2'
				'UPDATE GR_ADDRESS SET STREET = ''Coven Street'' WHERE ID = 3'
				'UPDATE GR_ADDRESS SET HOUSE_NUM = ''221b'' WHERE ID = 4'
				'UPDATE GR_ADDRESS SET HOUSE_NUM = ''7'' WHERE ID = 5'
				'UPDATE GR_ADDRESS SET HOUSE_NUM = ''12'' WHERE ID = 6')]
		ifTrue: [#('UPDATE GR_ADDRESS SET STREET = ?,HOUSE_NUM = ? WHERE ID = ?'
				'UPDATE GR_ADDRESS SET STREET = ? WHERE ID = ?'
				'UPDATE GR_ADDRESS SET STREET = ? WHERE ID = ?'
				'UPDATE GR_ADDRESS SET HOUSE_NUM = ? WHERE ID = ?'
				'UPDATE GR_ADDRESS SET HOUSE_NUM = ? WHERE ID = ?'
				'UPDATE GR_ADDRESS SET HOUSE_NUM = ? WHERE ID = ?')].
	actualStrings := OrderedCollection new.
	"Mimic the first lines of execute{Unbound|Bound}In: to test non-group writing"
	(command hasMultipleRows and: [command shouldUseGroupWriting not])
		ifTrue: [command allRowsSinglyEvaluate: [actualStrings add: command sqlString]].
	actualStrings with: requiredStrings do:
		[:actualString :requiredString |
		self assert: actualString = requiredString
			description: ('Updating ungrouped row to <1s> <2?Bound:Unbound> wrote <3s> instead of expected <4s>'
					expandMacrosWith: aDatabasePlatform class name
					with: aDatabasePlatform useBinding
					with: actualString
					with: requiredString)
		resumable: true].
]

{ #category : #'utilities-insert' }
GlorpSQLPrintingTest >> assertNonGroupWritingOnPlatform: aDatabasePlatform [
	"The parameter platform instance is not configured to allow group writing.  Verify that a two-row InsertCommand created from it will not group-write by evaluating the relevant code in InsertCommand>>execute{Bound|Unbound}In:, which is
	self hasMultipleRows and: [self shouldUseGroupWriting not] ...
(as we know our test command has two rows, we only check #shouldUseGroupWriting).  Then check each row's SQL under the
		self allRowsSinglyEvaluate: [ ... self sqlString ...]
follow-on code of those methods."

	| command requiredStrings actualStrings |
	command := self twoRowInsertCommandForPlatform: aDatabasePlatform.
	self deny: command shouldUseGroupWriting
		description: ('<1s> <2?Bound:Unbound> should not group-write multi-row <3s>'
					expandMacrosWith: aDatabasePlatform class name
					with: aDatabasePlatform useBinding
					with: command class name).
	requiredStrings := command useBinding
		ifFalse: [OrderedCollection
				with: 'INSERT INTO GR_ADDRESS (ID)  VALUES (1)'
				with: 'INSERT INTO GR_ADDRESS (ID)  VALUES (2)']
		ifTrue: [OrderedCollection
				with: 'INSERT INTO GR_ADDRESS (ID)  VALUES (?)'
				with: 'INSERT INTO GR_ADDRESS (ID)  VALUES (?)'].
	actualStrings := OrderedCollection new.
	"Mimic the first lines of execute{Unbound|Bound}In: to test non-group writing"
	(command hasMultipleRows and: [command shouldUseGroupWriting not])
		ifTrue: [command allRowsSinglyEvaluate: [actualStrings add: command sqlString]].
	actualStrings with: requiredStrings do:
		[:actualString :requiredString |
		self assert: actualString = requiredString
			description: ('Inserting ungrouped row to <1s> <2?Bound:Unbound> wrote <3s> instead of expected <4s>'
					expandMacrosWith: aDatabasePlatform class name
					with: aDatabasePlatform useBinding
					with: actualString
					with: requiredString)
		resumable: true].
]

{ #category : #'utilities-update' }
GlorpSQLPrintingTest >> sixRowUpdateCommandForPlatform: aDatabasePlatform [
	"A trivial multi-row update command for testing group writing.  One row has values for all three fields, two have values for ID and STREET, three have values for ID and HOUSE_NUM.  (These row numbers - 1, 2 and 3 - are used as indexes to get specific results in callers.)"

	| rows session system table |
	session := GlorpDemoDescriptorSystem sessionForLogin: (Login new database: aDatabasePlatform).
	system := session system.
	table := system tableNamed: 'GR_ADDRESS'.
	rows := OrderedCollection new: 6.
	"ID, STREET and HOUSE_NUM have values"
	rows add: (DatabaseRow newForTable: table).
	rows last
		atFieldNamed: 'ID' put: 1;
		atFieldNamed: 'STREET' put: 'Privet Drive';
		atFieldNamed: 'HOUSE_NUM' put: '4'.
	"ID and STREET have values"
	rows add: (DatabaseRow newForTable: table).
	rows last
		atFieldNamed: 'ID' put: 2;
		atFieldNamed: 'STREET' put: 'Baker Street'.
	rows add: (DatabaseRow newForTable: table).
	rows last
		atFieldNamed: 'ID' put: 3;
		atFieldNamed: 'STREET' put: 'Coven Street'.
	"ID and HOUSE_NUM have values"
	rows add: (DatabaseRow newForTable: table).
	rows last
		atFieldNamed: 'ID' put: 4;
		atFieldNamed: 'HOUSE_NUM' put: '221b'.
	rows add: (DatabaseRow newForTable: table).
	rows last
		atFieldNamed: 'ID' put: 5;
		atFieldNamed: 'HOUSE_NUM' put: '7'.
	rows add: (DatabaseRow newForTable: table).
	rows last
		atFieldNamed: 'ID' put: 6;
		atFieldNamed: 'HOUSE_NUM' put: '12'.
	^UpdateCommand
		forRows: rows asArray
		useBinding: session useBinding
		session: session
]

{ #category : #tests }
GlorpSQLPrintingTest >> testDatePrinting [
	| date stream |
	date := Dialect newDateWithYears: 1997 months: 11 days: 14.
	stream := WriteStream on: String new.
	date glorpPrintSQLOn: stream.
	self assert: stream contents = '''1997-11-14'''.

	date := Dialect newDateWithYears: 2002 months: 5 days: 2.
	stream := WriteStream on: String new.
	date glorpPrintSQLOn: stream.
	self assert: stream contents = '''2002-05-02'''.
]

{ #category : #tests }
GlorpSQLPrintingTest >> testGroupWriting [
	"Oracle does not group-write:  when binding, it says it does solely to take the code path that leads to array buinding.  We therefore do not test Oracle here."

	| platform |
	platform := PostgreSQLPlatform new.
	platform useBinding: false.
	self assertGroupWritingOnPlatform: platform.

	platform := SQLServerPlatform new.
	platform useBinding: false.
	self assertGroupWritingOnPlatform: platform.
	platform := SQLServerPlatform new.
	platform useBinding: true.
	self assertGroupWritingOnPlatform: platform.
]

{ #category : #tests }
GlorpSQLPrintingTest >> testGroupWritingInsertCommandSQL [
	"Oracle never writes groups of statements:  in Oracle, a multi-row insert statement uses a single SQL expression followed by either an array of bound values or (if not binding) a sequence of individual unbound values.  The other platforms support combinations of {bound|unbound}Statements and/or of a single statement followed by {bound|unbound}Values and/or followed by an array of bound values (unless they do not support any kind of grouping in which case only a solo statement can be tested - see #testUngroupedInsertCommandSQL).
	In some cases, what the server will accept depends on its version.  The default values must use the functionally-safe approach (e..g no group writing, or grouped statements not values).  This test fakes up an accessor with connection to send #postLoginInitializeFromAccessor: so it can test Glorp's exploitation of the abilities of newer servers."


	| platform unboundStatements unboundValues boundStatements boundValues boundArray mockAccessor |
	unboundStatements := 'INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (1,NULL,NULL); INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (2,NULL,NULL)'.
	boundStatements := 'INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (?,?,?); INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (?,?,?)'.
	unboundValues := 'INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (1,NULL,NULL), (2,NULL,NULL)'.
	boundValues := 'INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (?,?,?), (?,?,?)'.
	boundArray := 'INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (?,?,?)'.

	mockAccessor := GlorpMockAccessor new connection: PostgresSocketConnection new.
	mockAccessor connection activeParameters
		at: 'standard_conforming_strings' put: 'on';
		at: 'server_version' put: '8.2'.

	platform := PostgresSocketPlatform new useBinding: false.
	self assertGroupWritingOnPlatform: platform printsSQL: unboundStatements.
	platform := PostgresSocketPlatform new useBinding: false; postLoginInitializeFromAccessor: mockAccessor.
	self assertGroupWritingOnPlatform: platform printsSQL: unboundValues.
	platform := PostgresSocketPlatform new useBinding: true; postLoginInitializeFromAccessor: mockAccessor.
	self assertGroupWritingOnPlatform: platform printsSQL: boundValues.

	platform := PostgresLibpqPlatform new useBinding: false.
	self assertGroupWritingOnPlatform: platform printsSQL: unboundStatements.
	platform := PostgresLibpqPlatform new useBinding: true.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	"If our mock accessor returned #(('on')) instead of #((3)) to executeSQLString:, we could skip setting the instVar above."
	platform postLoginInitializeFromAccessor: mockAccessor.
	self assertGroupWritingOnPlatform: platform printsSQL: boundValues.

	"Check the test raises a failure if we try to test group writing when it should not be allowed."
	mockAccessor connection activeParameters at: 'server_version' put: '8.1'.
	platform := PostgresSocketPlatform new useBinding: true; postLoginInitializeFromAccessor: mockAccessor.
	self deny: (self twoRowInsertCommandForPlatform: platform) shouldUseGroupWriting
		description: 'PostgresSocketPlatform on old server trying to group-write when bound'
		resumable: true.
	"We reuse the mockAccessor, exploiting the fact that the libpq connection and the socket connection both understand #serverVersion."
	platform := PostgresLibpqPlatform new useBinding: true.
	platform postLoginInitializeFromAccessor: mockAccessor.
	self deny: (self twoRowInsertCommandForPlatform: platform) shouldUseGroupWriting
		description: 'PostgresLibpqPlatform on old server trying to group-write when bound'
		resumable: true.

	platform := SQLServerPlatform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertGroupWritingOnPlatform: platform printsSQL: unboundValues.
	platform := SQLServerPlatform new useBinding: true.
	self assertGroupWritingOnPlatform: platform printsSQL: boundArray.
	platform := SQLServerPlatform new useBinding: false.
	self assertGroupWritingOnPlatform: platform printsSQL: unboundStatements.

	platform := OraclePlatform new useBinding: true.
	self assertGroupWritingOnPlatform: platform printsSQL: boundArray.
	platform := OraclePlatform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self
		assertGroupWritingOnPlatform: platform
		printsSQL: 'INSERT ALL INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (1,NULL,NULL) INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (2,NULL,NULL) SELECT * FROM DUAL'.

	platform := DB2Platform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertGroupWritingOnPlatform: platform printsSQL: unboundValues.
	platform := DB2Platform new useBinding: true.
	self assertGroupWritingOnPlatform: platform printsSQL: boundArray.

	platform := MySQLPlatform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertGroupWritingOnPlatform: platform printsSQL: unboundValues.
	platform := MySQLPlatform new useBinding: true.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertGroupWritingOnPlatform: platform printsSQL: boundValues.

	platform := SQLite3Platform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertGroupWritingOnPlatform: platform printsSQL: unboundValues.
	platform := SQLite3Platform new useBinding: true.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertGroupWritingOnPlatform: platform printsSQL: boundValues.
]

{ #category : #tests }
GlorpSQLPrintingTest >> testGroupWritingUpdateCommandSQL [
	"Oracle and DB2 support array binding but not statement batching, so they can only group-write bound updates..  PostgreSocket supports statement batching but only for unbound statements, so can never writes groups of updates bound.  SQLServer supports array binding and statement batching, so can group-write both bound and unbound updates.  Array-bound updates share the same SQL statement so, the rows of a multi-row update command must be subdivided into subgroups of rows with values for the same subset of fields and only these subgroups can be group-written.  Batched update statements do not have this limitation."

	| platform unboundStatements boundArrayAll mockAccessor |
	unboundStatements := #('UPDATE GR_ADDRESS SET STREET = ''Privet Drive'',HOUSE_NUM = ''4'' WHERE ID = 1; UPDATE GR_ADDRESS SET STREET = ''Baker Street'' WHERE ID = 2; UPDATE GR_ADDRESS SET STREET = ''Coven Street'' WHERE ID = 3; UPDATE GR_ADDRESS SET HOUSE_NUM = ''221b'' WHERE ID = 4; UPDATE GR_ADDRESS SET HOUSE_NUM = ''7'' WHERE ID = 5; UPDATE GR_ADDRESS SET HOUSE_NUM = ''12'' WHERE ID = 6').
	boundArrayAll :=
		#('UPDATE GR_ADDRESS SET STREET = ?,HOUSE_NUM = ? WHERE ID = ?'
		'UPDATE GR_ADDRESS SET STREET = ? WHERE ID = ?'
		'UPDATE GR_ADDRESS SET HOUSE_NUM = ? WHERE ID = ?').

	mockAccessor := GlorpMockAccessor new connection: PostgresSocketConnection new.
	mockAccessor connection activeParameters
		at: 'standard_conforming_strings' put: 'on';
		at: 'server_version' put: '9.4.4'.

	platform := PostgresSocketPlatform new useBinding: false.
	self assertGroupUpdatingOnPlatform: platform printsSQLs: unboundStatements.
	platform := PostgresSocketPlatform new useBinding: false; postLoginInitializeFromAccessor: mockAccessor.
	self assertGroupUpdatingOnPlatform: platform printsSQLs: unboundStatements.
	platform := PostgresLibpqPlatform new useBinding: false.
	self assertGroupUpdatingOnPlatform: platform printsSQLs: unboundStatements.
	"We reuse the mockAccessor, exploiting the fact that the libpq connection and the socket connection both understand #serverVersion."
	platform := PostgresLibpqPlatform new useBinding: false; postLoginInitializeFromAccessor: mockAccessor.
	self assertGroupUpdatingOnPlatform: platform printsSQLs: unboundStatements.

	"Check the test raises a failure if we try to test group writing when it should not be allowed."
	platform := PostgresSocketPlatform new useBinding: true; postLoginInitializeFromAccessor: mockAccessor.
	self deny: (self sixRowUpdateCommandForPlatform: platform) shouldUseGroupWriting
		description: 'PostgresSocketPlatform trying to group-write updates when bound'
		resumable: true.
	"We reuse the mockAccessor, exploiting the fact that it's now set and both libpq and socket connection understand #serverVersion."
	platform := PostgresLibpqPlatform new useBinding: true.
	platform postLoginInitializeFromAccessor: mockAccessor.
	self deny: (self sixRowUpdateCommandForPlatform: platform) shouldUseGroupWriting
		description: 'PostgresLibpqPlatform trying to group-write updates when bound'
		resumable: true.

	platform := SQLServerPlatform new useBinding: false.
	self assertGroupUpdatingOnPlatform: platform printsSQLs: unboundStatements.
	platform := SQLServerPlatform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.	"just to check this has no effect"
	self assertGroupUpdatingOnPlatform: platform printsSQLs: unboundStatements.
	platform := SQLServerPlatform new useBinding: true.
	self assertGroupUpdatingOnPlatform: platform printsSQLs: boundArrayAll.

	platform := OraclePlatform new useBinding: true.
	self assertGroupUpdatingOnPlatform: platform printsSQLs: boundArrayAll.

	platform := DB2Platform new useBinding: true.
	self assertGroupUpdatingOnPlatform: platform printsSQLs: boundArrayAll.
]

{ #category : #tests }
GlorpSQLPrintingTest >> testGroupWritingWithIdentityColumn [
	"When a row is inserted into a table with a serial-type column, some servers post-assign the id value, i.e. the id is a _result_ of inserting a row and so cannot easily be known beforehand.  Glorp needs to know such ids to maintain the map between an object and row(s) written for it.  This can complicate group-writing insert statements:  if the table has a serial type and the platform uses identity columns, either a post-insert query to discover the ids must be wrapped into a grouped insert, or individual inserts, immediately succeeded by post-insert query for the id, are needed.  See #postWriteAssignSequencesUsing: versus #preWriteAssignSequencesUsing: and their call chain."

	| platform unboundValues boundArray |
	unboundValues := 'DECLARE @TableOfIdentities TABLE (IdentValue INT); INSERT INTO ITINERARY (RES_ID)  OUTPUT Inserted.ID INTO @TableOfIdentities(IdentValue)  VALUES (4), (5); SELECT IdentValue FROM @TableOfIdentities ORDER BY IdentValue'.
	boundArray := 'DECLARE @TableOfIdentities TABLE (IdentValue INT); INSERT INTO ITINERARY (RES_ID)  OUTPUT Inserted.ID INTO @TableOfIdentities(IdentValue)  VALUES (?); SELECT IdentValue FROM @TableOfIdentities ORDER BY IdentValue'.

	platform := SQLServerPlatform new useBinding: true.
	self assertGroupWritingIdentityOnPlatform: platform printsSQL: boundArray.
	platform := SQLServerPlatform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertGroupWritingIdentityOnPlatform: platform printsSQL: unboundValues.
	platform := SQLServerPlatform new useBinding: false.
	self deny: (self twoRowIdentityInsertCommandForPlatform: platform) shouldUseGroupWriting
		description: ('Old versions of <1s> <2?Bound:Unbound> should not attempt to group-write rows with identity column'
				expandMacrosWith: platform class name
				with: platform useBinding).
]

{ #category : #tests }
GlorpSQLPrintingTest >> testNonGroupWritingInsertCommandSQL [
	"The platform instances below do not currently support group writing.  If any become able to group-write, move them from this test to testGroupWriting."

	| platform |
	platform := OraclePlatform new useBinding: false.	"by default, assumes old version so not writing value sequences"
	self assertNonGroupWritingOnPlatform: platform.

	platform := DB2Platform new useBinding: false.
	self assertNonGroupWritingOnPlatform: platform.

	platform := MySQLPlatform new useBinding: false.
	self assertNonGroupWritingOnPlatform: platform.
	platform := MySQLPlatform new useBinding: true.
	self assertNonGroupWritingOnPlatform: platform.

	platform := SQLite3Platform new useBinding: false.
	self assertNonGroupWritingOnPlatform: platform.
	platform := SQLite3Platform new useBinding: true.
	self assertNonGroupWritingOnPlatform: platform.

	platform := FirebirdPlatform new useBinding: false.
	self assertNonGroupWritingOnPlatform: platform.
	platform := FirebirdPlatform new useBinding: true.
	self assertNonGroupWritingOnPlatform: platform.

	platform := AccessPlatform new useBinding: false.
	self assertNonGroupWritingOnPlatform: platform.
	platform := AccessPlatform new useBinding: true.
	self assertNonGroupWritingOnPlatform: platform.
]

{ #category : #tests }
GlorpSQLPrintingTest >> testNonGroupWritingUpdateCommandSQL [
	"The platform instances below do not currently support group writing of update commands.  If any become able to group-write updates, move them from this test to testGroupWriting."

	| platform |
	platform := OraclePlatform new useBinding: false.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := OraclePlatform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertNonGroupUpdatingOnPlatform: platform.

	platform := DB2Platform new useBinding: false.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := DB2Platform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertNonGroupUpdatingOnPlatform: platform.

	platform := PostgresSocketPlatform new useBinding: true.
	self assertNonGroupUpdatingOnPlatform: platform.

	platform := MySQLPlatform new useBinding: false.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := MySQLPlatform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := MySQLPlatform new useBinding: true.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := MySQLPlatform new useBinding: true.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertNonGroupUpdatingOnPlatform: platform.

	platform := SQLite3Platform new useBinding: false.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := SQLite3Platform new useBinding: false.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := SQLite3Platform new useBinding: true.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := SQLite3Platform new useBinding: true.
	platform instVarNamed: 'supportsGroupWritingValues' put: true.
	self assertNonGroupUpdatingOnPlatform: platform.

	platform := FirebirdPlatform new useBinding: false.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := FirebirdPlatform new useBinding: true.
	self assertNonGroupUpdatingOnPlatform: platform.

	platform := AccessPlatform new useBinding: false.
	self assertNonGroupUpdatingOnPlatform: platform.
	platform := AccessPlatform new useBinding: true.
	self assertNonGroupUpdatingOnPlatform: platform.
]

{ #category : #tests }
GlorpSQLPrintingTest >> testNonGroupWritingWithIdentityColumn [
	"The platform instances below do not currently support group writing.  If any become able to group-write, move them from this test to testGroupWriting."

	| platform command requiredStrings actualStrings |
	platform := SQLServerPlatform new useBinding: false.
	command := self twoRowIdentityInsertCommandForPlatform: platform.
	self deny: command shouldUseGroupWriting
		description: ('Old SQLServerPlatform unbound should not group-write multi-row <1s>'
					expandMacrosWith: command class name).
	requiredStrings := OrderedCollection
		with: 'INSERT INTO ITINERARY (RES_ID)  VALUES (4); SELECT SCOPE_IDENTITY()'
		with: 'INSERT INTO ITINERARY (RES_ID)  VALUES (5); SELECT SCOPE_IDENTITY()'.
	actualStrings := OrderedCollection new.	"Mimic the first lines of execute{Unbound|Bound}In: to test non-group writing"
	(command hasMultipleRows and: [command shouldUseGroupWriting not]) ifTrue:
		[command allRowsSinglyEvaluate: [actualStrings add: command sqlString]].
	actualStrings with: requiredStrings do:
		[:actualString :requiredString |
		self
			assert: actualString = requiredString
			description: ('Inserting ungrouped row to <1s> <2?Bound:Unbound> wrote <3s> instead of expected <4s>'
						expandMacrosWith: platform class name
						with: platform useBinding
						with: actualString
						with: requiredString)
			resumable: true].
]

{ #category : #'utilities-insert' }
GlorpSQLPrintingTest >> twoRowIdentityInsertCommandForPlatform: aDatabasePlatform [
	"A trivial multi-row insert command for testing group writing.  Make the command use binding if the platform instance is configured to use binding."

	| row1 row2 session system |
	session := GlorpDemoDescriptorSystem sessionForLogin: (Login new database: aDatabasePlatform).
	system := session system.
	row1 := DatabaseRow newForTable: (system tableNamed: 'ITINERARY').
	row1 atFieldNamed: 'RES_ID' put: 4.
	row2 := DatabaseRow newForTable: (system tableNamed: 'ITINERARY').
	row2 atFieldNamed: 'RES_ID' put: 5.
	^session platform
		insertCommandForRows: (Array with: row1 with: row2)
		binding: session useBinding
		session: session
]

{ #category : #'utilities-insert' }
GlorpSQLPrintingTest >> twoRowInsertCommandForPlatform: aDatabasePlatform [
	"A trivial multi-row insert command for testing group writing."

	| row1 row2 session system |
	session := GlorpDemoDescriptorSystem sessionForLogin: (Login new database: aDatabasePlatform).
	system := session system.
	row1 := DatabaseRow newForTable: (system tableNamed: 'GR_ADDRESS').
	row1 atFieldNamed: 'ID' put: 1.
	row2 := DatabaseRow newForTable: (system tableNamed: 'GR_ADDRESS').
	row2 atFieldNamed: 'ID' put: 2.
	^session platform
		insertCommandForRows: (Array with: row1 with: row2)
		binding: session useBinding
		session: session
]
