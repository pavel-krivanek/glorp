"
An alternative to optimistic locking is to write an incremental update, not an absolute value, to a field.  My various tests check the writing of these values and/or whether Glorp then recovers the post-write actual values.
"
Class {
	#name : #GlorpRelativeFieldTest,
	#superclass : #GlorpTestCase,
	#instVars : [
		'session'
	],
	#category : #'GlorpTests-GlorpTest'
}

{ #category : #accessing }
GlorpRelativeFieldTest class >> resources [
	^Array with: GlorpSessionResource.
]

{ #category : #'VisualWorks metadata' }
GlorpRelativeFieldTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #support }
GlorpRelativeFieldTest >> item1 [
	^GlorpItemWithQty new
		id: 1;
		name: 'Thingamabob 1';
		qty: 100;
		totalSales: 0.0;
		yourself
]

{ #category : #support }
GlorpRelativeFieldTest >> item2 [
	^GlorpItemWithQty new
		id: 2;
		name: 'Gizmo 2';
		qty: 50;
		totalSales: 500.0;
		yourself
]

{ #category : #running }
GlorpRelativeFieldTest >> setUp [
	| itemRow1 itemRow2 |
	super setUp.
	session := GlorpSessionResource current newSession.
	session beginTransaction.
	itemRow1 := session system exampleItemWithQtyRow1.
	itemRow2 := session system exampleItemWithQtyRow2.
	session writeRow: itemRow1.
	session writeRow: itemRow2.
	session commitTransaction
]

{ #category : #running }
GlorpRelativeFieldTest >> supportsReturningValuesForSession: aSession [
	"Oracle supports returning values, but only if the command is bound."
	
	^(aSession platform relativeUpdateCommand includesBehavior: ReturningUpdateCommand)
		and: [aSession platform isOraclePlatform not or: [DatabasePlatform useBindingIfSupported]].
]

{ #category : #running }
GlorpRelativeFieldTest >> tearDown [
	session delete: GlorpItemWithQty where: [:item | item id >= 0].
	session reset.
	super tearDown.
]

{ #category : #'test-returning' }
GlorpRelativeFieldTest >> testImageDBConsistencyAfterParallelUpdates [
	"This test investigates possible discrepancy between the image after updating a relative field if it has also been updated in another session."

	| session1 session2 session3 query1 query2 query3 items1 items2 items3 |
	session1 := GlorpSessionResource current newSession.
	(self supportsReturningValuesForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
		["Read the current values in the first session. Values are #(100 50)"
		query1 := Query read: GlorpItemWithQty.
		query1 orderBy: [:item | item id].
		items1 := session1 execute: query1.	

		session2 := GlorpSessionResource current newSession.
		session2 inUnitOfWorkDo: 
			["Read the items, and then update their quantities, undetected by session1."
			query2 := Query read: GlorpItemWithQty.
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
	query3 := Query read: GlorpItemWithQty.
	query3 orderBy: [:item | item id].
	items3 := session3 execute: query3.
	self assert: items3 first qty = 325 description: 'Re-read first lacks final value 325' resumable: true.
	self assert: items3 last qty = 375 description: 'Re-read last lacks final value 375'.	"no point resuming last assert"
]

{ #category : #'test-multiple fields' }
GlorpRelativeFieldTest >> testMultiRelativeFieldsImageDBConsistencyAfterParallelUpdates [
	"This test investigates possible discrepancy between the image after updating a relative field if it has also been updated in another session. Oracle cannot return values if unbound."

	| session1 session2 session3 query1 query2 query3 items1 items2 items3 |
	session1 := GlorpSessionResource current newSession.
	(self supportsReturningValuesForSession: session1) ifFalse: [^true].
	session1 inUnitOfWorkDo: 
		["Read the current values in the first session. Values are #(100 500s) and #(50 0s)"
		query1 := Query read: GlorpItemWithQty.
		query1 orderBy: [:item | item id].
		items1 := session1 execute: query1.	

		session2 := GlorpSessionResource current newSession.
		session2 inUnitOfWorkDo: 
			["Read the items, and then update their quantities, undetected by session1."
			query2 := Query read: GlorpItemWithQty.
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
	query3 := Query read: GlorpItemWithQty.
	query3 orderBy: [:item | item id].
	items3 := session3 execute: query3.
	self assert: items3 first qty = 325 description: 'Re-read first lacks final value 325' resumable: true.
	self assert: items3 first totalSales = 125s description: 'Re-read first lacks final value 325' resumable: true.
	self assert: items3 last qty = 375 description: 'Re-read last lacks final value 375'.	"no point resuming last assert"
	self assert: items3 last totalSales = -375s description: 'Re-read last lacks final value 375'.	"no point resuming last assert"
]

{ #category : #'test-multiple fields' }
GlorpRelativeFieldTest >> testMultipleRelativeFieldsNormalUsage [
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each qty: 125; totalSales: 100.0]].
	"We wrote values in setUp and updated them; check values."
	session2 := GlorpSessionResource current newSession.
	query := Query read: GlorpItemWithQty.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
	self assert: items first totalSales = 100.
	self assert: items last totalSales = 100.
]

{ #category : #'test-updating' }
GlorpRelativeFieldTest >> testRelativeAndOrdinaryFields [
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each name: (each name, 'new').	"Include a non-relative field to make sure it gets through."
						each qty: 125]].					"Set the target qty to 125."

	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values, including the changed non-relative fields."
	query := Query read: GlorpItemWithQty.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
	self assert: (items first name findString: 'new' startingAt: 1) > 0.
	self assert: (items last name findString: 'new' startingAt: 1) > 0.
]

{ #category : #'test-updating' }
GlorpRelativeFieldTest >> testRelativeFieldDecrementUsage [
	| session1 session2 query items |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each | each qty: 10]].		"Set the target qty to 10."

	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemWithQty.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 10.
	self assert: items last qty = 10.
]

{ #category : #'test-updating' }
GlorpRelativeFieldTest >> testRelativeFieldManyRowUpdate [
	"This test inserts, then updates, an array of data to ensure that relative field works with multiple row update."

	| session1 session2 session3 data1 data2 data3 |
	session1 := GlorpSessionResource current newSession.
	data1 := OrderedCollection new
		add: (GlorpItemWithQty new id: 3; name: 'a'; qty: 10);
		add: (GlorpItemWithQty new  id: 4; name: 'b'; qty: 11);
		add: (GlorpItemWithQty new  id: 5; name: 'c'; qty: 12);
		add: (GlorpItemWithQty new  id: 6; name: 'd'; qty: 13);
		yourself.
	session1 inUnitOfWorkDo: [session1 registerAll: data1].
	session2 := GlorpSessionResource current newSession.
	session2 inUnitOfWorkDo:
		[data2 := session2 read: GlorpItemWithQty.
		self assert: data2 size = 6.
		data2 do: [:each| each qty: 35]].
	session3 := GlorpSessionResource current newSession.
	data3 := session3 read: GlorpItemWithQty.
	self assert: data3 size = 6 .
	data3 do: [:each| self assert: each qty = 35].
]

{ #category : #'test-returning' }
GlorpRelativeFieldTest >> testRelativeFieldNonUsage [
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo:
		["Read the items and update a normal field but ignore the relative field."
		query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each name: 'Smith']].
	"We wrote values to the db in setUp; check their quantities are unchanged."
	session2 := GlorpSessionResource current newSession.
	query := Query read: GlorpItemWithQty.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first name = 'Smith'.
	self assert: items first qty = 100.
	self assert: items last name = 'Smith'.
	self assert: items last qty = 50.
]

{ #category : #'test-updating' }
GlorpRelativeFieldTest >> testRelativeFieldNormalUsage [
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each qty: 125]].		"Set the target qty to 125."

	session2 := GlorpSessionResource current newSession.
	"We wrote values to the db in setUp; check the post-relative-update values."
	query := Query read: GlorpItemWithQty.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first qty = 125.
	self assert: items last qty = 125.
]

{ #category : #'test-updating' }
GlorpRelativeFieldTest >> testRelativeFieldNullWrite [
	"We created the qty field to be not-NULLable, but the totalSales field can hold NULL.  Of course, once we NULL a relative field, we cannot insert any value (at least, not via that mapping)."

	| session1 session2 query items session3 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo:		"read, check values, set to nil"
		[query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		self assert: items first totalSales = 0.
		self assert: items last totalSales = 500s.
		items do: [:each | each totalSales: nil].
		items do: [:each | self assert: each totalSales isNil]].

	session2 := GlorpSessionResource current newSession.
	session2 inUnitOfWorkDo:		"read, check values are nil, set to 20"
		[query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session2 execute: query.
		self assert: items first totalSales isNil.
		self assert: items last totalSales isNil.
		items do: [:each | each totalSales: 20].
		"Before we write, we hold the values we set."
		items do: [:each | self assert: each totalSales = 20]].
	"After we write, we are syched with the database, so are nil again (if we are a returning command, not otherwise)."
	(self supportsReturningValuesForSession: session1)
		ifTrue: [items do: [:each | self assert: each totalSales isNil]].

	"read, check values are still nil"
	session3 := GlorpSessionResource current newSession.
	query := Query read: GlorpItemWithQty.
	query orderBy: [:item| item id].
	items := session3 execute: query.
	self assert: items first totalSales isNil.
	self assert: items last totalSales isNil.
]

{ #category : #'test-updating' }
GlorpRelativeFieldTest >> testRelativeFieldOneRowNULLOneNotNULL [
	"Have a null and a non-null row.  This passes on Postgres unbound and bound but the bound only works because Postgres bound does not group."

	| session1 session2 query items session3 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo:		"read, check values, set to nil"
		[query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		self assert: items first totalSales = 0.
		self assert: items last totalSales = 500s.
		items first totalSales: nil.
		items last totalSales: 250].

	session2 := GlorpSessionResource current newSession.
	session2 inUnitOfWorkDo:		"read, check values are nil, set to 20"
		[query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session2 execute: query.
		self assert: items first totalSales isNil.
		self assert: items last totalSales = 250.
		items do: [:each | each totalSales: 20].
		"Before we write, we hold the values we set."
		items do: [:each | self assert: each totalSales = 20]].
	"After we write, we are syched with the database, so are nil again (if we are a returning command, not otherwise)."
	(self supportsReturningValuesForSession: session1) ifTrue:
		[self assert: items first totalSales isNil.
		self assert: items last totalSales = 20].
	"read, check values are still nil"
	session3 := GlorpSessionResource current newSession.
	query := Query read: GlorpItemWithQty.
	query orderBy: [:item| item id].
	items := session3 execute: query.
	self assert: items first totalSales isNil.
	self assert: items last totalSales = 20s.
]

{ #category : #'test-updating' }
GlorpRelativeFieldTest >> testRelativeFieldParallelDecrements [
	"This test validates the behavior of relative field updates, which don't need to know the current values of their target fields. They do know the relative change in value between when their session read them and wrote them, which is what gets added to the target in the database. This test uses 2 separate sessions, oblivious about each other, and involves several steps.
	Step 1: The first session loads values from the Db. It sees qty #(100 50) for the two rows.
	Step 2: The second session does the same, and updates these values to #(10 10).
	Step 3: The first session now updates the qty from #(100 50), unaware these are stale numbers, to (300 300).
	Step 4: The transaction commits, and the database qty is now #(325 375),
			since (300-100=200)+10=210  and (300-50=250)+10=260.
	Step 5: A fresh session reads from the database and confirms these values."

	| session1 session2 session3 query1 query2 query3 items1 items2 items3 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
			["Read the current values in the first session. Values are #(100 50)"
			query1 := Query read: GlorpItemWithQty.
			query1 orderBy: [:item | item id].
			items1 := session1 execute: query1.
			
			session2 := GlorpSessionResource current newSession.
			session2 inUnitOfWorkDo: 
					["Read the items, and then update their quantities, undetected by session1."
					query2 := Query read: GlorpItemWithQty.
					query2 orderBy: [:item | item id].
					items2 := session2 execute: query2.
					items2 do: [:each | each qty: 10]].	"Set the target qty to 10. (update -90, update -40)."

			"Use the already-cached items from session1, whose values are still #(100 50)"
			items1 do: [:each | each qty: 300]].	"Update the quantity. (update +200, update +250)."

	"Determine the actual quantities."
	session3 := GlorpSessionResource current newSession.
	query3 := Query read: GlorpItemWithQty.
	query3 orderBy: [:item | item id].
	items3 := session3 execute: query3.
	self assert: items3 first qty = 210.
	self assert: items3 last qty = 260.
]

{ #category : #'test-updating' }
GlorpRelativeFieldTest >> testRelativeFieldParallelIncrements [
	"Read values, apply two updates in separate sessions, then read again from the database and verify values are the summary of the two differences."

	| session1 session2 session3 query1 query2 query3 items1 items2 items3 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
			["Read the current values in the first session. Values are #(100 50)"
			query1 := Query read: GlorpItemWithQty.
			query1 orderBy: [:item | item id].
			items1 := session1 execute: query1.
			
			session2 := GlorpSessionResource current newSession.
			session2 inUnitOfWorkDo: 
					["Read the items, and then update their quantities, undetected by session1."
					query2 := Query read: GlorpItemWithQty.
					query2 orderBy: [:item | item id].
					items2 := session2 execute: query2.
					items2 do: [:each | each qty: 125]].	"Set the target qty to 125. (update +25, update +75)."

			"Use the already-cached items from session1, whose values are still #(100 50)"
			items1 do: [:each | each qty: 300]].	"Update the quantity. (update +200, update +250)."

	"Determine the actual quantities."
	session3 := GlorpSessionResource current newSession.
	query3 := Query read: GlorpItemWithQty.
	query3 orderBy: [:item | item id].
	items3 := session3 execute: query3.
	self assert: items3 first qty = 325.
	self assert: items3 last qty = 375
]

{ #category : #'test-multiple fields' }
GlorpRelativeFieldTest >> testSecondRelativeFieldOnlyUsage [
	"Update the 2nd relative field, leaving the first unchanged (so it's contents won't be part of our update query)."
	| query items session1 session2 |
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query read: GlorpItemWithQty.
		query orderBy: [:item| item id].
		items := session1 execute: query.
		items do: [:each| each totalSales: 200.0]].		"Set the target totalSales to 125."

	session2 := GlorpSessionResource current newSession.
	"SetUp has already written these values to the db, so update their quantities."
	query := Query read: GlorpItemWithQty.
	query orderBy: [:item| item id].
	items := session2 execute: query.
	self assert: items first totalSales = 200.0.
	self assert: items last totalSales = 200.0.
]

{ #category : #'test-multiple fields' }
GlorpRelativeFieldTest >> testSecondRelativeFieldOnlyUsageSingleRow [
	"Update the 2nd relative field, leaving the first unchanged (so it's contents won't be part of our update query).
	This test only updates one row, so it won't use array-binding (if that is available for the current platform)."
	| query session1 session2 itemWritten itemRead|
	session1 := GlorpSessionResource current newSession.
	session1 inUnitOfWorkDo: 
		["Read the items, and update their quantities."
		query := Query readOneOf: GlorpItemWithQty.
		itemWritten := session1 execute: query.
		itemWritten totalSales: 200.0].		"Set the target totalSales to 125."

	session2 := GlorpSessionResource current newSession.
	"SetUp has already written these values to the db, so update their quantities."
	query := Query readOneOf: GlorpItemWithQty where: [:each| each id = itemWritten id].
	itemRead := session2 execute: query.
	self assert: itemRead totalSales = 200.0.
]
