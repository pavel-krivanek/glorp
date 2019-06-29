Extension { #name : #DescriptorSystem }

{ #category : #'*GlorpDBTests-utility' }
DescriptorSystem class >> createTables [
	"Create the tables for this descriptor system. This will fail if the tables already exist;  use recreateTables for that.  This returns the session used to create the tables (which will already be logged out, and may be discarded)."

	^self createTablesFor: GlorpDatabaseLoginResource current login
]

{ #category : #'*GlorpDBTests-utility' }
DescriptorSystem class >> dropTables [
	"Drop and re-create the tables for this descriptor system."
	^self dropTablesFor: GlorpDatabaseLoginResource current login.
]

{ #category : #'*GlorpDBTests-utility' }
DescriptorSystem class >> recreateTables [
	"Drop and re-create the tables for this descriptor system."
	^self recreateTablesFor: GlorpDatabaseLoginResource current login.
]
