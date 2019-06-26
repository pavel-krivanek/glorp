"
I am only supported on Oracle as yet.  I can write bound or unbound rows to multiple tables in a single round trip, but am only used for unbound multiple row inserts to a single table as yet.  (My superclass handles bound inserts to a single table better, using array-binding.  Array binding is much faster than multi-value binding, e.g. three times faster, so only in the inhomogeneous rows case could I outperform array binding.  When running unbound, I will of course outperform my round-trip-per-row unbound rival, but Oracle is usually run bound whenever the dialect's external database interface to it supports binding.)

I concatenate the values of my rows, so that instead of, for example,
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ('a', 'A', '1');
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ('b', 'B', '2');
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ('c', 'C', '3');
	...
or, if bound,
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES (?, ?, ?);
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES (?, ?, ?);
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES (?, ?, ?);
	...
I write what is technically a single command
	INSERT ALL 
		INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ('a', 'A', '1')
		INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ('b', 'B', '2')
		INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ('c', 'C', '3')
		...
	SELECT * FROM DUAL
or, if bound
	INSERT ALL 
		INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES (?, ?, ? )
		INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES (?, ?, ? )
		INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES (?, ?, ? )
		...
	SELECT * FROM DUAL
I am indistinguishable from my superclass if there is only one row, and so am never created in that case;  my code assumes I have multiple rows.

I support inhomogeneous row grouping, e.g.
	INSERT ALL
		INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ( 'a', 'A', '1')
		INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ( 'b', 'B', '2')
		INTO GR_POSTOFFICE (ID,POSTCODE) VALUES ('1', 'A13 6BA')
		INTO GR_POSTOFFICE (ID,POSTCODE) VALUES ('2', 'A13 6BB')
		INTO GR_POSTOFFICE (ID,POSTCODE) VALUES ('3', 'A13 6BC')
		INTO GR_REGION (ID,LOCATION) VALUES (1000, 'Cornwall')
		INTO GR_REGION (ID,LOCATION) VALUES (1001, 'Devon')
		...
	SELECT * FROM DUAL
Glorp does not yet exploit this.
"
Class {
	#name : #InsertMultiValuesTablesCommand,
	#superclass : #InsertCommand,
	#category : #GlorpDatabase
}

{ #category : #'VisualWorks metadata' }
InsertMultiValuesTablesCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
InsertMultiValuesTablesCommand >> printSQL [
	"This command works bound or unbound but for performance reasons is only ever run unbound, ensured by Oracle returning true to #usesArrayBindingToGroupWrite;  that would have to return false (and OraclePlatform>>bindingsForGroupWriting would need to call #batchStatementBindings) for it to run bound.  As Oracle is bound by default, this command is seldom run."

	self nextPutAll: 'INSERT ALL '.
	super printSQL.
	self nextPutAll: ' SELECT * FROM DUAL'.
]

{ #category : #executing }
InsertMultiValuesTablesCommand >> printSQLForFirstRow: aRow [
	"This class can only be used if shouldUseGroupWriting is true, so code in the super implementation that checks that has been inlined to true here."

	| fields |
	self nextPutAll: 'INTO '.
	aRow table printSQLOn: self withParameters: #().
	fields := self arrayBoundFields.
	self space; nextPut: $(.
	GlorpHelper
		do: [:each | self nextPutAll: (self platform nameForColumn: each name)]
		for: fields
		separatedBy: [self nextPut: $,].
	self nextPut: $).
	self nextPutAll: '  VALUES ('.
	GlorpHelper
		do: [:each | (self canBind: (aRow at: each ifAbsent: [nil]) to: each type)
					ifTrue: [self nextPutBindMarkerIn: nil]
					ifFalse: [aRow printValueOfField: each on: self]]
		for: fields
		separatedBy: [self nextPut: $,].
	self nextPut: $).
]

{ #category : #executing }
InsertMultiValuesTablesCommand >> printSQLForNextRow: aRow [
	self space.
	self printSQLForFirstRow: aRow.
]

{ #category : #testing }
InsertMultiValuesTablesCommand >> supportsGroupWritingValues [
	"The version of the INSERT command that can concatenate values onto a command (as one way of group-writing) is only supported by some database platforms in some versions.  If the platform does, it will create an instance of me, or of a subclass that supportsGroupWriting, when asked to insert.  Logically, this should be implemented as
	^self supportsGroupWriting
not just as true, but all callers will have already checked that."

	^true
]
