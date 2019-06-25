"
The database accessor subclass for Dolphin Smalltalk.
"
Class {
	#name : #DolphinDatabaseAccessor,
	#superclass : #DatabaseAccessor,
	#category : #GlorpDatabase
}

{ #category : #'VisualWorks metadata' }
DolphinDatabaseAccessor class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
DolphinDatabaseAccessor >> basicExecuteSQLString: aString [
	| resultSet array |
	self log: aString.
	self logOnly ifTrue: [^self].
	resultSet := connection query: aString.	"Write statements don't like asArray if there's not result. DDL statements don't even like the isEmpty test"
	array := [resultSet isEmpty ifTrue: [#()] ifFalse: [resultSet asArray]]
		on: Dialect error
		do: [:ex | ex return: #()].
	resultSet
		close;
		free.
	^ReadStream on: array read.
]

{ #category : #transactions }
DolphinDatabaseAccessor >> beginTransaction [

	connection beginRWTxn.
]

{ #category : #transactions }
DolphinDatabaseAccessor >> commitTransaction [
	self log: 'Commit Transaction'.
	self logOnly ifTrue: [^self].
	connection commitTxn
]

{ #category : #executing }
DolphinDatabaseAccessor >> externalDatabaseErrorSignal [

	^Smalltalk at: #DBError
]

{ #category : #transactions }
DolphinDatabaseAccessor >> isInTransaction [

	^connection isInTransaction
]

{ #category : #accessing }
DolphinDatabaseAccessor >> isLoggedIn [

	^connection notNil.
]

{ #category : #login }
DolphinDatabaseAccessor >> loginIfError: aBlock [

	self
		execute:
			[connection := ((Smalltalk at: #DBConnection) new)
				dsn: currentLogin connectString;
				uid: currentLogin username;
				pwd: currentLogin password;
				connect.]
		ifError: aBlock
]

{ #category : #login }
DolphinDatabaseAccessor >> logout [

	connection notNil
		ifTrue:
			[[connection close.] ensure: [connection := nil]].
]

{ #category : #transactions }
DolphinDatabaseAccessor >> rollbackTransaction [
	self log: 'Rollback Transaction'.
	self logOnly ifTrue: [^self].
	connection rollbackTxn
]

{ #category : #login }
DolphinDatabaseAccessor >> showDialog: aString [

	(Smalltalk at: #MessageBox) warning: aString.
]
