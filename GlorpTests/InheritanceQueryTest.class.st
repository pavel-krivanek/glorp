"
Test queries within queries on collections of subclasses in an inheritance tree.


"
Class {
	#name : #InheritanceQueryTest,
	#superclass : #GlorpSessionBasedTest,
	#category : #GlorpTests
}

{ #category : #'VisualWorks metadata' }
InheritanceQueryTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #utility }
InheritanceQueryTest >> queryForCustomerStation [
	| query |
	query := Query read: CustomerStation where:
		[:customerStation |
		customerStation successor anySatisfy:
			[:successor | successor id in: self queryForSuccessor]].
	query retrieve: [:customerStation | customerStation id].
	^query
]

{ #category : #utility }
InheritanceQueryTest >> queryForFeederStation [
	| query |
	query := Query read: FeederStation where: [:feederStation | feederStation id in: #(1 2 3 4)].
	query retrieve: [:feederStation | feederStation id].
	^query
]

{ #category : #utility }
InheritanceQueryTest >> queryForSuccessor [
	| query |
	query := Query read: Successor where:
		[:successor | successor successorFeeder id in: self queryForFeederStation].
	query retrieve: [:successor | successor id].
	^query
]

{ #category : #support }
InheritanceQueryTest >> setUp [
	super setUp.
	system := InheritanceQueryDescriptorSystem forPlatform: session platform.
	session system: system.

	session beginTransaction.
	session beginUnitOfWork.
	self writeTestHarness.
	session commitUnitOfWork.
]

{ #category : #support }
InheritanceQueryTest >> tearDown [
	session rollbackTransaction.
	super tearDown.
]

{ #category : #running }
InheritanceQueryTest >> testInnerQueries [
	self assert: (session execute: self queryForCustomerStation) size = 1.
]

{ #category : #running }
InheritanceQueryTest >> testLocalInnerQueries [
	"The same as testInnerQueries, but with all the queries defined within the block (should run the same)."

	| query |
	query := Query read: CustomerStation where:
		[:customerStation |
		customerStation successor anySatisfy: 
			[:successor || query2 |
			query2 := Query read: Successor where: 
				[:successor1 || feederQuery |
				feederQuery := Query read: FeederStation where:
					[:feederStation | feederStation id in: #(1 2 3 4)].
				feederQuery retrieve: [:feederStation | feederStation id].
				successor1 successorFeeder id in: feederQuery].
			query2 retrieve: [:successor1 | successor1 id].
			successor id in: query2]].
	query retrieve: [:customerStation | customerStation id].
	self assert: (session execute: query) = #(10).
]

{ #category : #running }
InheritanceQueryTest >> testSubSelectRebuild [
	"The OR in the anySatisfy block works for a successor with both successorCustomer and successorFeeder values.  It does not work when one is nil because the nil check ends up being asked of the object, not the successor object's field ponting to it.  (Maybe fix with outer join?)"

	| query stations unproxiedSuccessor |
	query := Query read: Station where:
		[:station |
		station successor anySatisfy:
			[:successor |
			successor successorFeeder id = 3 OR:
				[successor successorCustomer id = 1]]].
	stations := session execute: query.
	self assert: stations size = 1.
	unproxiedSuccessor := stations first successor first.
	self assert: unproxiedSuccessor successorFeeder id = 3.
]

{ #category : #running }
InheritanceQueryTest >> testTestHarness [
	"The test writes 5 customer stations and 5 feeder stations, thus adding 10 rows to the horizontally-mapped superclass's table (Station)."

	self assert: (session read: Station) size = 11.
	self assert: (session read: CustomerStation) size = 6.
	self assert: (session read: FeederStation) size = 5.
	self assert: (session read: Successor) size = 6.
]

{ #category : #utility }
InheritanceQueryTest >> writeTestHarness [
	|  feedStation1 feedStation2 feedStation3 custStation6 custStation7 custStation8 custStation9 custStation10 custStation11 |
	session register: (feedStation1 := FeederStation new id: 1; yourself).
	session register: (feedStation2 := FeederStation new id: 2; yourself).
	session register: (feedStation3 := FeederStation new id: 3; yourself).
	session register: ("feedStation4 := "FeederStation new id: 4; yourself).
	session register: ("feedStation5 := "FeederStation new id: 5; yourself).
	
	session register: (custStation6 := CustomerStation new id: 6; yourself).
	session register: (custStation7 := CustomerStation new id: 7; yourself).
	session register: (custStation8 := CustomerStation new id: 8; yourself).
	session register: (custStation9 := CustomerStation new id: 9; yourself).
	session register: (custStation10 := CustomerStation new id: 10; yourself).
	session register: (custStation11 := CustomerStation new id: 11; yourself).

	feedStation1 successor:
		(Array
			with: (Successor new id: 101; station: feedStation1; successorCustomer: custStation6; yourself)
			with: (Successor new id: 102; station: feedStation1; successorCustomer: custStation7; yourself)
			with: (Successor new id: 103; station: feedStation1; successorCustomer: custStation8; yourself)).
	feedStation2 successor:
		(Array
			with: (Successor new id: 104; station: feedStation2; successorCustomer: custStation9; yourself)
			with: (Successor new id: 105; station: feedStation2; successorCustomer: custStation10; yourself)).
	"This last line is the one found in #testSubSelectRebuild.  If we did not set both successorFeeder and successorCustomer, it would not be found (see the test's comment)."
	custStation10 successor:
		(Array
			with: (Successor new id: 106; station: custStation10; successorFeeder: feedStation3; successorCustomer: custStation11; yourself)).
]
