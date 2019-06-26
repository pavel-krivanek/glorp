"
An unmanaged cache, e.g. the preparedStatements cache of a VWDatabaseAccessor, has no CacheManager and so no access to a session or descriptor system.  It caches items added by the user and expires them according to its user-assigned policy.

Instance Variables:
	items	<Dictionary from: Object to: Object>	The cached items, keyed by their primary key values
	policy	<CachePolicy>	Controls whether data is held with the instance, whether and when it expires, etc.
	extraReferences	<nil|FixedSizeQueue>	Weak policies can keep a fixed number of instances



"
Class {
	#name : #UnmanagedCache,
	#superclass : #Object,
	#instVars : [
		'items',
		'policy',
		'extraReferences'
	],
	#category : #'GlorpCore-Glorp'
}

{ #category : #'VisualWorks metadata' }
UnmanagedCache class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #lookup }
UnmanagedCache >> at: key ifAbsent: aBlock [
	| item value |
	item := self basicAt: key ifAbsent: [^aBlock value].
	value := policy contentsOf: item.
	(self hasItemExpired: item) ifTrue:
		[policy takeExpiryActionForKey: key withValue: value in: self.
		item := self basicAt: key ifAbsent: [^aBlock value].
		value := policy contentsOf: item].
	self markEntryAsCurrent: value.
	^value
]

{ #category : #lookup }
UnmanagedCache >> at: key ifAbsentPut: aBlock [
	^self at: key ifAbsent: [self at: key put: aBlock value]
]

{ #category : #accessing }
UnmanagedCache >> at: key put: anObject [
	"Get an item for anObject (the item may be just anObject) and put it in the dictionary, being sure to return anObject, not the item."

	| newItem |
	newItem := policy cacheEntryFor: anObject.
	items at: key put: newItem.
	self markEntryAsCurrent: anObject.
	^anObject
]

{ #category : #private }
UnmanagedCache >> basicAt: anObject ifAbsent: aBlock [
	^items at: anObject ifAbsent: aBlock
]

{ #category : #accessing }
UnmanagedCache >> cachePolicy [
	^policy
]

{ #category : #accessing }
UnmanagedCache >> cachePolicy: aCachePolicy [
	policy := aCachePolicy.
	self initializeCache.
]

{ #category : #private }
UnmanagedCache >> do: aBlock [
	items do: aBlock.
]

{ #category : #lookup }
UnmanagedCache >> expireAll [
	items do: [:each | policy expire: each].
]

{ #category : #lookup }
UnmanagedCache >> expireKey: key ifAbsent: aBlock [
	| item |
	item := self basicAt: key ifAbsent: [^aBlock value].
	policy expire: item
]

{ #category : #private }
UnmanagedCache >> expiredInstanceFor: key [
	"Return the expired value.  Used for refreshing so that we don't recursively try and refresh when we get the instance to be refreshed."

	| item |
	item := self basicAt: key ifAbsent: [self error: 'No expired instance found'].
	(self hasItemExpired: item) ifFalse: [self error: 'No expired instance found'].
	^policy contentsOf: item
]

{ #category : #lookup }
UnmanagedCache >> hasExpired: key [
	| item |
	item := self basicAt: key ifAbsent: [^false].
	^self hasItemExpired: item
]

{ #category : #lookup }
UnmanagedCache >> hasItemExpired: anItem [
	^policy hasExpired: anItem
]

{ #category : #lookup }
UnmanagedCache >> includesKey: key [
	"Return true if we include the object. Don't listen to any expiry policy"
	self basicAt: key ifAbsent: [^false].
	^true
]

{ #category : #lookup }
UnmanagedCache >> includesKey: key as: anObject [
	"Return true if we include the object, and it matches the given object. If we include a different object with the same key, raise an exception. Don't listen to any expiry policy"
	| item value |
	item := self basicAt: key ifAbsent: [^false].
	value := policy contentsOf: item.
	value == anObject ifFalse: [
		(DuplicatePrimaryKeyException new: anObject existing: value) signal].
	^true
]

{ #category : #lookup }
UnmanagedCache >> includesKey: key withClass: aClass [
	"Return true if we include the object, and it matches our class. Don't listen to any expiry policy"
	| item value |
	item := self basicAt: key ifAbsent: [^false].
	value := policy contentsOf: item.
	^value isKindOf: aClass
]

{ #category : #initialize }
UnmanagedCache >> initializeCache [
	items := policy newItemsIn: self.
	extraReferences := policy collectionForExtraReferences.
]

{ #category : #private }
UnmanagedCache >> markAsCurrentAtKey: key [
	| item |
	item := self basicAt: key ifAbsent: [^false].
	^policy markEntryAsCurrent: item in: self
]

{ #category : #private }
UnmanagedCache >> markEntryAsCurrent: anItem [
	"The policy has told us to mark an item as current. This is only really useful for weak policies, which tell us to keep an additional pointer to the object in a (presumably) fixed-size collection."

	extraReferences isNil ifFalse: [extraReferences add: anItem].
]

{ #category : #finalization }
UnmanagedCache >> mournKeyOf: anEphemeron [
	policy takeExpiryActionForKey: anEphemeron key withValue: anEphemeron value in: self.
]

{ #category : #accessing }
UnmanagedCache >> numberOfElements [
	^items size
]

{ #category : #initialize }
UnmanagedCache >> release [
	policy release: self.
	extraReferences := nil.
]

{ #category : #lookup }
UnmanagedCache >> removeKey: key ifAbsent: aBlock [
	^items removeKey: key ifAbsent: aBlock
]

{ #category : #accessing }
UnmanagedCache >> session [
	"I am a freestanding cache with no CacheManager and so no session or descriptor system;  return nil and assume the caller will be OK with that as they are using me, not my subclass.  (See GlorpPreparedStatement>>glorpNoticeOfExpiryIn: for an example caller.)"

	^nil
]

{ #category : #accessing }
UnmanagedCache >> willRemoveItems [
	^policy willRemoveItems
]
