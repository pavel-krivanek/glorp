"
This is a sequence type for MySQL AutoIncrement fields.
"
Class {
	#name : #MySQLSequence,
	#superclass : #NamedSequence,
	#category : 'Glorp-Database'
}

{ #category : #sequencing }
MySQLSequence >> getSequenceValueFromDatabaseFor: aField in: aRow using: aSession [
]

{ #category : #testing }
MySQLSequence >> isIdentityColumn [
	^true.
]

{ #category : #sequencing }
MySQLSequence >> postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: anAccessor [
	"A zero value indicates either the INSERT failed, or there is no IDENTITY column in the insert:  either way, an error."

	| value |
	value := anAccessor connection lastAutoIncrementValue asInteger.
	value = 0 ifTrue: [self error: 'Bad IDENTITY column insert.'].
	^aDatabaseRow at: aDatabaseField put: value
]

{ #category : #sequencing }
MySQLSequence >> postWriteAssignSequenceValueFor: aDatabaseField inRows: someDatabaseRows using: anAccessor [
	| firstValue |
	firstValue := anAccessor connection lastAutoIncrementValue asInteger.
"The SQL equivalent to the above is
	(anAccessor executeSQLString: 'SELECT LAST_INSERT_ID()') first atIndex: 1.
We use the above to avoid the cost of a second round trip."
	someDatabaseRows do:
		[:ithrow |
		ithrow at: aDatabaseField put: firstValue.
		firstValue := firstValue + 1].
]

{ #category : #sequencing }
MySQLSequence >> reserveSequenceNumbers: anInteger in: aSession for: aTable [
	"No real sequences here, just identity columns, which we can't pre-allocate"
]
