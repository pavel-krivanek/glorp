"
This is a query that expects all the objects it might return to already be in memory, and in a collection from which it can pick them out by evaluating a block. This is used to implement filtered reads on a mapping. When one of the mappings fires, it reads all the relevant results, and so each instance  using that mapping can get the results out of memory without going to the database again.

Instance Variables:
	collectBlock	<Block>	A one-argument block we evaluate to actually collect up the results. That is, internally we are likely to have a more complex representation in the collection, e.g. an array containing various extra information plus the objects. This gets the objects out of the collection.
	collection	<(GlorpVirtualCollection of: Object)>	The collection on which we filter. Typically a virtual collection, at least for filtered reads, but can also handle a normal collection.
	filter	<Block>	The two-argument block we use to filter. The first argument is the entry from the collection, the second is the parameters to the query that were used.
	readsOneObject	<Boolean>	A duplicate of readsOneObject in AbstractReadyQuery. Do we return a collection, or a single result.

FilteringQuery is an optimization. A FilteringQuery is one that doesn't do any direct database access, but is given a collection and has two blocks, one to filter out which of the elements are appropriate, and another to transform the results into the final form. This can be used in a variety of places. One general one is when you have a deep hierarchy of objects. Fetching these one by one is expensive, but you may have a way of reading all the nodes associated with a particular tree into memory, and you just need to know how they're connected. You can make a virtual collection that reads them all then for each node the relationshps are defined as filtering queries that look for children, parents, or whatever.

The #useFilteredRead method for RelationshipMappings, does this for the particular case of reading sub-components. Suppose that we want to display a tabular view of customers. We want the person's name, city, and postal code, but the last two are in a separate Address object. If we do this naively, it will be very slow. We'll get all the people in one round-trip to the database, but then each time we're asked for an address it will go back and get them one by one. If, however, we tell it to use a filtered read for the address relationship, then the first time we ask *any* of those customers for their address it will get all the addresses for all the people fetched in that original query and then filter from that collection to find the appropriate one, needing only two database round-trips to display this information. Of course, if we'd used an #alsoFetch: or a #retrieve: we would have done it in one trip. This has a couple of possible advantages over that. If we do this for several things, particularly with to-many relationships, retrieve: can cause joins that have a lot of duplicate data. This will have less. Also, we don't have to specify this in the query, we can specify it in the metadata. OK, we can do that with #alsoFetch: too, but then that will *always* bring back the extra data. The advantage here is that we proxy, so we don't bring back the addresses if we don't use them at all, but as soon as we need one we bring in all the ones we might need. That makes it relatively easy to just set this option and have it do the right thing in multiple circumstances. This should work for any kind of relationship, including dictionaries, and to multiple levels.

There are some fairly complicated things going on internally in order to bring in the joins from the original query. The biggest one is the ability to have ""phantom mappings"". Suppose we read Customer and want to fetch Addresses. In order to attach the joins that were used in the original query for customers, we need to be able to describe the customer in terms of the address. We know how to describe the address in terms of the customer, because there's a relationship there, but there may not be a reverse one. So we construct a mapping (that doesn't correspond to any attribute), build up its information by reversing the original mapping, and then build an expression node for it and rebuild the original query's criteria on top of that new node.

We also need a way to do the filtering. For example, it's not enough to bring back the list of addresses; we need to be able to figure out who corresponds to what. So we retrieve, in addition to the data, the primary keys for the object we originally queried against. The filtering query we construct knows how to use this information to find the owner, and knows to get rid of those fields for the final result. This is also an issue if the result type is a dictionary - we need the virtual collection to give us back a simpler collection and have the filtering query construct the final dictionary.
"
Class {
	#name : #FilteringQuery,
	#superclass : #Query,
	#instVars : [
		'collection',
		'filter',
		'collectBlock'
	],
	#category : #GlorpQueries
}

{ #category : #'instance creation' }
FilteringQuery class >> on: aCollection filter: aBlock [
	^self new
		collection: aCollection;
 		filter: aBlock.
]

{ #category : #'VisualWorks metadata' }
FilteringQuery class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
FilteringQuery >> collectBlock [
	^collectBlock
]

{ #category : #accessing }
FilteringQuery >> collectBlock: aBlock [
	collectBlock:= aBlock.
]

{ #category : #accessing }
FilteringQuery >> collection [
	^collection
]

{ #category : #accessing }
FilteringQuery >> collection: aCollection [
	aCollection class == GlorpVirtualCollection ifTrue: [collectionType := aCollection getQuery collectionType].
	collection := aCollection.
]

{ #category : #executing }
FilteringQuery >> collectionTypesAgree: aCollection [
	^self collectionType new class == aCollection class
]

{ #category : #executing }
FilteringQuery >> executeWithParameters: parameterArray in: aSession [
	| filtered result |
	session := aSession.
	collection class == GlorpVirtualCollection
		ifTrue:
			[collection setSession: aSession.
			collection parameters: parameterArray.
			collection := collection realObjects].
	filtered := self filterResultsForParameters: parameterArray.
	result := self transformsValues
		ifTrue: [filtered collect: [:each | self valueFor: each]]
		ifFalse: [filtered].
	result := (self collectionTypesAgree: result) ifTrue: [result] ifFalse: [self resultCollectionFor: result readStream].
	^self readsOneObject
		ifTrue: [result detect: [:each | true] ifNone: [nil]]
		ifFalse: [result].
]

{ #category : #accessing }
FilteringQuery >> filter [
	^filter
]

{ #category : #accessing }
FilteringQuery >> filter: aBlock [
	filter := aBlock
]

{ #category : #executing }
FilteringQuery >> filterResultsForParameters: parameterArray [
	| passing seen |
	seen := IdentitySet new.
	passing := collection
		select:
			[:each | 
			| passes new value |
			passes := filter value: each value: parameterArray.
			value := self valueFor: each.
			passes
				ifTrue:
					[new := (seen includes: value) not.
					new ifTrue: [seen add: value]].
			passes and: [new]].
	^passing.
]

{ #category : #accessing }
FilteringQuery >> resultClass [
	collection class == GlorpVirtualCollection ifTrue: [^collection getQuery resultClass].
	^(collection detect: [:each | true] ifNone: [nil]) class
]

{ #category : #executing }
FilteringQuery >> transformsValues [
	^collectBlock notNil.
]

{ #category : #executing }
FilteringQuery >> valueFor: anObject [
	collectBlock isNil ifTrue: [^anObject].
	^collectBlock value: anObject.
]
