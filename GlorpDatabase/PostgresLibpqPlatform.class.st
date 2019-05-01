"
This is a platform for the libpq C protocol 3 API of the open-source PostgreSQL database.

"
Class {
	#name : #PostgresLibpqPlatform,
	#superclass : #PostgresPlatform,
	#instVars : [
		'supportsGroupWritingValues'
	],
	#category : #GlorpDatabase
}

{ #category : #accessing }
PostgresLibpqPlatform class >> kind [
	^'Postgres via Libpq I/F'
]
