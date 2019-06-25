Extension { #name : #PGSequence }

{ #category : #'*GlorpCore-private' }
PGSequence >> backupReserveCommand: anInteger in: aSession [
	| stream command |
	stream := WriteStream on: (String new: 200).
	stream nextPutAll: 'select '.
	GlorpHelper
		print: [:i | 'nextval(''' , self qualifiedName , ''')']
		on: stream
		for: (1 to: anInteger)
		separatedBy: ','.
	command := SQLStringSelectCommand new.
	command setSQLString: stream contents.
	command parameters: (Array with: anInteger).
	command session: aSession.
	^command.
]

{ #category : #'*GlorpCore-SQL' }
PGSequence >> tableSelectCommandFor: aTable in: aSession reserving: anInteger [
	| stream |
	(tableSelectCommand notNil and: [tableSelectCommand parameters includes: anInteger]) ifFalse:
			[stream := WriteStream on: (String new: 200).
			stream nextPutAll: 'select nextval('.
			self qualifiedName printOn: stream.
			stream nextPutAll: ') from ' , aTable name.
			stream nextPutAll: ' limit '.
			stream nextPutAll: (aSession useBinding ifTrue: ['?'] ifFalse: [anInteger printString]).
			tableSelectCommand := SQLStringSelectCommand new.
			tableSelectCommand parameters: (Array with: anInteger).
			tableSelectCommand setSQLString: stream contents.
			tableSelectCommand session: aSession].
	^tableSelectCommand.
]
