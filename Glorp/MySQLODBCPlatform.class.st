Class {
	#name : #MySQLODBCPlatform,
	#superclass : #MySQLPlatform,
	#category : #'Glorp-Database'
}

{ #category : #accessing }
MySQLODBCPlatform class >> kind [
	^'MySQL ODBC Driver'
]

{ #category : #testing }
MySQLODBCPlatform >> isODBCPlatform [

	^true.
]
