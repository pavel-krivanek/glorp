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
