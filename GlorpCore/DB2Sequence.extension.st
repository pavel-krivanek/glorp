Extension { #name : #DB2Sequence }

{ #category : #'*GlorpCore-private' }
DB2Sequence >> backupReserveCommand: anInteger in: aSession [
	"syscat.tables is a public view of all the tables.
	Don't bind the number in the fetch first nn clause."

	| command stream |
	stream := WriteStream on: (String new: 200).
	stream nextPutAll: 'select next value for '.
	stream nextPutAll: self qualifiedName.
	stream nextPutAll: ' from SYSCAT.TABLES'.
	stream nextPutAll: ' fetch first '.
	stream nextPutAll: anInteger printString.
	stream nextPutAll: ' rows only'.
	command := SQLStringSelectCommand new.
	command setSQLString: stream contents.
	command parameters: (Array with: anInteger).
	command session: aSession.
	^command.
]

{ #category : #'*GlorpCore-SQL' }
DB2Sequence >> tableSelectCommandFor: aTable in: aSession reserving: anInteger [
	"Don't bind the number in the fetch first nn clause."
	| stream |
	(tableSelectCommand notNil and: [tableSelectCommand parameters includes: anInteger]) ifFalse:
			[stream := WriteStream on: (String new: 200).
			stream nextPutAll: 'select next value for '.
			stream nextPutAll: self qualifiedName.
			stream nextPutAll: ' from '.
			stream nextPutAll: aTable name.
			stream nextPutAll: ' fetch first '.
			stream nextPutAll: anInteger printString.
			stream nextPutAll: ' rows only'.
			tableSelectCommand := SQLStringSelectCommand new.
			tableSelectCommand parameters: (Array with: anInteger).
			tableSelectCommand setSQLString: stream contents.
			tableSelectCommand blockFactor: anInteger.
			tableSelectCommand session: aSession].
	^tableSelectCommand.
]
