Extension { #name : #DescriptorSystem }

{ #category : #'*GlorpDBTests-utility' }
DescriptorSystem classSide >> createTables [
	"Create the tables for this descriptor system. This will fail if the tables already exist. Use recreateTables for that."
	^self createTablesFor: GlorpDatabaseLoginResource current login.
]

{ #category : #'*GlorpDBTests-utility' }
DescriptorSystem classSide >> dropTables [
	"Drop and re-create the tables for this descriptor system."
	^self dropTablesFor: GlorpDatabaseLoginResource current login.
]

{ #category : #'*GlorpDBTests-utility' }
DescriptorSystem classSide >> recreateTables [
	"Drop and re-create the tables for this descriptor system."
	^self recreateTablesFor: GlorpDatabaseLoginResource current login.
]
