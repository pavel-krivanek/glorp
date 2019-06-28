"
This test verifies that nested #anySatisfy: blocks do not throw an exception.  It also tests #isEmpty and #sqlCount in #retrieve: blocks, and in ANDed and ORed queries.

Instance Variables:
	session		<GlorpSession>	session for test, created from DefaultLogin via GlorpSessionResource
"
Class {
	#name : #AnySatisfyTest,
	#superclass : #TestCase,
	#instVars : [
		'session'
	],
	#category : #GlorpDBTests
}

{ #category : #resources }
AnySatisfyTest class >> resources [
	^Array with: GlorpSessionResource
]

{ #category : #'VisualWorks metadata' }
AnySatisfyTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'XProgramming.SUnit'
	)

]

{ #category : #utility }
AnySatisfyTest >> convertToBoolean: anObject [
	"Not all databases support explicit true/false.  Provide an explicit conversion until/unless we complete automatic conversion."

	| platformBoolType platformBoolConverter |
	platformBoolType := session platform boolean.
	platformBoolConverter := platformBoolType converterForStType: Boolean.
	^platformBoolConverter convert: anObject fromDatabaseRepresentationAs: platformBoolType
]

{ #category : #'example data' }
AnySatisfyTest >> createTestData: aSession [
	| bonus itemBonus |
	aSession inUnitOfWorkDo:
		[| item order lineItem customer |
		customer := aSession readOneOf: ASCustomer where: [:cust | cust id = 5].
		customer ifNil:
			[customer := ASCustomer new id: 5; name: 'Informing AG' yourself.
			aSession register: customer].
		customer orders isEmpty
			ifTrue: 
				[order := ASOrder new orderNo: 10; customer: customer; yourself.
				aSession register: order.
				customer orders add: order]
			ifFalse: [order := customer orders first].
		item := aSession readOneOf: ASItem where: [:itm | itm id = 20].
		item ifNil:
			[item := ASItem new id: 20; name: 'ost'; yourself.
			aSession register: item].
		order lineItems isEmpty ifTrue: 
			[lineItem := ASOrderLineItem new posNo: 30; quantity: 15; price: 25; item: item; order: order; yourself.
			aSession register: lineItem.
			order lineItems add: lineItem].
		bonus := aSession readOneOf: ASBonus where: [:bos | bos id = 27].
		bonus ifNil:
			[bonus := ASBonus new id: 27; name: 'BigTimeSavings'; credits: 100; yourself.
			aSession register: bonus].
		item bonuses isEmpty ifTrue:
			[itemBonus := ASItemBonus new item: item; bonus: bonus; yourself.
			aSession register: itemBonus.
			item bonuses add: itemBonus]].
]

{ #category : #running }
AnySatisfyTest >> setUp [
	session := GlorpSessionResource current newSession.
	session system: (AnySatisfyDescrSystem forPlatform: session platform).
	self createTestData: session.
]

{ #category : #running }
AnySatisfyTest >> testANDedQueryEmptyCheck [
	"To test empty (an aggregate call) in the AND: block, we must have the descriptor set on the base.  For this, the query's base needs to know its descriptor, which it gets from the system which the query gets from its session.  Thus the session that will be used to execute the query (or one using the identically-equal system) must be provided earlier and the base set up from it."

	| customer query |
	 query := Query readOneOf: ASCustomer where:
		[:cust | cust name = 'Informing AG'].
	query setUpBaseFromSession: session.
	query AND: [:cust | cust orders notEmpty].
	customer := query execute.
	self assert: customer name = 'Informing AG'.
	self deny: customer orders isEmpty.
]

{ #category : #running }
AnySatisfyTest >> testANDedQuerySqlCount [
	"To do a count (an aggregate call) in an OR: block appended to a query, we must have the descriptor set on the base.  For this, the query needs to know the system which it gets from the session, so the session that will be used to execute the query must be provided earlier, and the base set from it."

	| customer query |
	 query := Query readOneOf: ASCustomer where:
		[:cust | cust name = 'Informing AG'].
	query setUpBaseFromSession: session.
	query AND: [:cust | cust orders sqlCount = 1].
	customer := query execute.
	self assert: customer name = 'Informing AG'.
	self assert: customer orders size = 1.
]

{ #category : #running }
AnySatisfyTest >> testAnySatisfyNested [
	| customer |
	customer := session readOneOf: ASCustomer where:
		[:cust |
		cust orders anySatisfy: 
			[:order |
			order lineItems anySatisfy:
				[:lineItem | (lineItem item name like: 'os%') & (lineItem quantity > 0)]]].
	self assert: (customer orders anySatisfy:
				[:order | order lineItems anySatisfy:
					[:lineItem | (lineItem item name like: 'os%') and: [lineItem quantity > 0]]])
		description: 'Nested where-block anySatisfy: does not agree with image anySatisfy:'.
]

{ #category : #running }
AnySatisfyTest >> testAnySatisfyTwiceNested [
	| customer |
	customer := session readOneOf: ASCustomer where:
		[:cust |
		cust name = 'Informing AG' AND:
			[cust orders anySatisfy:
				[:order |
				order lineItems anySatisfy:
					[:lineItem |
					lineItem item bonuses anySatisfy:
						[:itemBonus | itemBonus bonus credits > 50]]]]].
	self assert: customer name = 'Informing AG'.
	self assert: (customer orders anySatisfy:
				[:order | order lineItems anySatisfy:
					[:lineItem | lineItem item bonuses anySatisfy:
						[:itemBonus | itemBonus bonus credits > 50]]])
		description: 'Three-deep where-block anySatisfy: does not agree with image anySatisfy:'.
]

{ #category : #running }
AnySatisfyTest >> testORedQueryEmptyCheck [
	"To test empty (an aggregate call) in the OR: block, we must have the descriptor set on the base.  For this, the query needs to know the system which it gets from the session, so the session that will be used to execute the query must be provided earlier."

	| customer query |
	 query := Query readOneOf: ASCustomer where:
		[:cust | cust name = 'Informing AG'].
	query setUpBaseFromSession: session.
	query OR: [:cust | cust orders isEmpty].
	customer := query execute.
	"These assertions assume there are no customers without orders."
	self assert: customer name = 'Informing AG'.
	self deny: customer orders isEmpty.
]

{ #category : #running }
AnySatisfyTest >> testRetrieveIsEmpty [
	"To test empty (an aggregate call) in a retrieve block, we must have the descriptor set on the base.  For this, the query's base needs to know its descriptor, which it gets from the system which the query gets from its session.  Thus the session that will be used to execute the query (or one using the identically-equal system) must be provided earlier and the base set up from it."

	| query resultArray |
	 query := Query readOneOf: ASCustomer where:
		[:cust | cust name = 'Informing AG' AND: [cust orders notEmpty]].
	query setUpBaseFromSession: session.
	query retrieve: [:each | each name].
	query retrieve: [:each | each orders isEmpty].
	resultArray := query execute.
	self assert: resultArray first = 'Informing AG'.
	self deny: (self convertToBoolean: resultArray last)
		description: 'We read a customer with orders but retrieved no orders'.
]

{ #category : #running }
AnySatisfyTest >> testRetrieveSqlCount [
	"To do a count (an aggregate call) in a retrieve block, we must have the descriptor set on the base.  For this, the query needs to know the system which it gets from the session, so the session that will be used to execute the query must be provided earlier, and the base set from it."

	| query resultArray |
	 query := Query readOneOf: ASCustomer where:
		[:cust | cust name = 'Informing AG' AND: [cust orders notEmpty]].
	query setUpBaseFromSession: session.
	query retrieve: [:each | each name].
	query retrieve: [:each | each orders sqlCount].
	resultArray := query execute.
	self assert: resultArray first = 'Informing AG'.
	self assert: resultArray last = 1.
]
