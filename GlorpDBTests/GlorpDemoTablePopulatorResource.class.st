Class {
	#name : #GlorpDemoTablePopulatorResource,
	#superclass : #TestResource,
	#instVars : [
		'login'
	],
	#classVars : [
		'GlorpDemoTablePopulatorResource'
	],
	#category : #'GlorpDBTests-GlorpTest'
}

{ #category : #setup }
GlorpDemoTablePopulatorResource class >> invalidateSetup [
	"GlorpDemoTablePopulatorResource invalidateSetup"

	NeedsSetup := true.
	self reset.
]

{ #category : #setup }
GlorpDemoTablePopulatorResource class >> needsSetup [
	NeedsSetup isNil ifTrue: [NeedsSetup := true].
	^NeedsSetup
]

{ #category : #setup }
GlorpDemoTablePopulatorResource class >> needsSetup: aBoolean [

	NeedsSetup := aBoolean.
]

{ #category : #setup }
GlorpDemoTablePopulatorResource class >> resources [

	^Array with: GlorpDatabaseLoginResource.
]

{ #category : #'VisualWorks metadata' }
GlorpDemoTablePopulatorResource class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'XProgramming.SUnit'
	)

]

{ #category : #setup }
GlorpDemoTablePopulatorResource >> populateStuffTable [
 
	login accessor executeSQLStringNoResult: 'INSERT INTO STUFF VALUES (12,''abc'')'.
	login accessor executeSQLStringNoResult: 'INSERT INTO STUFF VALUES (13, ''hey nonny nonny'')'.
	login accessor executeSQLStringNoResult: 'INSERT INTO STUFF VALUES (42, ''yabba dabba doo'')'.
	login accessor executeSQLStringNoResult: 'INSERT INTO STUFF VALUES (9625, ''the band played on'')'.
	login accessor executeSQLStringNoResult: 'INSERT INTO STUFF VALUES (113141, ''Smalltalk'')'.
]

{ #category : #setup }
GlorpDemoTablePopulatorResource >> setUp [
	super setUp.
	login := GlorpDatabaseLoginResource current.
	self class needsSetup ifFalse: [^self].
	login accessor doDDLOperation:
		[GlorpTestDescriptorSystem allSubclasses do:
			[:eachSystemClass |
			self setUpSystem: (eachSystemClass forPlatform: login platform) setUpDefaults].
		self populateStuffTable].
	self class needsSetup: false.
]

{ #category : #setup }
GlorpDemoTablePopulatorResource >> setUpSystem: system [
	"This coding suppresses dropping errors, to be robust to when running in a new database (shows drop errors because things ordered dropped are not there) and rerunning.  Sometimes drop errors can block running the tests (e.g. a table is dropped to which another table - undropped as not in this version - has a foreign key).  See end of method comment re debugging drop errors."

	| errorBlock |
	login accessor dropTables: ((TableSorter for: system allTables) sort reverse).
	errorBlock := [:ex | Transcript show: ex description; cr. ex pass].
	system platform areSequencesExplicitlyCreated ifTrue:
		[login accessor dropSequences: system allSequences.
		system allSequences do:
			[:each | login accessor createSequence: each ifError: errorBlock]].
	system allTables do:
		[:each | login accessor createTable: each ifError: errorBlock].
	system allTables do:
		[:each | login accessor createTableIndexes: each ifError: errorBlock].
	"SQLite3 doesn't support adding/dropping constraints."
	system platform supportsConstraints ifTrue:
		[system allTables do:
			[:each | login accessor createTableFKConstraints: each ifError: errorBlock]].

"To debug drop errors, try e.g.
	login accessor
		dropTables: ((TableSorter for: system allTables) sort reverse)
		ifError: [self halt. ex pass].
or
	login accessor
		logging: true;
		dropTables: ((TableSorter for: system allTables) sort reverse);
		endLogging."
]
