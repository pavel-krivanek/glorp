"
A command to update one or more rows.  The updated row is identified by the values of its primary key field(s), e.g.
	UPDATE AUTHOR SET NAME = 'William Shakespeare' WHERE ID = 2
and by those of its lock key field(s) if present, e.g.
	UPDATE BOOK SET COPIES_IN_STOCK = 4000,VERSION = 3 WHERE ID = 23 AND VERSION = 2
Lock fields can be used to assist optimistic locking by blocking update of written-since-read rows.  A lock field appears in the UPDATE clause, with its to-write value, and again in the WHERE clause, with its was-read value.

In a where clause, the SQL must be WHERE ... IS NULL, not WHERE ... =NULL, whether binding or not, so my #printSQL method writes IS NULL if a lock field's was-read value is nil (see #printLockEqualityForField:on:, which leads through a RelationalEpression to #printWithNullOn:)..  Thus we can have
	UPDATE BOOK SET TITLE = ?,COPIES_IN_STOCK = ?,VERSION = ? WHERE ID = ? AND VERSION = ?
bound to
	#('Mastering ENVY/Developer' 4000 3 5 2)
but if the bound values were
	#('Mastering ENVY/Developer' 4000 1 5 nil)
then the SQL would be
	UPDATE BOOK SET TITLE = ?,COPIES_IN_STOCK = ?,VERSION = ? WHERE ID = ? AND VERSION IS NULL
If there is only one lock field then its final nil binding value would have no bind marker and could just be ignored (as happened in older Glorp).  When there are two lock fields (rarer case), a nil read value for the first would be bound to the second's ? in the SQL, its own value being ignored.  Therefore I suppress binding nil to a lock field.
"
Class {
	#name : #UpdateCommand,
	#superclass : #RowBasedCommand,
	#category : #'Glorp-Database'
}

