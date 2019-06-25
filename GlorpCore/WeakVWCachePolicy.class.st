"
This is a cache policy that uses VisualWorks 7.x weak references (ephemerons) to store references to objects, letting them vanish if not referenced. It uses the numberOfElements inst var as an indicator of how many objects to keep hard references to, preventing objects from disappearing too quickly.

Instance Variables:
"
Class {
	#name : #WeakVWCachePolicy,
	#superclass : #CachePolicy,
	#category : #GlorpCore
}

{ #category : #'VisualWorks metadata' }
WeakVWCachePolicy class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #expiry }
WeakVWCachePolicy >> collectionForExtraReferences [

	^FixedSizeQueue maximumSize: self numberOfReferencesToKeepAround.
]

{ #category : #accessing }
WeakVWCachePolicy >> dictionaryClass [
	^Dialect smalltalkAt: #EphemeralValueDictionary ifAbsent: [Dictionary].
]

{ #category : #expiry }
WeakVWCachePolicy >> markEntryAsCurrent: item in: aCache [
	aCache markEntryAsCurrent: item.
]

{ #category : #'initialize-release' }
WeakVWCachePolicy >> newItemsIn: aCache [
	| items |
	items := super newItemsIn: aCache.
	items manager: aCache.
	^items.
]

{ #category : #accessing }
WeakVWCachePolicy >> numberOfReferencesToKeepAround [
	^numberOfElements.
]
