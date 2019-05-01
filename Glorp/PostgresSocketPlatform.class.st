"
This is a platform for the socket protocol 3 API of the PostgreSQL database.

"
Class {
	#name : #PostgresSocketPlatform,
	#superclass : #PostgresPlatform,
	#instVars : [
		'supportsGroupWritingValues'
	],
	#category : #'Glorp-Database'
}

{ #category : #accessing }
PostgresSocketPlatform class >> kind [
	^'Postgres Socket'
]
