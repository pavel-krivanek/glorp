Class {
	#name : #MySQLODBCPlatform,
	#superclass : #MySQLPlatform,
	#category : #GlorpDatabase
}

{ #category : #accessing }
MySQLODBCPlatform class >> kind [
	^'MySQL ODBC Driver'
]

{ #category : #testing }
MySQLODBCPlatform >> isODBCPlatform [

	^true.
]