{ #category : #executing }
UpdateCommand >> allRowsGrouped: maxSizeInteger evaluate: aBlock [
	"If we are array binding and are updating only changed fields or have nullable lock fields, we need to group our rows into subsets that generate the same SQL into which values can be bound.  The SQL in the SET clause must have the same fields to uopdate for all rows.  Each lock field's initial value will appear in the where clause comparison, along with the primary key values, but whereas primary keys cannot be null, lock fields just might be.  In each group we write, each lock field must have either no nil values or all nil values so that the SQL in the where clause can be either ... lockField IS NULL or else ... lockField=?, with ? never being bound to nil value."

	| theRows nullableLockKeyFields compatibleRowGroups compatibleRowKeys |
	self useBinding ifFalse:	"unbound SQL can handle variations in which fields to update and/or which lock fields are nil"
		[^super allRowsGrouped: maxSizeInteger evaluate: aBlock].
	self platform usesArrayBindingToGroupWrite ifFalse:	"batch-statement-grouped rows can handle variations"
		[^super allRowsGrouped: maxSizeInteger evaluate: aBlock].
	nullableLockKeyFields := row lockKeyFields select: [:each | each isNullable].	"if no lock field can be nil, can't have rows with clashing nil states"
	"Sort the rows into compatible groups.  Collect the keys as well as the groups, instead of just using #groupedBy:, to preserve order as much as possible."
	compatibleRowGroups := Dictionary new.
	compatibleRowKeys := OrderedCollection new.
	nullableLockKeyFields isEmpty
		ifTrue: [self shouldUpdateOnlyChangedFields
				ifFalse: [^super allRowsGrouped: maxSizeInteger evaluate: aBlock]
				ifTrue: [allRows do:
						[:eachRow || eachKey | eachKey := eachRow fieldsNeedingUpdate.
						(compatibleRowGroups at: eachKey ifAbsentPut:
							[compatibleRowKeys add: eachKey.
							OrderedCollection new: allRows size]) add: eachRow]]]
		ifFalse: [self shouldUpdateOnlyChangedFields
				ifFalse: [allRows do:
						[:eachRow || eachKey |
						eachKey := nullableLockKeyFields collect:
							[:eachLockField | (eachRow oldVersionAt: eachLockField ifAbsent: [nil]) isNil].
						(compatibleRowGroups at: eachKey ifAbsentPut:
							[compatibleRowKeys add: eachKey.
							OrderedCollection new: allRows size]) add: eachRow]]
				ifTrue: [allRows do:
						[:eachRow || eachKey |
						eachKey := eachRow fieldsNeedingUpdate.
						eachKey addAll: (nullableLockKeyFields collect:
							[:eachLockField | (eachRow oldVersionAt: eachLockField ifAbsent: [nil]) isNil]).
						(compatibleRowGroups at: eachKey ifAbsentPut:
							[compatibleRowKeys add: eachKey.
							OrderedCollection new: allRows size]) add: eachRow]]].
	compatibleRowKeys size = 1 ifTrue:	"all rows have same update-field and lockKey-nil key;  no splitting needed"
		[^super allRowsGrouped: maxSizeInteger evaluate: aBlock].
	theRows := allRows.
	compatibleRowKeys do:
		[:key || compatibleRows | compatibleRows := compatibleRowGroups at: key.
		allRows := compatibleRows.
		self row: allRows first.
		super allRowsGrouped: maxSizeInteger evaluate: aBlock].
	"We're finished;  reset me back to my start state."
	allRows := theRows.
	self row: allRows first.
]

{ #category : #'bound values' }
UpdateCommand >> arrayBindings [
	"We must handle the special case of lock keys.  A lock key field appears twice in the UPDATE command:  with its (current) to-write value and (in the WHERE clause) with its (prior) was-read value (see class comment).  Thanks to #allRowsGrouped:evaluate:, my first row's lockKeyFields' nil/nonNil state is true for all my rows if and when this is called.  As we are using array binding, I can bind any nonNil value to a lock field, so need only consider nil values when coordinating with the where clause SQL."

	| basicBindings lockKeyNonNilFields lockKeyWhereClauseBindings |
	basicBindings := super arrayBindings.
	lockKeyNonNilFields := row lockKeyFields select:
		[:each | each isNullable not or: [(row oldVersionAt: each ifAbsent: [nil]) notNil]].
	lockKeyNonNilFields isEmpty ifTrue: [^basicBindings].
	lockKeyWhereClauseBindings := (1 to: lockKeyNonNilFields size) collect: [:each | Array new: allRows size].
	1 to: allRows size do:
		[:rowNumber || inputRow | inputRow := allRows at: rowNumber.
		1 to: lockKeyNonNilFields size do:
			[:columnNumber |
			(lockKeyWhereClauseBindings at: columnNumber)
				at: rowNumber
				put: (inputRow
						oldVersionAt: (lockKeyNonNilFields at: columnNumber)
						ifAbsent: [self error: 'invalid grouping:  in where clause, group has both nonNil and nil values for Lock ', (lockKeyNonNilFields at: columnNumber) printString])]].
	^basicBindings, lockKeyWhereClauseBindings
]

{ #category : #'bound values' }
UpdateCommand >> arrayBoundFields [
	"Array binding binds one or more values to the same SQL so all rows must agree which fields need update.  We also have to bind any optimistic lock field twice, once here with its current to-write value and once in the where clause with its older was-read value;  this second where-clause bind is appended by the caller."

	| basicFields |
	basicFields := self fieldsNeedingUpdate: row.
	^basicFields, row table primaryKeyFields asArray
]

{ #category : #'bound values' }
UpdateCommand >> batchStatementBindings [
	"As the super implementation but we add the where clause bindings for any lock fields."

	| bound fields lockKeyFields |
	lockKeyFields := row lockKeyFields.
	lockKeyFields isEmpty ifTrue: [^super batchStatementBindings].
	fields := self arrayBoundFields.
	bound := OrderedCollection new: allRows size * (fields size + lockKeyFields size).
	allRows do:
		[:eachRow |
		fields do:
			[:each || fieldValue | fieldValue := eachRow at: each ifAbsent: [nil].
			(self canBind: fieldValue to: each type) ifTrue: [bound add: fieldValue]].
		lockKeyFields do:	"this is the only real change from the super implementation"
			[:each || fieldValue | fieldValue := eachRow oldVersionAt: each ifAbsent: [nil].
			(fieldValue notNil and: [self canBind: fieldValue to: each type]) ifTrue: [bound add: fieldValue]]].
	^bound asArray
]

{ #category : #'bound values' }
UpdateCommand >> bindingTypes [
	"In a where clause, the SQL for a null-valued lock field must be WHERE ... IS NULL, not WHERE ... =NULL.  (Because SQL is one of the many languages that get it wrong where Smalltalk gets it right.  Unlike nil, which is equal and identical to itself, NULL means undefined and never equals itself:  NULL=NULL is always false;  you must use IS NULL.)
	A lock field appears in the UPDATE clause, with its to-write value, and again in the WHERE clause, with its was-read value, so my #printSQL method writes IS NULL if a lock field's read value is nil (see #printLockEqualityForField:on:, which leads through a RelationalEpression to #printWithNullOn:).  If there is only one lock field then its final nil binding value would have no bind marker and could just be ignored (as happened in older Glorp).  If there were two lock fields (a rare case - how likely is it?), a nil read value for the first gets bound to the second's ? in the SQL, its own value being ignored.  Therefore avoid binding nil to a lock field."

	| lockKeyWhereClauseBindingTypes lockType |
	row lockKeyFields isEmpty ifTrue: [^super bindingTypes].
	lockKeyWhereClauseBindingTypes := OrderedCollection new: row lockKeyFields size.
	row lockKeyFields do:
		[:each || fieldValue | fieldValue := row oldVersionAt: each ifAbsent: [nil].
		(fieldValue notNil and: [self canBind: fieldValue to: (lockType := each type)])
			ifTrue: [lockKeyWhereClauseBindingTypes add: lockType]].
	^super bindingTypes , lockKeyWhereClauseBindingTypes
]

{ #category : #accessing }
UpdateCommand >> blockFactor [
	^1.
]

{ #category : #accessing }
UpdateCommand >> fieldsNeedingUpdate [
	^self shouldUpdateOnlyChangedFields 
		ifTrue: [row fieldsNeedingUpdate]
		ifFalse: [row nonPrimaryKeyFields]
]

{ #category : #accessing }
UpdateCommand >> fieldsNeedingUpdate: aDatabaseRow [
	^self shouldUpdateOnlyChangedFields 
		ifTrue: [aDatabaseRow fieldsNeedingUpdate]
		ifFalse: [aDatabaseRow nonPrimaryKeyFields]
]

{ #category : #testing }
UpdateCommand >> needsRowCount [
	"We need to know whether any of the rows we attempted to update were not updated, i.e. whether any of them had changed lock key values from when we read them, so did not match their where clause, so did not update."

	^row lockKeyFields isEmpty not
]

{ #category : #executing }
UpdateCommand >> printSQL [
	self printSQLForFirstRow: row.
	self hasMultipleRows ifFalse: [^self].
	(self useBinding and: [self platform usesArrayBindingToGroupWrite]) ifTrue: [^self].
	2 to: self allRows size do:
		[:i | self printSQLForNextRow: (allRows at: i)].
]

{ #category : #executing }
UpdateCommand >> printSQLForFirstRow: aRow [
	| bodyFields |
	self nextPutAll: 'UPDATE '.
	aRow table printSQLOn: self withParameters: #().
	self nextPutAll: ' SET '.
	bodyFields := self fieldsNeedingUpdate: aRow.
	GlorpHelper
		do: [:field | aRow printEqualityTemplateForField: field on: self]
		for: bodyFields
		separatedBy: [self nextPut: $,].
	self nextPutAll: ' WHERE '.
	aRow printPrimaryKeyTemplateOn: self.
	aRow lockKeyFields do:
		[:field | self nextPutAll: ' AND '.
		aRow printLockEqualityForField: field on: self].
]

{ #category : #executing }
UpdateCommand >> printSQLForNextRow: aRow [
	self nextPut: $;.
	self space.
	self printSQLForFirstRow: aRow.
]

{ #category : #testing }
UpdateCommand >> shouldUpdateOnlyChangedFields [
	"Return true if we should write only changed fields out in an update statement, or if we should write all of them. The tradeoff is that writing only the changed ones will produce less SQL, but make more variations of the statement, and require us to keep more prepared statements around if we're using binding. By default, use this option only if we're not using binding by default."

	^self system shouldUpdateOnlyChangedFieldsFor: self.
]

{ #category : #'bound values' }
UpdateCommand >> singleRowBindings [
	"In an update command, lock fields appear twice, once in the UPDATE clause, with (current) to-write value, and again in the WHERE clause, with (prior) was-read value;  add these where clause values (see class comment)."

	| lockKeyWhereClauseBindings |
	row lockKeyFields isEmpty ifTrue: [^super singleRowBindings].
	lockKeyWhereClauseBindings := OrderedCollection new: row lockKeyFields size.
	row lockKeyFields do:
		[:each || fieldValue | fieldValue := row oldVersionAt: each ifAbsent: [nil].
		(fieldValue notNil and: [self canBind: fieldValue to: each type]) ifTrue:
			[lockKeyWhereClauseBindings add: fieldValue]].
	^super singleRowBindings, lockKeyWhereClauseBindings
]

{ #category : #'bound values' }
UpdateCommand >> singleRowBoundFields [
	"We will actually have to bind one more thing than this, the optimistic lock fields (if present). That's handled in the caller."

	| basicFields |
	basicFields := self fieldsNeedingUpdate: row.
	^basicFields , row table primaryKeyFields asArray
]

{ #category : #testing }
UpdateCommand >> supportsGroupWriting [
	^true
]
