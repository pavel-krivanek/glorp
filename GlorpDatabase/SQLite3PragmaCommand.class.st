Class {
	#name : #SQLite3PragmaCommand,
	#superclass : #SQLStringSelectCommand,
	#category : #'GlorpDatabase-GlorpCore'
}

{ #category : #'VisualWorks metadata' }
SQLite3PragmaCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #sql }
SQLite3PragmaCommand >> printSQL [
	stream nextPutAll: 'PRAGMA '.
	query resultClass = DatabaseField
		ifTrue: [ stream nextPutAll: 'table_info (' ].
	query resultClass = SQLite3ForeignKeyData
		ifTrue: [ stream nextPutAll: 'foreign_key_list(' ].	"VW_TRANSLATION:Glorp.SQLite3ForeignKeyData:SQLite3ForeignKeyData"
	query resultClass = SQLite3IndexData
		ifTrue: [ stream nextPutAll: 'index_list(' ].	"VW_TRANSLATION:Glorp.SQLite3IndexData:SQLite3IndexData"
	query resultClass = SQLite3IndexColumnData
		ifTrue: [ stream nextPutAll: 'index_info(' ].	"VW_TRANSLATION:Glorp.SQLite3IndexColumnData:SQLite3IndexColumnData"
	"query printSelectFieldsOn: self."
	self findBoundExpressions.
	"query printTablesOn: self."
	query printWhereClauseOn: self.
	stream nextPutAll: ')'
	"query printJoinsOn: self.
	query printOrderingOn: self.
	query printGroupByOn: self.
	query printPostLimitOn: self.
	query printOffsetOn: self."
]
