"
This builds full-blown persistent objects with descriptors. This is the most common type of builder.

Instance Variables:
	relatedBuilder	<ObjectBuilder>	If I am alsoFetched, I knit myself to the instance of my relatedBuilder.
	queryCache	<ObjectBuilder>
"
Class {
	#name : #ObjectBuilder,
	#superclass : #ElementBuilder,
	#instVars : [
		'relatedBuilder',
		'queryCache'
	],
	#category : #'GlorpQueries-Glorp'
}

{ #category : #'VisualWorks metadata' }
ObjectBuilder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'building objects' }
ObjectBuilder >> buildObjectFrom: anArray [
	self row: anArray.
	self requiresPopulating ifTrue: [self populateInstance].
	(self system shouldResetExpiryTimeForObjectOfClass: instance class readFrom: self query)
		ifTrue: [self session markAsCurrentOfClass: instance class key: self primaryKey].
]

{ #category : #testing }
ObjectBuilder >> buildsObjects [
	^true.
]

{ #category : #copying }
ObjectBuilder >> cacheBuilderRelationships: aCollection [
	"By this point, we have all our builders, so find if there is one to whose instance we will knit our instance."

	expression canKnit ifFalse: [^self].
	relatedBuilder := aCollection
		detect: [:each | each buildsObjects and: [each expression == expression base]]
		ifNone: [nil].

"Clone any changes to DictionaryBuilder>>cacheBuilderRelationships: as needed."
]

{ #category : #accessing }
ObjectBuilder >> cachedQueryFor: aMapping ifAbsent: aBlock [
	"If we have no queries - the usual case - exit as quick as we can and do not initialize the cache."

	queryCache isNil ifTrue: [^aBlock value].
	^queryCache at: aMapping ifAbsent: aBlock
]

{ #category : #accessing }
ObjectBuilder >> cachedQueryFor: aMapping put: aQuery [
	"Save a query which we will use when constructing filtered queries, or as a NullQuery to avoid getting something we will alsoFetch."

	queryCache isNil ifTrue: [queryCache := IdentityDictionary new: 5].
	^queryCache at: aMapping put: aQuery
]

{ #category : #'building objects' }
ObjectBuilder >> canBuild [
	"If we have a regular object with a nil primary key, or if we have an embedded object whose values are all nil, we can't build anything.  This could be due to an outer join, or to a ConditionalMapping whose representativeMapping is a relationship but whose current case is not."

	^self descriptor mapsPrimaryKeys
		ifTrue: [self primaryKey notNil]
		ifFalse: [true]
]

{ #category : #'building objects' }
ObjectBuilder >> canCache [
	| keyFields |
	keyFields := self descriptor keyFields.
	^keyFields notNil and: [keyFields notEmpty].
]

{ #category : #accessing }
ObjectBuilder >> canCauseDuplicateRows [
	^expression class == MappingExpression and: [expression mapping isToManyRelationship].
]

{ #category : #accessing }
ObjectBuilder >> command [
	^cursor command.
]

{ #category : #'building objects' }
ObjectBuilder >> createObjectOfClass: aClass [
	"Try to create objects using new, so initialization can run. But if we can't do it, then just use basicNew."
	^[aClass new] on: Error do: [:ex | ex return: aClass basicNew].
]

{ #category : #accessing }
ObjectBuilder >> descriptor [
	
	^expression descriptor.
]

{ #category : #'selecting fields' }
ObjectBuilder >> fieldsForSelectStatement [
	^self fieldsFromThePerspectiveOfTheMainSelect: self fieldsFromMyPerspective.
]

{ #category : #'selecting fields' }
ObjectBuilder >> fieldsFromMyPerspective [
	^query returnProxies 
		ifTrue: [self descriptor table primaryKeyFields]
		ifFalse: [self descriptor fieldsForSelectStatement]
]

{ #category : #'selecting fields' }
ObjectBuilder >> fieldsFromThePerspectiveOfTheMainSelect: aCollection [
	^expression translateFields: aCollection.
]

{ #category : #'building objects' }
ObjectBuilder >> findInstanceForRow: aRow proxyType: proxyType [
	instance := nil.
	self row: aRow.
	self canBuild ifFalse: [^self].
	(self shouldProxyInstanceFor: proxyType)
		ifTrue: [^self newProxyWithNewQueryForClass: proxyType].
	self lookupCachedObject.
	self instanceExistsButIsDeleted
		ifTrue:
			[instance := nil.
			^self].
	instance isNil
		ifFalse:
			[requiresPopulating := requiresPopulating | query shouldRefresh.
			^self].
	requiresPopulating := true.
	instance := self createObjectOfClass: (self descriptor
		describedConcreteClassFor: self row
		withBuilder: self).
	self canCache ifTrue: [self session cacheAt: self primaryKey put: instance].
]

{ #category : #initializing }
ObjectBuilder >> initialize [

	requiresPopulating := false.
	isExpired := false.
]

{ #category : #accessing }
ObjectBuilder >> instance: anObject [
	instance := anObject
]

{ #category : #'building objects' }
ObjectBuilder >> instanceDescriptor [
	"Return the descriptor for the instance we're going to build. Note that we have to look it up by instance in order to find subclass. "
	| basicDescriptor |
	instance isNil ifTrue: [^nil].
	basicDescriptor := self system descriptorFor: instance.
	basicDescriptor isNil ifFalse: [^basicDescriptor].
	^expression descriptor.
]

{ #category : #'building objects' }
ObjectBuilder >> instanceExistsButIsDeleted [
	instance isNil ifTrue: [^false].
	instance := self session filterDeletionFrom: instance.
	^instance isNil.
]

{ #category : #'building objects' }
ObjectBuilder >> knitResultIn: aCursoredStream [
	"Connect up our built object with any other objects that reference it. Used if we retrieve more than one thing in the same query."

	relatedBuilder isNil ifTrue: [^self].
	relatedBuilder instance isNil ifTrue: [^self].
	expression mapping knitFromBuilder: relatedBuilder toBuilder: self.
]

{ #category : #'building objects' }
ObjectBuilder >> lookupCachedObject [
	| resultClass |
	self canBuild ifFalse: [^self].
	self canCache ifTrue:
		[resultClass := expression descriptor describedClass.
		(self session hasExpired: resultClass key: self primaryKey)
			ifTrue:
				[instance := self session expiredInstanceOf: resultClass key: self primaryKey.
				requiresPopulating := true.
				isExpired := true]
			ifFalse:
				[instance := self session cacheLookupForClass: resultClass key: self primaryKey.
				requiresPopulating := instance isNil]].
]

{ #category : #'building objects' }
ObjectBuilder >> newProxyWithNewQueryForClass: aClass [
	| parameters |
	parameters := IdentityDictionary new.
	self descriptor primaryTable primaryKeyFields
		do:
			[:eachField | parameters at: eachField put: (self valueOfField: eachField)].
	instance := aClass new
		session: self session;
		parameters: parameters;
		query: self queryForNewProxy.
	self session addToReaper: instance.
	^self.
]

{ #category : #'building objects' }
ObjectBuilder >> populateInstance [
	| tracker |
	key isNil ifTrue: [^self].
	self instanceDescriptor populateObject: instance inBuilder: self.
	tracker := self session modificationTracker.
	tracker isNil ifFalse: [tracker track: instance].
]

{ #category : #copying }
ObjectBuilder >> postCopy [
	super postCopy.
	queryCache := nil.
]

{ #category : #accessing }
ObjectBuilder >> primaryKey [
	"We use self as a special guard value to indicate that we have not already found the key."

	key == self ifFalse: [^key].
	self canCache ifFalse: [^nil].
	key := self descriptor keyFields collect: [:each | self valueOfField: each].
	"If we get here, we have a collection of one or more primaryKey values.  If there is only one, key is set to be that sole value (to be economical and performant - or, it might be claimed, 'clever').  Of course, this means we must make all accesses robust to the fact that it might be a value or a collection of values.  Here we ensure that a nil check also works when the original was #(nil nil ... nil) as well as when it was #(nil).  Arguably we need only check the first value for nil since a primaryKey value should not be NULL, but let's let any cases of e.g. #(nil 27) proceed since they would probably indicates errors we want to see and fix."
	key size = 1
		ifTrue: [key := key first]
		ifFalse: [(key allSatisfy: [:each | each isNil]) ifTrue: [key := nil]].
	^key
]

{ #category : #printing }
ObjectBuilder >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	expression printOn: aStream.
	aStream nextPut: $).
]

{ #category : #'building objects' }
ObjectBuilder >> queryForNewProxy [
	"Create a proxy with a primary key query in which the parameters are the primary key fields. We can't just reuse a mapping's query, it has to be a new primary key one, because the mapping's query has just run and been told to return proxies. This kind of stinks"
	| whereExpression |
	whereExpression := Join new.
	self descriptor primaryTable primaryKeyFields do: [:eachField | 
		whereExpression addSource: eachField target: eachField].
	^Query
		readOneOf: query resultClass 
		where: whereExpression
]

{ #category : #copying }
ObjectBuilder >> reconcileWithBuilders: oldCollection andCopy: newCollection [
	| initialValueQuery |
	relatedBuilder isNil ifTrue: [^self].
	relatedBuilder := newCollection at: (oldCollection indexOf: relatedBuilder).
	"Ensure my relatedBuilder does not redundantly try to get my value."
	initialValueQuery := ShortCircuitQuery new.
	expression mapping attribute isCollectionAttribute ifTrue:
		[initialValueQuery resultTemplate: expression mapping attribute newCollection].
	relatedBuilder cachedQueryFor: expression mapping put: initialValueQuery.
]

{ #category : #accessing }
ObjectBuilder >> requiresPopulating [
	^requiresPopulating and: [self returnProxies not].
]

{ #category : #accessing }
ObjectBuilder >> requiresPopulating: aBoolean [
	requiresPopulating := aBoolean
]

{ #category : #accessing }
ObjectBuilder >> returnProxies [
	^query returnProxies.
]

{ #category : #accessing }
ObjectBuilder >> returnValueIn: aCursoredStream [
	"If we're a to-many relationship, what we retrieve: is the collection containing us, not the individual items"
	| relatedBuilder |
	expression canKnit ifFalse: [^self instance].
	expression mapping isToManyRelationship ifFalse: [^self instance].
	relatedBuilder := aCursoredStream elementBuilderFor: expression base.
	(relatedBuilder isNil or: [relatedBuilder instance isNil]) ifTrue: [^self instance].
	^expression mapping getValueFrom: relatedBuilder instance.
]

{ #category : #'building objects' }
ObjectBuilder >> shouldProxyInstanceFor: proxyType [
	^proxyType notNil.
]
