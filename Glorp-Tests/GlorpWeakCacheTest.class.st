Class {
	#name : #GlorpWeakCacheTest,
	#superclass : #GlorpCacheTest,
	#instVars : [
		'mourned'
	],
	#category : #'Glorp-Tests'
}

{ #category : #'instance creation' }
GlorpWeakCacheTest class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #support }
GlorpWeakCacheTest >> checkCacheExhaustivelyFor: aBlock [
	"Check to make sure the cache satisfies the criteria. Since this relies on unpredictable finalization, do a full 10 garbage collect then wait iterations. Don't return early, because we're checking to see that finalization *doesn't* happen"
	self assert: (self doesCacheExhaustivelySatisfy: aBlock).
]

{ #category : #support }
GlorpWeakCacheTest >> checkCacheFor: aBlock [
	"Check to make sure the cache satisfies the criteria. Since this relies on unpredictable finalization, do up to 10 garbage collect then wait iterations. If it's true before that, return early, but if it's not true at the end, fail"
	self assert: (self doesCacheSatisfy: aBlock).
]

{ #category : #support }
GlorpWeakCacheTest >> doesCacheExhaustivelySatisfy: aBlock [
	| result |
	result := false.
	10
		timesRepeat:
			[Dialect garbageCollect.
			(Delay forMilliseconds: 100) wait.
			result := aBlock value].
	^result.
]

{ #category : #support }
GlorpWeakCacheTest >> doesCacheSatisfy: aBlock [
	10
		timesRepeat:
			[Dialect garbageCollect.
			(Delay forMilliseconds: 100) wait.
			aBlock value ifTrue: [^true]].
	^false.
]

{ #category : #initializing }
GlorpWeakCacheTest >> initialize [
]

{ #category : #support }
GlorpWeakCacheTest >> mournKeyOf: anEphemeron [
	mourned := true.
]

{ #category : #support }
GlorpWeakCacheTest >> setUp [
	super setUp.
	system cachePolicy: WeakVWCachePolicy new.
	mourned := false.
]

{ #category : #tests }
GlorpWeakCacheTest >> testEphemeralValue [
	| value ephemeron |
	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	value := Object new.
	ephemeron := (Dialect smalltalkAt: #EphemeralValue) key: 'abc' value: value.
	ephemeron manager: self.
	Dialect garbageCollect.
	value := nil.
	self should: [10 timesRepeat: [
		mourned ifFalse: [Dialect garbageCollect.
		(Delay forMilliseconds: 100) wait]].
		mourned].
]

{ #category : #tests }
GlorpWeakCacheTest >> testEphemeralValueDictionary [
	| value dict done |
	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	value := Object new.
	dict := WeakVWCachePolicy new dictionaryClass new.
	dict at: 'abc' put: value.
	Dialect garbageCollect.
	value := nil.
	done := false.
	self should:
		[10	timesRepeat:
			[done ifFalse: [
				Dialect garbageCollect.
				(Delay forMilliseconds: 100) wait.
				done := dict size = 0]].
			 done].
]

{ #category : #tests }
GlorpWeakCacheTest >> testEphemeron [
	| value ephemeron |
	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	value := Object new.
	ephemeron := (Dialect smalltalkAt: #Ephemeron) key: value value: 'abc'.
	ephemeron manager: self.
	Dialect garbageCollect.
	value := nil.
	self should: [10 timesRepeat: [
		mourned ifFalse: [Dialect garbageCollect.
		(Delay forMilliseconds: 100) wait]].
		mourned].
]

{ #category : #tests }
GlorpWeakCacheTest >> testEphemeronDictionary [
	| value dict done |
	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	value := Object new.
	dict := (Dialect smalltalkAt: #EphemeronDictionary) new.
	dict at: value put: 'abc'.
	Dialect garbageCollect.
	value := nil.
	done := false.
	self should:
		[10	timesRepeat:
			[done ifFalse: [
				Dialect garbageCollect.
				(Delay forMilliseconds: 100) wait.
				done := dict size = 0]].
			 done].
]

{ #category : #tests }
GlorpWeakCacheTest >> testLargeWeakDictionary [
	| elements size customers newElements |
	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	system cachePolicy numberOfElements: 1.
	size := 2 raisedTo: 14.
	customers := OrderedCollection new: size.
	1 to: size do: [:i | | cust |
		cust := GlorpCustomer new.
		customers add: cust.
		cache at: i insert: cust].
	elements := cache numberOfElements.
	self assert: elements = (2 raisedTo: 14).
	customers := nil.
	Dialect garbageCollect.
	(Delay forSeconds: 2) wait.
	Dialect garbageCollect.
	(Delay forSeconds: 1) wait.
	newElements := cache numberOfElements.
	self assert: newElements = 1.
]

{ #category : #tests }
GlorpWeakCacheTest >> testUnreferencedExcessObjectsAreRemoved [
	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	system cachePolicy numberOfElements: 1.
	cache at: 3 insert: GlorpCustomer new.
	cache at: 4 insert: GlorpCustomer new.
	self checkCacheFor: [(cache containsObjectForClass: GlorpCustomer key: 3) not].
	self assert: (cache containsObjectForClass: GlorpCustomer key: 4).
]

{ #category : #tests }
GlorpWeakCacheTest >> testUnreferencedObjectsAreRemoved [

	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	system cachePolicy numberOfElements: 0.
	cache at: 3 insert: GlorpCustomer new.
	self
		checkCacheFor: [(cache containsObjectForClass: GlorpCustomer key: 3) not].
]

{ #category : #tests }
GlorpWeakCacheTest >> testUnreferencedObjectsAreRemovedInTheRightOrder [
	| customer |
	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	system cachePolicy numberOfElements: 1.
	cache at: 3 insert: GlorpCustomer new.
	cache at: 4 insert: GlorpCustomer new.
	customer := cache lookupClass: GlorpCustomer key: 3.
	self deny: customer isNil.
	cache at: 3 insert: customer.
	self checkCacheFor: [(cache containsObjectForClass: GlorpCustomer key: 4) not].
	self assert: (cache containsObjectForClass: GlorpCustomer key: 3).
]

{ #category : #tests }
GlorpWeakCacheTest >> testUnreferencedObjectsNotRemovedDueToExtraReferences [
	Dialect isVWWithNameSpaces ifFalse: [ ^self ].
	cache at: 3 insert: GlorpCustomer new.
	self checkCacheExhaustivelyFor: [(cache containsObjectForClass: GlorpCustomer key: 3)].
]
