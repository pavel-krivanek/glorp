"
This is a platform for the socket protocol 3 API of the PostgreSQL database.

Instance Variables:
	canRecurse	<Boolean>	is recursive SQL supported
	supportsGroupWritingValues	<Boolean>	can a single INSERT statement be followed by multiple VALUES
"
Class {
	#name : #PostgresSocketPlatform,
	#superclass : #PostgresPlatform,
	#instVars : [
		'supportsGroupWritingValues',
		'canRecurse'
	],
	#category : #GlorpDatabase
}

{ #category : #accessing }
PostgresSocketPlatform class >> kind [
	^'Postgres Socket'
]

{ #category : #'VisualWorks metadata' }
PostgresSocketPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #testing }
PostgresSocketPlatform >> canRecurse [
	^canRecurse
]

{ #category : #'initialize-release' }
PostgresSocketPlatform >> initialize [
	"I have supported group writing since version 8.2 and recursion since 8.4.  For safety, we initialize to false, resetting in postLoginInitializeFromAccessor:."

	super initialize.
	canRecurse := false.
	supportsGroupWritingValues := false.
]

{ #category : #commands }
PostgresSocketPlatform >> insertCommandForRows: aCollectionOfDatabaseRows binding: aBoolean session: aSession [
	"When unbound, Postgres can group ;-separated INSERT statements or (in 8.2 and after) ,-separated values following a single INSERT statement.  When bound, only the latter works.  We group using values in both cases, because we must when bound and to minimise the length of the round-trip SQL when unbound."

	^(self supportsGroupWritingValues ifFalse: [InsertCommand] ifTrue: [InsertMultiValuesCommand])
		forRows: aCollectionOfDatabaseRows
		useBinding: aBoolean
		session: aSession
]

{ #category : #'conversion-strings' }
PostgresSocketPlatform >> postLoginInitializeFromAccessor: aDatabaseAccessor [
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
PostgresSocketPlatform >> supportsGroupWritingFor: aCommand [
	"I can group statements unbound.  If the serverVersion is 8.2 or newer, I can also group bound (or unbound) values following a single insert statement."

	^(super supportsGroupWritingFor: aCommand) and:
		[self useBinding not or: [aCommand supportsGroupWritingValues]]
]

{ #category : #testing }
PostgresSocketPlatform >> supportsGroupWritingValues [
	"Postgres versions earlier than 8.2 do not support a single INSERT statement followed by multiple VALUES statements;  read the version after login and cache whether the specific database installation that I represent does or not."

	^supportsGroupWritingValues ifNil: [false]	"false is functionally safe, just slower"
]

{ #category : #testing }
PostgresSocketPlatform >> supportsMultipleOpenCursors [
	"I appear to support interleaved readihg from two or more cursors on the same connection only because the EXDI layer connection buffers an executing session whenever another session asks to execute on the same connection."

	^true
]

{ #category : #accessing }
PostgresSocketPlatform >> vwEXDIConnectionClass [
	^'PostgresSocketConnection' asQualifiedReference valueIfUndefinedLoadFrom: 'PostgreSQL3EXDI'
]
