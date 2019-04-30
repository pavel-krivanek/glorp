"
If my platform usesArrayBindingToGroupWrite and I useBinding, or I have only one row, then I am identical to my superclass.  In all other cases, I concatenate the values of my rows, so that instead of, for example,
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ( 'a', 'A', '1');
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ('b', 'B', '2');
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ('c', 'C', '3');
	...
or, if bound but not usesArrayBindingToGroupWrite,
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ( ?, ?, ?);
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ( ?, ?, ?);
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ( ?, ?, ?);
	...
I write what is technically a single command
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ( 'a', 'A', '1'), ('b', 'B', '2'), ('c', 'C', '3'). ...
or, if bound,
	INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM) VALUES ( ?, ?, ?), ( ?, ?, ?), ( ?, ?, ?). ...
"
Class {
	#name : #InsertMultiValuesCommand,
	#superclass : #InsertCommand,
	#category : #'Glorp-Database'
}

{ #category : #executing }
InsertMultiValuesCommand >> printConcatenatedValuesSQLFor: aRow [
	"Print the next row by concatenation, as in INSERT INTO table ... VALUES (row1), (row2), (row3).  Used in subclasses."

	| fields |
	fields := self arrayBoundFields.
	self nextPut: $(.
	GlorpHelper
		do:
			[:each |
			(self canBind: (aRow at: each ifAbsent: [nil]) to: each type)
				ifTrue: [self nextPutBindMarkerIn: nil]
				ifFalse: [aRow printValueOfField: each on: self]]
		for: fields
		separatedBy: [self nextPut: $,].
	self nextPut: $).
]

{ #category : #executing }
InsertMultiValuesCommand >> printSQLForNextRow: aRow [
	"For platforms where #usesArrayBindingToGroupWrite returns true, I will only be called if 'useBinding' is false."

	self nextPut: $,.
	self space.
	self printConcatenatedValuesSQLFor: aRow.
]

{ #category : #testing }
InsertMultiValuesCommand >> supportsGroupWritingValues [
	"The version of the INSERT command that can concatenate values onto a command (as one way of group-writing) is only supported by some database platforms in some versions.  If the platform does, it will create an instance of me, or of a subclass that supportsGroupWriting, when asked to insert.  Logically, this should be implemented as
	^self supportsGroupWriting
not just as true, but all callers will have already checked that."

	^true
]
