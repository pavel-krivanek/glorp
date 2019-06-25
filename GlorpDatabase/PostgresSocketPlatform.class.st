"
This is a platform for the socket protocol 3 API of the PostgreSQL database.

"
Class {
	#name : #PostgresSocketPlatform,
	#superclass : #PostgresPlatform,
	#instVars : [
		'supportsGroupWritingValues'
	],
	#category : #GlorpDatabase
}

{ #category : #accessing }
PostgresSocketPlatform class >> kind [
	^'Postgres Socket'
]

{ #category : #'VisualWorks metadata' }
PostgresSocketPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
