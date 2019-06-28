"
This is a platform for the libpq C protocol 3 API of the open-source PostgreSQL database.

Instance Variables:
	canRecurse	<Boolean>	is recursive SQL supported
	supportsGroupWritingValues	<Boolean>	can a single INSERT statement be followed by multiple VALUES
"
Class {
	#name : #PostgresLibpqPlatform,
	#superclass : #PostgresPlatform,
	#instVars : [
		'supportsGroupWritingValues',
		'canRecurse'
	],
	#category : #GlorpDatabase
}

{ #category : #accessing }
PostgresLibpqPlatform class >> kind [
	^'Postgres via Libpq I/F'
]

{ #category : #'VisualWorks metadata' }
PostgresLibpqPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #testing }
PostgresLibpqPlatform >> canRecurse [
	^canRecurse
]

{ #category : #'initialize-release' }
PostgresLibpqPlatform >> initialize [
	"I have supported group writing since version 8.2 and recursion since 8.4.  For safety, we initialize to false, resetting in postLoginInitializeFromAccessor:."

	super initialize.
	canRecurse := false.
	supportsGroupWritingValues := false.
]

{ #category : #commands }
PostgresLibpqPlatform >> insertCommandForRows: aCollectionOfDatabaseRows binding: aBoolean session: aSession [
	"When unbound, Postgres can group ;-separated INSERT statements or (in 8.2 and after) ,-separated values following a single INSERT statement.  When bound, only the latter works.  We group using values in both cases, because we must when bound and to minimise the length of the round-trip SQL when unbound."

	^(self supportsGroupWritingValues ifFalse: [InsertCommand] ifTrue: [InsertMultiValuesCommand])
		forRows: aCollectionOfDatabaseRows
		useBinding: aBoolean
		session: aSession
]

{ #category : #'conversion-strings' }
PostgresLibpqPlatform >> postLoginInitializeFromAccessor: aDatabaseAccessor [
	| standardConformingStrings dbmsVersion |
	charactersThatNeedEscaping isNil ifFalse: [^self].	"All values are set first time round, so we need only check one."
	"Only the VWDatabaseAccessor calls this method at the moment, so we need not check
	Dialect isVisualWorks ifFalse: [^super postLoginInitializeFromAccessor: aDatabaseAccessor]."
	standardConformingStrings := aDatabaseAccessor connection standardConformingStrings.
	standardConformingStrings = 'on'
		ifTrue: [charactersThatNeedEscaping := '''']	"escape single quote characters only"
		ifFalse: [charactersThatNeedEscaping := '''\'].	"escape single quote and backslash"
	dbmsVersion := aDatabaseAccessor connection serverVersion tokensBasedOn: $..
	supportsGroupWritingValues := self isVersion: #(8 2) notNewerThan: dbmsVersion.
	canRecurse := self isVersion: #(8 4) notNewerThan: dbmsVersion.
]

{ #category : #testing }
PostgresLibpqPlatform >> supportsGroupWritingFor: aCommand [
	"I can group statements unbound.  If the serverVersion is 8.2 or newer, I can also group bound (or unbound) values following a single statement.  If the command needsRowCount then the clause in supportsRowCount: i.e. aCommand expectedNumberOfModifiedRows < 2 can never be true in this method, since it must be greater than one to pass the #shouldUseGroupWriting call's check of hasMultipleRows."

	^(super supportsGroupWritingFor: aCommand) and:
		[aCommand supportsGroupWritingValues or:
			[self useBinding not and: [aCommand needsRowCount not and: [aCommand class ~= ReturningUpdateCommand]]]]
]

{ #category : #testing }
PostgresLibpqPlatform >> supportsGroupWritingValues [
	"Postgres versions earlier than 8.2 do not support a single INSERT statement followed by multiple VALUES statements;  read the version after login and cache whether the specific database installation that I represent does or not."

	^supportsGroupWritingValues ifNil: [false]	"false is functionally safe, just slower"
]

{ #category : #testing }
PostgresLibpqPlatform >> supportsMultipleOpenCursors [
	"To be reviewed."

	^false
]

{ #category : #testing }
PostgresLibpqPlatform >> supportsRowCountFor: aRowBasedCommand [
	"If libpq is not bound then it can send batched statements to te server but will only return the result set and rowCount of the last statement in the batch.  Thus its rowCount is unreliable when unbound if more than one statement is involved: a batch of several attempted UPDATEs wil return a rowCount of 0 or 1 for the last UPDATE only.  (By contrast, PostgresSocket returns a result set - which may be just #noAnswerStream - for each statement in a batch, so the rowCounts can be queried and aggregated.)"

	^(self useBinding and: [aRowBasedCommand useBinding])
		or: [aRowBasedCommand expectedNumberOfModifiedRows < 2]
]

{ #category : #accessing }
PostgresLibpqPlatform >> vwEXDIConnectionClass [
	^'PostgresLibpqConnection' asQualifiedReference valueIfUndefinedLoadFrom: 'PostgreSQL3EXDI'
]
