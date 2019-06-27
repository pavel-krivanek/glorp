"
This test verifies that nested #anySatisfy: blocks do not throw an exception.
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
