Extension { #name : #DatabaseAccessor }

{ #category : #'*GlorpCore-obsolete' }
DatabaseAccessor >> createConstraint: aConstraint [
	^self addConstraint: aConstraint
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> denyReads [
	deniedCommands := SelectCommand allSubclasses.
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> denyWrites [
	deniedCommands := RowBasedCommand allSubclasses.
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> insertOnly [
	deniedCommands := Array with: UpdateCommand withAllSubclasses with: DeleteCommand.
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> permitEverything [
	"Note that nil is treated as a flag indicating that all commands are allowed"
	deniedCommands := nil.
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> permitEverythingDuring: aBlock [
	| oldCommands |
	oldCommands := self deniedCommands.
	self permitEverything.
	^aBlock ensure: [deniedCommands := oldCommands]
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> permitNothing [
	deniedCommands := DatabaseCommand allSubclasses asArray.
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> permitNothingDuring: aBlock [
	| oldCommands |
	oldCommands := self deniedCommands.
	self permitNothing.
	^aBlock ensure: [deniedCommands := oldCommands]
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> permitsInserts [
	deniedCommands isNil ifTrue: [^true].
	^(deniedCommands includes: InsertCommand) not.
]

{ #category : #'*GlorpCore-permissions' }
DatabaseAccessor >> permitsUpdates [
	deniedCommands isNil ifTrue: [^true].
	^(deniedCommands includes: UpdateCommand) not.
]
