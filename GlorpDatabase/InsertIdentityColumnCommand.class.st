"
I insert one or more rows of a table that has an identityColumn, i.e. a column whose values are set by the server and must be recovered post-insert.

Instance variables

	identityColumn	<DatabaseField>	a column whose value for each row is set by the server during insertion of that row


"
Class {
	#name : #InsertIdentityColumnCommand,
	#superclass : #InsertMultiValuesCommand,
	#instVars : [
		'identityColumn'
	],
	#category : #GlorpDatabase
}

{ #category : #'instance creation' }
InsertIdentityColumnCommand class >> forRows: aCollectionOfDatabaseRows useBinding: aBoolean session: aSession ifNoIdentityColumn: anInsertCommandClass [
	| identityColumn |
	identityColumn := aCollectionOfDatabaseRows first table fields
		detect: [:each | each type isIdentityColumn]
		ifNone: [^anInsertCommandClass forRows: aCollectionOfDatabaseRows useBinding: aBoolean session: aSession].
	^(self forRows: aCollectionOfDatabaseRows useBinding: aBoolean session: aSession)
		identityColumn: identityColumn
]

{ #category : #'VisualWorks metadata' }
InsertIdentityColumnCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
InsertIdentityColumnCommand >> identityColumn: aDatabaseField [
	identityColumn := aDatabaseField.
]

{ #category : #executing }
InsertIdentityColumnCommand >> postWriteAssignSequencesUsing: anAccessor [
	"Ask the serial type how to assign multiple server-generated IDs to the IDENTITY column of my rows."

	identityColumn type
		postWriteAssignSequenceValueFor: identityColumn
		inRows: allRows
		using: anAccessor.
]
