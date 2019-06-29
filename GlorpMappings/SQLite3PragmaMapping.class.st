Class {
	#name : #SQLite3PragmaMapping,
	#superclass : #ToManyMapping,
	#category : #GlorpMappings
}

{ #category : #'VisualWorks metadata' }
SQLite3PragmaMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #mapping }
SQLite3PragmaMapping >> buildQuery [
	| toMany builtQuery |
	toMany := self attribute isCollectionAttribute.
	builtQuery := toMany
		ifTrue: [SQLite3PragmaQuery read: self referenceClass where: self join]
		ifFalse: [SQLite3PragmaQuery readOneOf: self referenceClass where: self join].
	builtQuery session: self session.
	builtQuery baseExpression descriptor: (self session descriptorFor: self referenceClass).
	builtQuery collectionType: self collectionType.
	self usesLinkTable ifTrue:
		[builtQuery AND: (self expressionFromLinkToReferenceTableWithBase: builtQuery baseExpression)].
	orderBy isNil ifFalse: [orderBy do: [:each | builtQuery orderBy: each]].
	^builtQuery
]

{ #category : #public }
SQLite3PragmaMapping >> setValueIn: anObject to: aValue [
	"This method serves as a hook to do special work for the collection objects, #fields and #foreignKeysData. It connects the objects to their owning tables (a SQLite3DatabaseTable object), and also resets the field type for a primary key field whose owning table has 'AUTOINCREMENT' declared for its pkey field. Such a field has type #serial. It would be nicer if that info were available elsewhere, but right now, this is where the table and field first meet (and where that info can now be shared)."

	| setValue |
	self canRead ifFalse: [^aValue].
	setValue := self attribute setValueIn: anObject to: aValue.
	self attribute name = #fields ifTrue:
		[aValue do:
			[:fld |
			fld table: anObject.
			fld isPrimaryKey ifTrue:
				[anObject hasAutoIncrement ifTrue: [fld type: self descriptor system platform serial]]]].
	self attribute name = #foreignKeysData ifTrue:
		[aValue do: [:fld | fld sourceTableName: anObject name]].
	^setValue
]
