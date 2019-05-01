"
Implements firebird sequence generation by calling out to gen_id()


"
Class {
	#name : #FirebirdSequence,
	#superclass : #NamedSequence,
	#category : #GlorpDatabase
}

{ #category : #public }
FirebirdSequence >> creationString [

	^'create generator ' , self qualifiedName.
]

{ #category : #sequencing }
FirebirdSequence >> dropString [
	^'DELETE FROM RDB$GENERATORS
        WHERE RDB$GENERATOR_NAME=''', self qualifiedName, ''''.
]

{ #category : #sequencing }
FirebirdSequence >> getSequenceValueFromDatabaseFor: aDatabaseField in: aDatabaseRow using: anAccessor [ 
	| statement rows pk |
	statement := 'select gen_id(' , self qualifiedName 
				, ',1) from rdb$database'.
	rows := anAccessor executeSQLString: statement.
	pk := rows first first.
	aDatabaseRow at: aDatabaseField put: pk
]

{ #category : #sequencing }
FirebirdSequence >> postWriteAssignSequenceValueFor: aField in: aRow using: anAccessor [
]

{ #category : #'As yet unclassified' }
FirebirdSequence >> reserveViaBackupMechanism: anInteger in: aSession [
	"For interbase, the generator mechanism should always work"
	self error: 'This should never happen'.
]

{ #category : #sequencing }
FirebirdSequence >> reserveViaTableSelect: anInteger in: aSession for: aTable [
	"Interbase returns the top of the generated range in a single row. Do the iteration ourselves"
	| rows command max |
	command := self
		tableSelectCommandFor: aTable
		in: aSession
		reserving: anInteger.
	command parameters: (Array with: anInteger).
	command useBinding: false.
	rows := aSession accessor executeCommand: command.
	max := rows first first.
	max - anInteger + 1 to: max do: [:i | self reservedNumbers add: i].
]
