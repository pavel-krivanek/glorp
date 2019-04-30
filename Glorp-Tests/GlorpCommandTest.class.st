Class {
	#name : #GlorpCommandTest,
	#superclass : #TestCase,
	#category : #'Glorp-Tests'
}

{ #category : #tests }
GlorpCommandTest >> testFieldsToUpdate [

	| command system row old bookTable session |
	session := GlorpLockingDescriptorSystem sessionForLogin: (Login new database: OraclePlatform new).
	system := session system.
	bookTable := system tableNamed: 'BOOK'.
	row := DatabaseRow newForTable: bookTable.
	old := DatabaseRow newForTable: bookTable.
	old at: (bookTable fieldNamed: 'ID') put: 6.
	old at: (bookTable fieldNamed: 'TITLE') put: 'ABook'.
	old at: (bookTable fieldNamed: 'DESCRIPTION') put: 'Stuff'.
	old at: (bookTable fieldNamed: 'COPIES_IN_STOCK') put: 3.
	old at: (bookTable fieldNamed: 'VERSION') put: 2.

	row at: (bookTable fieldNamed: 'ID') put: 6.
	row at: (bookTable fieldNamed: 'TITLE') put: 'ABook'.
	row at: (bookTable fieldNamed: 'DESCRIPTION') put: 'Stuff'.
	row at: (bookTable fieldNamed: 'COPIES_IN_STOCK') put: 4.
	row at: (bookTable fieldNamed: 'VERSION') put: 2.
	row withAllFieldsIn: old.
	command := UpdateCommand forRows: (Array with: row) useBinding: false session: session.
	self assert: command shouldUpdateOnlyChangedFields.
	self assert: command singleRowBoundFields size = 2.
	self assert: command singleRowBindings isEmpty. 
	command useBinding: true.
	self deny: command shouldUpdateOnlyChangedFields.
	self assert: command singleRowBoundFields size = 5.
	"The lock field is bound at the end"
	self assert: command singleRowBindings size = 6.
]

{ #category : #tests }
GlorpCommandTest >> testSplittingInserts1 [
	"Test both creation protocols on a single row."

	| rows command wasEvaluated assertBlock |
	 wasEvaluated := false.
	rows := Array with: DatabaseRow new.
	"The normal protocol for a single row."
	command := InsertCommand forRow: rows first useBinding: false session: nil.
	assertBlock :=
		[wasEvaluated := true.
		self assert: command row == rows first].
	command allRowsGrouped: 1000 evaluate: assertBlock.
	self assert: wasEvaluated.  wasEvaluated := false.
	assertBlock value.	"we end in our start state"
	command allRowsGrouped: 1 evaluate: assertBlock.
	self assert: wasEvaluated.  wasEvaluated := false.
	assertBlock value.	"again, we end in our start state"

	"The forRows: protocol should not be called on a single row - see what happens if it were."
	command := InsertCommand forRows: rows useBinding: false session: nil.
	command allRowsGrouped: 1000 evaluate: assertBlock.
	self assert: wasEvaluated.  wasEvaluated := false.
	assertBlock value.	"we end in our start state"
	command allRowsGrouped: 1 evaluate: assertBlock.
	self assert: wasEvaluated.  wasEvaluated := false.
	assertBlock value.	"again, we end in our start state"
]

{ #category : #tests }
GlorpCommandTest >> testSplittingInserts1000 [
	| rows command evaluatedTimes assertBlock |
	rows := (Array new: 1000) atAllPut: DatabaseRow new.
	command := InsertCommand forRows: rows useBinding: false session: nil.
	evaluatedTimes := 0.
	assertBlock :=
		[self assert: command allRows size = 1000.
		self assert: command allRows first == command row.
		self assert: command allRows first == rows first.
		self assert: command allRows last == rows last].
	command allRowsGrouped: 1000 evaluate:
		[evaluatedTimes := evaluatedTimes + 1.
		assertBlock value].
	self assert: evaluatedTimes = 1.
	assertBlock value.	"check we ended in our start state"
]

{ #category : #tests }
GlorpCommandTest >> testSplittingInserts1001 [
	| rows command subCommands |
	rows := (Array new: 1001) atAllPut: DatabaseRow new.
	rows at: rows size put: DatabaseRow new.
	command := InsertCommand forRows: rows useBinding: false session: nil.
	subCommands := OrderedCollection new.
	command allRowsGrouped: 1000 evaluate:
		[subCommands add: command shallowCopy].
	self assert: subCommands size = 2.
	self assert: subCommands first allRows size = 1000.
	self assert: subCommands first allRows first == rows first.
	self assert: subCommands first allRows last == (rows at: 1000).
	self assert:  subCommands last allRows size = 1.
	self assert: subCommands last allRows first == rows last.
	"check we ended in our start state"
	self assert: command allRows size = 1001.
	self assert: command allRows first == command row.
	self assert: command allRows first == rows first.
	self assert: command allRows last == rows last.
]

{ #category : #tests }
GlorpCommandTest >> testSplittingInserts1003 [

	| rows command subCommands |
	rows := (Array new: 1003) atAllPut: DatabaseRow new.
	rows at: rows size put: DatabaseRow new.
	command := InsertCommand forRows: rows useBinding: false session: nil.
	subCommands := OrderedCollection new.
	command allRowsGrouped: 1000 evaluate:
		[subCommands add: command shallowCopy].
	self assert: (subCommands allSatisfy: [:each | each allRows first == each row]).
	self assert: subCommands size = 2.
	self assert: subCommands first allRows size = 1000.
	self assert: subCommands first allRows first == rows first.
	self assert: subCommands first allRows last == (rows at: 1000).
	self assert:  subCommands last allRows size = 3.
	self assert: subCommands last allRows first == command row.
	self assert: subCommands last allRows first == (rows at: 1001).
	self assert: subCommands last allRows last == rows last.
	"check we ended in our start state"
	self assert: command allRows size = 1003.
	self assert: command allRows first == command row.
	self assert: command allRows first == rows first.
	self assert: command allRows last == rows last.
]

{ #category : #tests }
GlorpCommandTest >> testSplittingInserts2 [
	| rows command evaluatedTimes assertBlock |
	rows := Array with: DatabaseRow new with: DatabaseRow new.
	command := InsertCommand forRows: rows useBinding: false session: nil.
	evaluatedTimes := 0.
	assertBlock :=
		[self assert: command allRows size = 2.
		self assert: command allRows first == command row.
		self assert: command allRows first == rows first.
		self assert: command allRows last == rows last].
	command allRowsGrouped: 1000 evaluate:
		[evaluatedTimes := evaluatedTimes + 1.
		assertBlock value].
	self assert: evaluatedTimes = 1.
	assertBlock value.	"check we ended in our start state"

	evaluatedTimes := 0.
	command allRowsGrouped: 1 evaluate:
		[evaluatedTimes := evaluatedTimes + 1.
		self assert: command allRows size = 1.
		self assert: command allRows first == command row.
		self assert: command allRows first == (rows at: evaluatedTimes)].
	self assert: evaluatedTimes = 2.
	assertBlock value.
]

{ #category : #tests }
GlorpCommandTest >> testSplittingInserts2000plus [
	"Check an exact multiple, then the same with a little extra."

	| rows command subCommands |
	rows := (Array new: 2000) atAllPut: DatabaseRow new.
	command := InsertCommand forRows: rows useBinding: false session: nil.
	subCommands := OrderedCollection new.
	command allRowsGrouped: 1000 evaluate:
		[subCommands add: command shallowCopy].
	self assert: (subCommands allSatisfy: [:each | each allRows first == each row]).
	self assert: subCommands size = 2.
	self assert: subCommands first allRows size = 1000.
	self assert: subCommands first allRows first == rows first.
	self assert: subCommands first allRows last == (rows at: 1000).
	self assert:  subCommands last allRows size = 1000.
	self assert: subCommands last allRows first == (rows at: 1001).
	self assert: subCommands last allRows last == rows last.
	"check we ended in our start state"
	self assert: command allRows size = 2000.
	self assert: command allRows first == command row.
	self assert: command allRows first == rows first.
	self assert: command allRows last == rows last.

	rows := (Array new: 2002) atAllPut: DatabaseRow new.
	command := InsertCommand forRows: rows useBinding: false session: nil.
	subCommands := OrderedCollection new.
	command allRowsGrouped: 1000 evaluate:
		[subCommands add: command shallowCopy].
	self assert: (subCommands allSatisfy: [:each | each allRows first == each row]).
	self assert: subCommands size = 3.
	self assert: subCommands first allRows size = 1000.
	self assert: subCommands first allRows first == rows first.
	self assert: subCommands first allRows last == (rows at: 1000).
	self assert: (subCommands at: 2) allRows size = 1000.
	self assert: (subCommands at: 2) allRows first == (rows at: 1001).
	self assert: (subCommands at: 2) allRows last == rows last.
	self assert: subCommands last allRows size = 2.
	self assert: subCommands last allRows first == (rows at: 2001).
	self assert: subCommands last allRows last == rows last.
	"check we ended in our start state"
	self assert: command allRows size = 2002.
	self assert: command allRows first == command row.
	self assert: command allRows first == rows first.
	self assert: command allRows last == rows last.
]
