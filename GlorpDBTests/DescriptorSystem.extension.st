Extension { #name : #DescriptorSystem }

{ #category : #'*GlorpDBTests' }
DescriptorSystem class >> createTables [
	"Create the tables for this descriptor system. This will fail if the tables already exist. Use recreateTables for that."
	^self createTablesFor: GlorpDatabaseLoginResource current login.
]

{ #category : #'*GlorpDBTests' }
DescriptorSystem class >> dropTables [
	"Drop and re-create the tables for this descriptor system."
	^self dropTablesFor: GlorpDatabaseLoginResource current login.
]

{ #category : #'*GlorpDBTests' }
DescriptorSystem class >> recreateTables [
	"Drop and re-create the tables for this descriptor system."
	^self recreateTablesFor: GlorpDatabaseLoginResource current login.
]
