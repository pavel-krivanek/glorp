Extension { #name : #DatabaseAccessor }

{ #category : #'*GlorpCore' }
DatabaseAccessor >> createConstraint: aConstraint [
	^self addConstraint: aConstraint
]

{ #category : #'*GlorpCore' }
DatabaseAccessor >> denyReads [
	deniedCommands := SelectCommand allSubclasses.
]

{ #category : #'*GlorpCore' }
DatabaseAccessor >> denyWrites [
	deniedCommands := RowBasedCommand allSubclasses.
]

{ #category : #'*GlorpCore' }
DatabaseAccessor >> insertOnly [
	self denyCommands: (Array with: UpdateCommand with: DeleteCommand).
]

{ #category : #'*GlorpCore' }
DatabaseAccessor >> permitEverything [
	"Note that nil is treated as a flag indicating that all commands are allowed"
	deniedCommands := nil.
]

{ #category : #'*GlorpCore' }
DatabaseAccessor >> permitNothing [
	deniedCommands := DatabaseCommand allSubclasses asArray.
]

{ #category : #'*GlorpCore' }
DatabaseAccessor >> permitNothingDuring: aBlock [
	| oldCommands |
	oldCommands := self deniedCommands.
	self permitNothing.
	aBlock ensure: [deniedCommands := oldCommands].
]

{ #category : #'*GlorpCore' }
DatabaseAccessor >> permitsInserts [
	deniedCommands isNil ifTrue: [^true].
	^(deniedCommands includes: InsertCommand) not.
]

{ #category : #'*GlorpCore' }
DatabaseAccessor >> permitsUpdates [
	deniedCommands isNil ifTrue: [^true].
	^(deniedCommands includes: UpdateCommand) not.
]
