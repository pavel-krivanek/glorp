"
This is a platform for Oracle, as accessed through ODBC. The database doesn't change, but at least in VW we determine which connection type to use based on the platform object, so we need to use an ODBC connection rather than an OCI connection.
"
Class {
	#name : #OracleODBCPlatform,
	#superclass : #OraclePlatform,
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #accessing }
OracleODBCPlatform class >> kind [
	^'Oracle ODBC Driver'
]

{ #category : #'VisualWorks metadata' }
OracleODBCPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #testing }
OracleODBCPlatform >> isODBCPlatform [

	^true.
]

{ #category : #login }
OracleODBCPlatform >> postLoginInitializeFromAccessor: aDatabaseAccessor [
	"Oracle has been supporting group writing with the VALUES clause at least since version 9.0.  A typical version string is: 'Oracle Database 11g Express Edition Release 11.2.0.2.0 - Production'."

	| dbmsVersion |
	dbmsVersion := aDatabaseAccessor connection dbmsVersion tokensBasedOn: $..
	supportsGroupWritingValues := dbmsVersion first asNumber > 9.
]

{ #category : #testing }
OracleODBCPlatform >> usesLengthNotEndPosInSubstring [
	^false
]
