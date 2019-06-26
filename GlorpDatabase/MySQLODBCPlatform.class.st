Class {
	#name : #MySQLODBCPlatform,
	#superclass : #MySQLPlatform,
	#category : #GlorpDatabase
}

{ #category : #accessing }
MySQLODBCPlatform class >> kind [
	^'MySQL ODBC Driver'
]

{ #category : #'VisualWorks metadata' }
MySQLODBCPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #testing }
MySQLODBCPlatform >> isODBCPlatform [

	^true.
]

{ #category : #login }
MySQLODBCPlatform >> postLoginInitializeFromAccessor: aDatabaseAccessor [
	"MySQL has been supporting group writing with the VALUES clause at least since version 5.0."

	| dbmsVersion |
	dbmsVersion := aDatabaseAccessor connection dbmsVersion tokensBasedOn: $..
	supportsGroupWritingValues := dbmsVersion first asNumber >= 5.
]
