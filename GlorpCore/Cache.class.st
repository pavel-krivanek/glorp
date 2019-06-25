"
This is the per-class cache of instances read from the database.  A CachePolicy is assigned by the descriptor (or, if the cache's class has no descriptor in the session's system, by default) and controls whether and how the cached instances are expired.

Instance Variables:
	mainCache	<CacheManager>	manages a group of class-specific caches of instances read in a session



"
Class {
	#name : #Cache,
	#superclass : #UnmanagedCache,
	#instVars : [
		'mainCache'
	],
	#category : #'GlorpCore-Glorp'
}

{ #category : #'instance creation' }
Cache class >> newFor: aClass in: aCacheManager [
	| newCache descriptor |
	newCache := Cache new.
	newCache mainCache: aCacheManager.
	descriptor := aCacheManager system descriptorFor: aClass.
	descriptor isNil
		ifTrue: [newCache cachePolicy: CachePolicy default]
		ifFalse: [newCache cachePolicy: descriptor cachePolicy].
	^newCache
]

{ #category : #'VisualWorks metadata' }
Cache class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #lookup }
Cache >> hasItemExpired: anItem [
	^(super hasItemExpired: anItem) and:
		[(mainCache session isRegistered: (policy contentsOf: anItem)) not]
]

{ #category : #accessing }
Cache >> mainCache [
	^mainCache
]

{ #category : #accessing }
Cache >> mainCache: aCacheManager [
	mainCache := aCacheManager
]

{ #category : #accessing }
Cache >> session [
	^mainCache session
]
