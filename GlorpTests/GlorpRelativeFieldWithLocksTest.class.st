Class {
	#name : #GlorpRelativeFieldWithLocksTest,
	#superclass : #GlorpTestCase,
	#instVars : [
		'session'
	],
	#category : #GlorpTests
}

{ #category : #'VisualWorks metadata' }
GlorpRelativeFieldWithLocksTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #running }
GlorpRelativeFieldWithLocksTest >> sessionShouldUpdateOnlyChangedFields [
	"Return true if our session will only update changed fields. If this is true, and our only changes are to relative fields,
	then the lock keys (if any) will be excluded from both the update list and from the where clause. In this case, the
	only fields updated will be the relative fields.
	Otherwise, if we return false, then even a relative-only update will update the lock fields as well, causing any tests
	that depend on the special handling of relative fields to fail. (Therefore, a guard clause has been added to those tests.)"

	^ session system
		shouldUpdateOnlyChangedFieldsFor: Glorp_UpdateCommand new	"VW_TRANSLATION:Glorp.UpdateCommand:Glorp_UpdateCommand"
]

{ #category : #running }
GlorpRelativeFieldWithLocksTest >> setUp [
	| itemWithLockRow1 itemWithLockRow2 |
	super setUp.
	session := GlorpSessionResource current newSession.
	session beginTransaction.
	itemWithLockRow1 := session system exampleItemRelativeLocksRow1.
	itemWithLockRow2 := session system exampleItemRelativeLocksRow2.
	session writeRow: itemWithLockRow1.
	session writeRow: itemWithLockRow2.
	session commitTransaction
]

{ #category : #running }
GlorpRelativeFieldWithLocksTest >> shouldUpdateOnlyChangedFieldsForSession: aSession [
	"Return true if our session will only update changed fields. If this is true, and our only changes are to relative fields,
	then the lock keys (if any) will be excluded from both the update list and from the where clause. In this case, the
	only fields updated will be the relative fields.
	Otherwise, if we return false, then even a relative-only update will update the lock fields as well, causing any tests
	that depend on the special handling of relative fields to fail. (Therefore, a guard clause has been added to those tests.)"

	^ aSession system
		shouldUpdateOnlyChangedFieldsFor: Glorp_UpdateCommand new	"VW_TRANSLATION:Glorp.UpdateCommand:Glorp_UpdateCommand"
]

{ #category : #running }
GlorpRelativeFieldWithLocksTest >> supportsReturningValuesForSession: aSession [
	"Oracle supports returning values, but only if the command is bound."
	
	^(aSession platform relativeUpdateCommand includesBehavior: ReturningUpdateCommand)
		and: [aSession platform isOraclePlatform not or: [DatabasePlatform useBindingIfSupported]].
]

{ #category : #running }
GlorpRelativeFieldWithLocksTest >> tearDown [
	session delete: GlorpItemRelativeLocks where: [:book | book id >= 0].
	session reset.
	super tearDown.
]

{ #category : #'tests requiring relative-only-lock-free' }
GlorpRelativeFieldWithLocksTest >> testImageDBConsistencyAfterParallelUpdates [
	"This test investigates possible discrepancy between the image after updating a relative field if it has also been updated in another session."
	"This test will ERROR on RETURNING platforms if the relative-only-ignores-locks code fails, so the second (qty: 300) update has invalid locks.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."

	| session1 session2 session3 query1 query2 query3 items1 items2 items3 |
	session1 := GlorpSessionResource current newSession.
	(self supportsReturningValuesForSession: session1) ifFalse: [^true].
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
		["Read the current values in the first session. Values are #(100 50)"
		query1 := Query read: GlorpItemRelativeLocks.
		query1 orderBy: [:item | item id].
		items1 := session1 execute: query1.	

		session2 := GlorpSessionResource current newSession.
		session2 inUnitOfWorkDo: 
			["Read the items, and then update their quantities, undetected by session1."
			query2 := Query read: GlorpItemRelativeLocks.
			query2 orderBy: [:item | item id].
			items2 := session2 execute: query2.
			items2 do: [:each | each qty: 125]].	"Set the target qty to 125. (update +25, update +75)."

		"Use the already-cached items from session1, whose values are still #(100 50)"
		items1 do: [:each | each qty: 300]].	"Update the quantity. (update +200, update +250)."

	"Both updates have now been applied to the database;  items2 do not know of later updates ..."
	self assert: items2 first qty = 125 description: 'Session2 first should still have value 125' resumable: true.
	self assert: items2 last qty = 125 description: 'Session2 last should still have value 125' resumable: true.
	"... . but items1 do know the actual final value at the end of writing their increments to the DB."
	self assert: items1 first qty = 325 description: 'Session1 first lacks post-write value 325' resumable: true.
	self assert: items1 last qty = 375 description: 'Session1 last lacks post-write value 375' resumable: true.
	"... and so their values are no longer the ones they wrote."
	self deny: items1 first qty = 300 description: 'Session1 first still has pre-write value 300' resumable: true.
	self deny: items1 last qty = 300 description: 'Session1 last still has its pre-write value 300' resumable: true.

	"Determine the actual quantities."
	session3 := GlorpSessionResource current newSession.
	query3 := Query read: GlorpItemRelativeLocks.
	query3 orderBy: [:item | item id].
	items3 := session3 execute: query3.
	self assert: items3 first qty = 325 description: 'Re-read first lacks final value 325' resumable: true.
	self assert: items3 last qty = 375 description: 'Re-read last lacks final value 375'.	"no point resuming last assert"
]

{ #category : #'tests requiring relative-only-lock-free' }
GlorpRelativeFieldWithLocksTest >> testMultiRelativeFieldsImageDBConsistencyAfterParallelUpdates [
	"This test investigates possible discrepancy between the image after updating a relative field if it has also been updated in another session. Oracle cannot return values if unbound."
	"This test will ERROR on RETURNING platforms if the relative-only-ignores-locks code fails, so the second (qty: 300) update has invalid locks.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."
	
	| session1 session2 session3 query1 query2 query3 items1 items2 items3 |
	session1 := GlorpSessionResource current newSession.
	(self supportsReturningValuesForSession: session1) ifFalse: [^true].
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
		["Read the current values in the first session. Values are #(100 500s) and #(50 0s)"
		query1 := Query read: GlorpItemRelativeLocks.
		query1 orderBy: [:item | item id].
		items1 := session1 execute: query1.	

		session2 := GlorpSessionResource current newSession.
		session2 inUnitOfWorkDo: 
			["Read the items, and then update their quantities, undetected by session1."
			query2 := Query read: GlorpItemRelativeLocks.
			query2 orderBy: [:item | item id].
			items2 := session2 execute: query2.
			items2 do: [:each| each qty: 125; totalSales: 100.0]].		"Set the target qty to 125, sales to 100.00."

		"Use the already-cached items from session1, whose values are still #(100 50)"
		items1 do: [:each | each qty: 300; totalSales: 25.0]].	"Update the quantity. (update +200, update +250), (+25.0, -475.0)."

	"Both updates have now been applied to the database;  items2 do not know of later updates ..."
	self assert: items2 first qty = 125 description: 'Session2 first should still have value 125' resumable: true.
	self assert: items2 first totalSales = 100s description: 'Session2 first sales should still have value 100.00' resumable: true.
	self assert: items2 last qty = 125 description: 'Session2 last should still have value 125' resumable: true.
	self assert: items2 last totalSales = 100s description: 'Session2 last  sales should still have value 100.00' resumable: true.
	"... . but items1 do know the actual final value at the end of writing their increments to the DB."
	self assert: items1 first qty = 325 description: 'Session1 first lacks post-write value 325' resumable: true.
	self assert: items1 last qty = 375 description: 'Session1 last lacks post-write value 375' resumable: true.
	"... and so their values are no longer the ones they wrote."
	self deny: items1 first qty = 300 description: 'Session1 first still has pre-write value 300' resumable: true.
	self deny: items1 last qty = 300 description: 'Session1 last still has its pre-write value 300' resumable: true.

	"Determine the actual quantities."
	session3 := GlorpSessionResource current newSession.
	query3 := Query read: GlorpItemRelativeLocks.
	query3 orderBy: [:item | item id].
	items3 := session3 execute: query3.
	self assert: items3 first qty = 325 description: 'Re-read first lacks final value 325' resumable: true.
	self assert: items3 first totalSales = 125s description: 'Re-read first lacks final value 325' resumable: true.
	self assert: items3 last qty = 375 description: 'Re-read last lacks final value 375'.	"no point resuming last assert"
	self assert: items3 last totalSales = -375s description: 'Re-read last lacks final value 375'.	"no point resuming last assert"
]

{ #category : #'test-multiple fields and valid locks' }
GlorpRelativeFieldWithLocksTest >> testMultipleRelativeFieldsNormalUsage [
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each qty: 125; totalSales: 100.0]].
	"We wrote values in setUp and updated them; check values."
	session2 := GlorpSessionResource current newSession.
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
	self assert: items first totalSales = 100.
	self assert: items last totalSales = 100.
]

{ #category : #'test-returning with valid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeFieldNonUsage [
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo:
		["Read the items and update a normal field but ignore the relative field."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each name: 'Smith']].
	"We wrote values to the db in setUp; check their quantities are unchanged."
	session2 := GlorpSessionResource current newSession.
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first name = 'Smith'.
	self assert: items first qty = 100.
	self assert: items last name = 'Smith'.
	self assert: items last qty = 50.
]

{ #category : #'test-updating with invalid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeFieldNormalUsageBadLocks [
	"Reuse session1, which evidently knows about the items it read before, so when we register: them later in another transaction, they are updated, not inserted.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."
	| query items session1 session2 caughtError |
	"Read the items with session1."
	session1 := GlorpSessionResource current newSession.
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	items := session1 read: GlorpItemRelativeLocks.
	"Invalidate the locks, going around Glorp, so that its sessions are unaware of the change."
	session1 accessor
			executeSQLStringNoResult: 'UPDATE ITEM_RELATIVE_LOCKS SET LOCK1 = LOCK1 + 100, LOCK2 = LOCK2 + 100'.
	"Re-register (resynch them) the items, and try to update them with now invalid lock keys."
	caughtError := false.
	[session1
			transact:
				[session1 register: items.
				items do: [:each| each qty: 125]]]
			on: GlorpDatabaseWriteError, GlorpWriteFailure
			do: [:ex | caughtError := true.
					ex return: nil].
	self assert: caughtError not.		"Since we ONLY changed relative fields, the locks should have been ignored."
	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
]

{ #category : #'test-updating with valid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldDecrementUsage [
	| session1 session2 query items |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each | each qty: 10]].		"Set the target qty to 10."

	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 10.
	self assert: items last qty = 10.
]

{ #category : #'test-updating with valid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldManyRowUpdate [
	"This test inserts, then updates, an array of data to ensure that relative field works with multiple row update."

	| session1 session2 session3 data1 data2 data3 |
	session1 := GlorpSessionResource current newSession.
	data1 := OrderedCollection new
		add: (GlorpItemRelativeLocks new id: 3; name: 'a'; qty: 10; lock1: 3);
		add: (GlorpItemRelativeLocks new  id: 4; name: 'b'; qty: 11; lock1: 4);
		add: (GlorpItemRelativeLocks new  id: 5; name: 'c'; qty: 12; lock1: 5);
		add: (GlorpItemRelativeLocks new  id: 6; name: 'd'; qty: 13; lock1: 6);
		yourself.
	session1 inUnitOfWorkDo: [session1 registerAll: data1].
	session2 := GlorpSessionResource current newSession.
	session2 inUnitOfWorkDo:
		[data2 := session2 read: GlorpItemRelativeLocks.
		self assert: data2 size = 6.
		data2 do: [:each| each qty: 35]].
	session3 := GlorpSessionResource current newSession.
	data3 := session3 read: GlorpItemRelativeLocks.
	self assert: data3 size = 6 .
	data3 do: [:each| self assert: each qty = 35].
]

{ #category : #'test-updating with invalid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldManyRowUpdateBadLocks [
	"This test inserts, then updates, an array of data to ensure that relative field works with multiple row update.
	Reuse session1, which evidently knows about the items it read before, so when we register: them later in another transaction, they are updated, not inserted.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."


	| session1 session3 data1 data3 caughtError |
	session1 := GlorpSessionResource current newSession.
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	data1 := OrderedCollection new
		add: (GlorpItemRelativeLocks new id: 3; name: 'a'; qty: 10; lock1: 3);
		add: (GlorpItemRelativeLocks new  id: 4; name: 'b'; qty: 11; lock1: 4);
		add: (GlorpItemRelativeLocks new  id: 5; name: 'c'; qty: 12; lock1: 5);
		add: (GlorpItemRelativeLocks new  id: 6; name: 'd'; qty: 13; lock1: 6);
		yourself.
	session1 inUnitOfWorkDo: [session1 registerAll: data1].
	session1 accessor
			executeSQLStringNoResult: 'UPDATE ITEM_RELATIVE_LOCKS SET LOCK1 = LOCK1 + 100, LOCK2 = LOCK2 + 100'.
	caughtError := false.
	[session1
			transact:
				[session1 registerAll: data1.
				data1 do: [:each| each qty: 35]]]
			on: GlorpDatabaseWriteError, GlorpWriteFailure
			do: [:ex | caughtError := true.
					ex return: nil].
	self assert: caughtError not.		"Since we ONLY changed relative fields, the locks should have been ignored."

	session3 := GlorpSessionResource current newSession.
	data3 := session3 read: GlorpItemRelativeLocks.
	self assert: data3 size = 6 .
	data3 do: [:each| self assert: ((each qty = 35) or: [#(50 100) includes: each qty])].
]

{ #category : #'test-updating with valid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldNormalUsage [
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each qty: 125]].		"Set the target qty to 125."

	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
]

{ #category : #'test-updating with valid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldNullWrite [
	"We created the qty field to be not-NULLable, but the totalSales field can hold NULL.  Of course, once we NULL a relative field, we cannot insert any value (at least, not via that mapping)."

	| session1 session2 query items session3 canRaiseGlorpWriteFailure |
	"Some platforms will raise a GlorpWriteFailure if an update fails, and rowCount will be zero.
	When we update a NULL relative field, MySQL returns 0 for rowCount, and Glorp throws the exception."
	canRaiseGlorpWriteFailure := session accessor platform supportsRowCountFor: UpdateCommand new.

	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo:		"read, check values, set to nil"
		[query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		self assert: items first totalSales = 0.
		self assert: items last totalSales = 500s.
		items do: [:each | each totalSales: nil].
		items do: [:each | self assert: each totalSales isNil]].

	session2 := GlorpSessionResource current newSession.
	[session2 inUnitOfWorkDo:		"read, check values are nil, set to 20"
		[query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session2 execute: query.
		self assert: items first totalSales isNil.
		self assert: items last totalSales isNil.
		items do: [:each | each totalSales: 20].
		"Before we write, we hold the values we set."
		items do: [:each | self assert: each totalSales = 20]]]
			on: GlorpWriteFailure do: [:ex| canRaiseGlorpWriteFailure ifTrue: [ex return: nil]].

	"After we write, we are syched with the database, so are nil again (if we are a returning command, not otherwise)."
	(self supportsReturningValuesForSession: session1)
		ifTrue: [items do: [:each | self assert: each totalSales isNil]].

	"read, check values are still nil"
	session3 := GlorpSessionResource current newSession.
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session3 execute: query.
	self assert: items first totalSales isNil.
	self assert: items last totalSales isNil.
]

{ #category : #'test-updating with valid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldOneRowNULLOneNotNULL [
	"Have a null and a non-null row.  This passes on Postgres unbound and bound but the bound only works because Postgres bound does not group."

	| session1 session2 query items session3 canRaiseGlorpWriteFailure hadWriteFailure |
	"Some platforms will raise a GlorpWriteFailure if an update fails, and rowCount will be zero.
	When we update a NULL relative field, MySQL returns 0 for rowCount, and Glorp throws the exception."
	canRaiseGlorpWriteFailure := session accessor platform supportsRowCountFor: UpdateCommand new.

	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo:		"read, check values, set to nil"
		[query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		self assert: items first totalSales = 0.
		self assert: items last totalSales = 500s.
		items first totalSales: nil.
		items last totalSales: 250].

	session2 := GlorpSessionResource current newSession.
	hadWriteFailure := false.
	[session2 inUnitOfWorkDo:		"read, check values are nil, set to 20"
		[query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session2 execute: query.
		self assert: items first totalSales isNil.
		self assert: items last totalSales = 250.
		items do: [:each | each totalSales: 20].
		"Before we write, we hold the values we set."
		items do: [:each | self assert: each totalSales = 20]]]
			on: GlorpWriteFailure
			do: [:ex| canRaiseGlorpWriteFailure ifTrue: [hadWriteFailure := true].
					ex return: nil].

	"After we write, we are syched with the database, so are nil again (if we are a returning command, not otherwise)."
	(self supportsReturningValuesForSession: session1) ifTrue:
		[self assert: items first totalSales isNil.
		self assert: items last totalSales = 20].
	"read, check values are still nil"
	session3 := GlorpSessionResource current newSession.
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session3 execute: query.
	self assert: items first totalSales isNil.
	self assert: (hadWriteFailure or: [items last totalSales = 20s]).
]

{ #category : #'tests requiring relative-only-lock-free' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldParallelDecrements [
	"This test validates the behavior of relative field updates, which don't need to know the current values of their target fields. They do know the relative change in value between when their session read them and wrote them, which is what gets added to the target in the database. This test uses 2 separate sessions, oblivious about each other, and involves several steps.
	Step 1: The first session loads values from the Db. It sees qty #(100 50) for the two rows.
	Step 2: The second session does the same, and updates these values to #(10 10).
	Step 3: The first session now updates the qty from #(100 50), unaware these are stale numbers, to (300 300).
	Step 4: The transaction commits, and the database qty is now #(325 375),
			since (300-100=200)+10=210  and (300-50=250)+10=260.
	Step 5: A fresh session reads from the database and confirms these values."
	"This test will ERROR on RETURNING platforms if the relative-only-ignores-locks code fails, so the second (qty: 300) update has invalid locks.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."
	
	| session1 session2 session3 query1 query2 query3 items1 items2 items3 |
	session1 := GlorpSessionResource current newSession.
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
			["Read the current values in the first session. Values are #(100 50)"
			query1 := Query read: GlorpItemRelativeLocks.
			query1 orderBy: [:item | item id].
			items1 := session1 execute: query1.
			
			session2 := GlorpSessionResource current newSession.
			session2 inUnitOfWorkDo: 
					["Read the items, and then update their quantities, undetected by session1.
					This inner UOW generates and commits its own transaction at the end of its block. 
					The outer UOW starts and commits its own transaction at the end of its block."
					query2 := Query read: GlorpItemRelativeLocks.
					query2 orderBy: [:item | item id].
					items2 := session2 execute: query2.
					items2 do: [:each | each qty: 10]].	"Set the target qty to 10. (update -90, update -40)."

			"Use the already-cached items from session1, whose values are still #(100 50)"
			items1 do: [:each | each qty: 300]].	"Update the quantity. (update +200, update +250)."

	"Determine the actual quantities."
	session3 := GlorpSessionResource current newSession.
	query3 := Query read: GlorpItemRelativeLocks.
	query3 orderBy: [:item | item id].
	items3 := session3 execute: query3.
	self assert: items3 first qty = 210.
	self assert: items3 last qty = 260.
]

{ #category : #'tests requiring relative-only-lock-free' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldParallelIncrements [
	"Read values, apply two updates in separate sessions, then read again from the database and verify values are the summary of the two differences."
	"This test will ERROR on RETURNING platforms if the relative-only-ignores-locks code fails, so the second (qty: 300) update has invalid locks.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."
	
	| session1 session2 session3 query1 query2 query3 items1 items2 items3 |
	session1 := GlorpSessionResource current newSession.
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
			["Read the current values in the first session. Values are #(100 50)"
			query1 := Query read: GlorpItemRelativeLocks.
			query1 orderBy: [:item | item id].
			items1 := session1 execute: query1.
			
			session2 := GlorpSessionResource current newSession.
			session2 inUnitOfWorkDo: 
					["Read the items, and then update their quantities, undetected by session1."
					query2 := Query read: GlorpItemRelativeLocks.
					query2 orderBy: [:item | item id].
					items2 := session2 execute: query2.
					items2 do: [:each | each qty: 125]].	"Set the target qty to 125. (update +25, update +75)."

			"Use the already-cached items from session1, whose values are still #(100 50)"
			items1 do: [:each | each qty: 300]].	"Update the quantity. (update +200, update +250)."

	"Determine the actual quantities."
	session3 := GlorpSessionResource current newSession.
	query3 := Query read: GlorpItemRelativeLocks.
	query3 orderBy: [:item | item id].
	items3 := session3 execute: query3.
	self assert: items3 first qty = 325.
	self assert: items3 last qty = 375
]

{ #category : #'test-updating with invalid locks' }
GlorpRelativeFieldWithLocksTest >> testRelativeLockFieldSingleRowUpdateBadLocks [
	"This test inserts, then updates, a single item to ensure that relative field works with single row updates.
	Reuse session1, which evidently knows about the items it read before, so when we register: them later in another transaction, they are updated, not inserted.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."

	| session1 session3 item data3 caughtError |
	session1 := GlorpSessionResource current newSession.
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	item := GlorpItemRelativeLocks new id: 3; name: 'a'; qty: 10; lock1: 3.
	session1 inUnitOfWorkDo: [session1 register: item].
	session1 accessor
			executeSQLStringNoResult: 'UPDATE ITEM_RELATIVE_LOCKS SET LOCK1 = LOCK1 + 100, LOCK2 = LOCK2 + 100'.
	caughtError := false.
	[session1
			transact:
				[session1 register: item.
				item qty: 35]]
			on: GlorpDatabaseWriteError, GlorpWriteFailure
			do: [:ex | caughtError := true.
					ex return: nil].

	self assert: caughtError not.		"Since we ONLY changed relative fields, the locks should have been ignored."
	session3 := GlorpSessionResource current newSession.
	data3 := session3 read: GlorpItemRelativeLocks.
	self assert: data3 size = 3 .
	data3 do: [:each| self assert: ((each qty = 35) or: [#(50 100) includes: each qty])].
]

{ #category : #'test-multiple fields and valid locks' }
GlorpRelativeFieldWithLocksTest >> testSecondRelativeFieldOnlyUsage [
	"Update the 2nd relative field, leaving the first unchanged (so it's contents won't be part of our update query)."
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each totalSales: 200.0]].		"Set the target totalSales to 125."

	session2 := GlorpSessionResource current newSession.
	"SetUp has already written these values to the db, so update their quantities."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first totalSales = 200.0.
	self assert: items last totalSales = 200.0.
]

{ #category : #'test-multiple fields and valid locks' }
GlorpRelativeFieldWithLocksTest >> testSecondRelativeFieldOnlyUsageSingleRow [
	"Update the 2nd relative field, leaving the first unchanged (so it's contents won't be part of our update query).
	This test only updates one row, so it won't use array-binding (if that is available for the current platform)."
	| query session1 session2 itemWritten itemRead|
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query readOneOf: GlorpItemRelativeLocks.
		itemWritten := session1 execute: query.
		itemWritten totalSales: 200.0].		"Set the target totalSales to 125."

	session2 := GlorpSessionResource current newSession.
	"SetUp has already written these values to the db, so update their quantities."
	query := Query readOneOf: GlorpItemRelativeLocks where: [:each| each id = itemWritten id].
	itemRead := session2 execute: query.
	self assert: itemRead totalSales = 200.0.
]

{ #category : #'test-updating all fields with locks' }
GlorpRelativeFieldWithLocksTest >> testUpdatingNormalAndRelativeFields [
	"Ensure that we can update  relative fields and regular fields, and that the lock fields do get incremented."
	| query items session1 session2 locks |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each qty: 125.					"Set the target qty to 125."
						each name: (each name,'new')]].	"Also, change the name (a non-relative field)."

	"Load just the lock fields, to ensure that they were incremented."
	locks := session1 accessor executeSQLString: 'SELECT LOCK1 FROM ITEM_RELATIVE_LOCKS ORDER BY LOCK1'.
	self assert: (  locks first first > 1).
	self assert: (locks last first > 2).

	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
	self assert: (items first name findString: 'new' startingAt: 1) > 0.
	self assert: (items last name findString: 'new' startingAt: 1) > 0.
]

{ #category : #'test-updating all fields with locks' }
GlorpRelativeFieldWithLocksTest >> testUpdatingOnlyNormalFields [
	"Ensure that we can update regular fields, and that the lock fields do get incremented."
	| query items session1 session2 locks |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each name: 'xyz']].		"Set the target qty to 125."
	"Load just the lock fields, to ensure that they were incremented."
	locks := session1 accessor executeSQLString: 'SELECT LOCK1 FROM ITEM_RELATIVE_LOCKS ORDER BY LOCK1'.
	self assert: (locks first first > 1).
	self assert: (locks last first > 2).

	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 100.
	self assert: items last qty = 50.
]

{ #category : #'test-updating all fields with locks' }
GlorpRelativeFieldWithLocksTest >> testUpdatingOnlyNormalFields2 [
	"Ensure that we can update regular fields, and that the lock fields do get incremented."
	| items lockValues newLockValues |
	items := session read: GlorpItemRelativeLocks orderBy: #id.
	lockValues := (session accessor executeSQLString: 'SELECT LOCK1 FROM ITEM_RELATIVE_LOCKS ORDER BY ID') collect: [:each | each first].
	session modify: items in: [
		items do: [:each | each name: 'xyz']].
	newLockValues := (session accessor executeSQLString: 'SELECT LOCK1 FROM ITEM_RELATIVE_LOCKS ORDER BY ID') collect: [:each | each first].
	self assert: newLockValues = (lockValues collect: [:each | each + 1]).
]

{ #category : #'tests requiring relative-only-lock-free' }
GlorpRelativeFieldWithLocksTest >> testUpdatingOnlyRelativeFields [
	"Ensure that we can update only relative fields, and that the lock fields are NOT incremented."
	"This test will ERROR on platforms if the relative-only-ignores-locks code fails, thereby incrementing the locks.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."
		
	| query items session1 session2 locks |
	session1 := GlorpSessionResource current newSession.
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each qty: 125]].		"Set the target qty to 125."
	"Load just the lock fields, to ensure that they weren't incremented."
	locks := session1 accessor executeSQLString: 'SELECT LOCK1 FROM ITEM_RELATIVE_LOCKS ORDER BY LOCK1'.
	self assert: (locks first first = 1).
	self assert: (locks last first = 2).
	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
]

{ #category : #'tests requiring relative-only-lock-free' }
GlorpRelativeFieldWithLocksTest >> testUpdatingRelativeFieldsOnlyInFirstRow [
	"Ensure that we can update only relative fields, and that the lock fields are NOT incremented."
	"This test will ERROR on platforms if the relative-only-ignores-locks code fails, thereby incrementing the locks.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."
		
	| query items session1 session2 locks |
	session1 := GlorpSessionResource current newSession.
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items first qty: 125.				"Set only the target qty to 125, meaning no need for lock keys."
		items last name: 'yogi bear'].		"Set only the name field, meaning we'll need lock keys."
	"Load just the lock fields, to ensure that they weren't incremented."
	locks := session1 accessor executeSQLString: 'SELECT LOCK1 FROM ITEM_RELATIVE_LOCKS ORDER BY LOCK1'.
	self assert: (locks first first = 1).	"Started at 1, stayed at 1."
	self assert: (locks last first = 3).	"Went from 2 to 3."
	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 50.
]

{ #category : #'tests requiring relative-only-lock-free' }
GlorpRelativeFieldWithLocksTest >> testUpdatingRelativeFieldsOnlyInSecondRow [
	"Ensure that we can update only relative fields, and that the lock fields are NOT incremented."
	"This test will ERROR on platforms if the relative-only-ignores-locks code fails, thereby incrementing the locks.
	If the platform or image settings always updates ALL fields, the relative-only-ignores-locks code is bypassed. Knowing this, return true."
		
	| query items session1 session2 locks |
	session1 := GlorpSessionResource current newSession.
	(self shouldUpdateOnlyChangedFieldsForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items first name: 'yogi bear'.		"Set only the name field, meaning we'll need lock keys."
		items last qty: 125].				"Set only the target qty to 125, meaning no need for lock keys."
	"Load just the lock fields, to ensure that they weren't incremented."
	locks := session1 accessor executeSQLString: 'SELECT LOCK1 FROM ITEM_RELATIVE_LOCKS ORDER BY LOCK1'.
	self assert: (locks first first = 2).	"Went from 1 to 2."
	self assert: (locks last first = 2).	"Started at 2, stayed at 2."
	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 100.
	self assert: items last qty = 125.
]

{ #category : #'test-updating with valid locks' }
GlorpRelativeFieldWithLocksTest >> testWithOnlyRelativeLockFieldNormalUsage [
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemRelativeLocks.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each qty: 125]].		"Set the target qty to 125."

	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemRelativeLocks.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
]
