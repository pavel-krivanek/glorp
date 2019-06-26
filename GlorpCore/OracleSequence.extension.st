Extension { #name : #OracleSequence }

{ #category : #'*GlorpCore-private' }
OracleSequence >> backupReserveCommand: anInteger in: aSession [
	| command stream |
	stream := WriteStream on: (String new: 200).
	stream nextPutAll: 'select '.
	stream nextPutAll: self qualifiedName.
	stream nextPutAll: '.nextval from SYS.ALL_OBJECTS '.
	stream nextPutAll: ' WHERE rownum <= '.
	stream
		nextPutAll:
			(aSession useBinding ifTrue: ['?'] ifFalse: [anInteger printString]).
	command := SQLStringSelectCommand new.
	command setSQLString: stream contents.
	command parameters: (Array with: anInteger).
	command session: aSession.
	^command.
]

{ #category : #'*GlorpCore-SQL' }
OracleSequence >> tableSelectCommandFor: aTable in: aSession reserving: anInteger [
	| stream |
	(tableSelectCommand notNil and: [tableSelectCommand parameters includes: anInteger]) ifFalse:
			[stream := WriteStream on: (String new: 200).
			stream nextPutAll: 'select '.
			stream nextPutAll: self qualifiedName.
			stream nextPutAll: '.nextval from '.
			stream nextPutAll: aTable name.
			stream nextPutAll: ' WHERE rownum <= '.
			stream nextPutAll: (aSession useBinding ifTrue: ['?'] ifFalse: [anInteger printString]).
			tableSelectCommand := SQLStringSelectCommand new.
			tableSelectCommand parameters: (Array with: anInteger).
			tableSelectCommand setSQLString: stream contents.
			tableSelectCommand blockFactor: anInteger.
			tableSelectCommand session: aSession].
	^tableSelectCommand.
]
