"
This implements postgresql sequences using nextVal. The mechanism is similar to Oracle sequences, but we don't have to give it a table to select against when all we want is a bunch of numbers, so the implementation is simpler.
"
Class {
	#name : #PGSequence,
	#superclass : #NamedSequence,
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #'VisualWorks metadata' }
PGSequence class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #SQL }
PGSequence >> getSequenceValueFromDatabaseFor: aDatabaseField in: aDatabaseRow using: anAccessor [

	| statement rows pk |

	"this could be made smarter by aggregating keys to fetch into a single sql query - maybe later -tb"
	statement := 'select nextval(''',  self qualifiedName, ''')'.

	rows := anAccessor executeSQLString: statement.
	pk := rows first first.

	aDatabaseRow at: aDatabaseField put: pk.
]

{ #category : #SQL }
PGSequence >> postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: anAccessor [

"No-op;  for user information, we show, commented, the code that was provided here circa Glorp 0.2.*.
	aDatabaseRow at: aDatabaseField
		put: (aSession accessor 
				executeSQLString: 'SELECT CURRVAL(' , self qualifiedName 	, ')')."
]

{ #category : #SQL }
PGSequence >> reserveViaBackupMechanism: anInteger in: aSession [
	"The regular mechanism didn't work, (probably because there weren't enough rows in the table), try a different technique."

	| command row |
	command := self backupReserveCommand: anInteger in: aSession.
	row := (aSession accessor executeCommand: command) first.
	self reservedNumbers addAll: row.
]

{ #category : #SQL }
PGSequence >> tableToSelectFromIn: session for: aTable [
	"Sometimes it's inefficient to select sequence values against our own table and we can use a database-specific system table instead to be much faster. Subclasses can override where this is the case"
	^(session databaseTableClass named: 'pg_attribute').
]
