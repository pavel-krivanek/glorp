"
An abstract superclass for Glorp queries. Most query types will descend from this, but a couple are specialized.

Subclasses must implement the following messages:
	executing
		rowsFromDatabaseWithParameters:

Instance Variables:
	base	<BaseExpression>	In Glorp expressions it's very important that expressions we're trying to compose together are built on the same base, which represents the object that we're talking about in the query. This holds the base expression that we're expecting to use in this query.
	limit	<Integer>	Some databases support limiting the number of rows retrieved. If we can, we'll use this variable to set that.
	offset	<Integer>	Some databases support starting from a given point in the collection of retrievable rows, often used in combination with limit. So, e.g. get me the rows, sorted by name, starting at the 1012th and giving me 40 of them.
	proxyType	<Class | nil>	If this is nil, do not use proxies. Otherwise, use this class to create proxies for relationships. At the moment, likely to be either Proxy or TimedProxy.
	readsOneObject	<Boolean>	Do we return only one object, or a collection. That is, is this a readManyOf: or a readOneOf:
	resultClass	<Behavior>	What kind of objects are we looking for.
	shouldRefresh	<Boolean>	If the result is already in cache, should we refresh it according to what the database says, or just return it as is.
	tracing	<Tracing>	The tracing. This describes the graph of objects we will actually retrieve.
	whereClause	<GlorpExpression | BlockClosure>	What is the criteria on which we will filter the results?

The whereClause often begins as a one-argument BlockClosure.  At some point during construction or evaluation it is converted to a GlorpExpression.
"
Class {
	#name : #AbstractReadQuery,
	#superclass : #Query,
	#instVars : [
		'resultClass',
		'whereClause',
		'base',
		'limit',
		'offset',
		'proxyType',
		'shouldRefresh',
		'tracing'
	],
	#category : #'GlorpQueries-Glorp'
}

{ #category : #'instance creation' }
AbstractReadQuery class >> newQuery [
	^SimpleQuery new.
]

{ #category : #'instance creation' }
AbstractReadQuery class >> read: aClass [
	^self read: aClass where: nil
]

{ #category : #'instance creation' }
AbstractReadQuery class >> read: aClass limit: anInteger [
	^self read: aClass where: nil limit: anInteger.
]

{ #category : #'instance creation' }
AbstractReadQuery class >> read: aClass where: anExpression [
	^self read: aClass where: anExpression limit: nil
]

{ #category : #'instance creation' }
AbstractReadQuery class >> read: aClass where: anExpression limit: anInteger [
	^(self newQuery)
		limit: anInteger;
		initResultClass: aClass whereClause: anExpression singleObject: false;
		yourself
]

{ #category : #'instance creation' }
AbstractReadQuery class >> readManyOf: aClass limit: anInteger [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: #(#version '7.10' #sunset '8.0' #use #read:limit:).
	^self read: aClass limit: anInteger
]

{ #category : #'instance creation' }
AbstractReadQuery class >> readManyOf: aClass where: anExpression limit: anInteger [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: #(#version '7.10' #sunset '8.0' #use #read:where:limit:).
	^self read: aClass where: anExpression limit: anInteger
]

{ #category : #'instance creation' }
AbstractReadQuery class >> readOneOf: aClass [
	^self readOneOf: aClass where: nil.
]

{ #category : #'instance creation' }
AbstractReadQuery class >> readOneOf: aClass where: anExpression [
	^self newQuery
		initResultClass: aClass
		whereClause: anExpression
		singleObject: true.
]

{ #category : #'instance creation' }
AbstractReadQuery class >> returningManyOf: aClass [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: #(#version '7.10' #sunset '8.0' #use #read:).
	^self read: aClass
]

{ #category : #'instance creation' }
AbstractReadQuery class >> returningManyOf: aClass limit: anInteger [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: #(#version '7.10' #sunset '8.0' #use #read:limit:).
	^self read: aClass limit: anInteger
]

{ #category : #'instance creation' }
AbstractReadQuery class >> returningManyOf: aClass where: anExpression [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: #(#version '7.10' #sunset '8.0' #use #read:where:).
	^self read: aClass where: anExpression
]

{ #category : #'instance creation' }
AbstractReadQuery class >> returningManyOf: aClass where: anExpression limit: anInteger [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: #(#version '7.10' #sunset '8.0' #use #read:where:limit:).
	^self read: aClass where: anExpression limit: anInteger
]

{ #category : #'instance creation' }
AbstractReadQuery class >> returningOneOf: aClass [
	"returningOneOf: is a synonym of readOneOf:. This now seems more natural to me, to be consistent with session API."

	self deprecated: #(#version '7.10' #sunset '8.0' #use #readOneOf:).
	^self readOneOf: aClass.
]

{ #category : #'instance creation' }
AbstractReadQuery class >> returningOneOf: aClass where: anExpression [
	"returningOneOf: is a synonym of readOneOf:. This now seems more natural to me, to be consistent with session API."

	self deprecated: #(#version '7.10' #sunset '8.0' #use #readOneOf:where:).
	^self readOneOf: aClass where: anExpression
]

{ #category : #'VisualWorks metadata' }
AbstractReadQuery class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'boolean operations' }
AbstractReadQuery >> AND: anExpression [
	"Allows you to send OR: directly to a query to build up a query dynamically without needing to mess with the criteria explicitly.  If anExpression is a block calling platform-specific functions, or aggregation functions such as #sqlCount or #isEmpty, you must set up the base (by sending #setUpBaseFromSession:) before calling this, but usually this will not be needed."

	whereClause := (anExpression asGlorpExpressionOn: base)
		AND: ((whereClause asGlorpExpressionOn: base) asGeneralGlorpExpression).
]

{ #category : #'boolean operations' }
AbstractReadQuery >> OR: anExpression [
	"Allows you to send OR: directly to a query to build up a query dynamically without needing to mess with the criteria explicitly.  If anExpression is a block calling platform-specific functions, or aggregation functions such as #sqlCount or #isEmpty, you must set up the base (by sending #setUpBaseFromSession:) before calling this, but usually this will not be needed."

	whereClause := (anExpression asGlorpExpressionOn: base)
		OR: (whereClause asGlorpExpressionOn: base) asGeneralGlorpExpression.
]

{ #category : #preparing }
AbstractReadQuery >> adjustWhereClause [
	^self.
]

{ #category : #'specifying retrievals' }
AbstractReadQuery >> alsoFetch: anExpression [
	self tracing alsoFetch: (self expressionBlockFor: anExpression).
]

{ #category : #recursing }
AbstractReadQuery >> alsoFetchRecursively: aBlock retrieveAll: anArray defineThenFollow: aSymbol recursivelyRetrievingAll: anotherArray [
	"Make me the final query of a recursive read in which resultClass is not the base of recursion but something that alsoFetches that base.  (For now, this coding assumes that the most recent retrieve or alsoFetch call was the command to alsoFetch this base;  it just gets my last tracing as the recursionBase.)  Compute my initialQuery usng my resultClass and whereClause (but not my alsoFetch or retrieve).  The retrieve... array parameters will likely both contain a direct reference to that base' ancestral primaryKey(s), to allow syncronising returned rows with ancestral owning objects.  Likewise I will likely have a command ordering returned rows by that value and by their depth."

	| initialQuery recursionBase |
	initialQuery := self class read: self resultClass where: (self whereClause asGlorpExpressionOn: BaseExpression new).
	self copyAttributesTo: initialQuery.
	recursionBase := self tracing allTracings last.
	self alsoFetch: aBlock.
	^self asRecursiveQuery
		fetchBaseExpression: recursionBase;
		mappingDefiner: aSymbol;
		retrievalMappingExpressions: anArray;
		unionQuery:
			(CompoundQuery newUnionAll
				requiresDistinct: false;
				addQuery: (initialQuery retrieveAll: anArray);
				addQuery: ((initialQuery class read: self resultClass)
							retrieveAll: anotherArray;
							yourself));
		yourself
]

{ #category : #recursing }
AbstractReadQuery >> alsoFetchRecursively: aBlock retrieveAll: anArray thenFollow: aSymbol recursivelyRetrievingAll: anotherArray [
	"Make me the final query of a recursive read in which resultClass is not the base of recursion but something that alsoFetches that base.  (For now, this coding assumes that the most recent retrieve or alsoFetch call was the command to alsoFetch this base;  it just gets my last tracing as the recursionBase.)  Compute my initialQuery usng my resultClass and whereClause (but not my alsoFetch or retrieve).  The retrieve... array parameters will likely both contain a direct reference to that base' ancestral primaryKey(s), to allow syncronising returned rows with ancestral owning objects.  Likewise I will likely have a command ordering returned rows by that value and by their depth."

	| initialQuery recursionBase |
	initialQuery := self class read: self resultClass where: (self whereClause asGlorpExpressionOn: BaseExpression new).
	self copyAttributesTo: initialQuery.
	recursionBase := self tracing allTracings last.
	self alsoFetch: aBlock.
	^self asRecursiveQuery
		fetchBaseExpression: recursionBase;
		mappingToCloseOver: aSymbol;
		retrievalMappingExpressions: anArray;
		unionQuery:
			(CompoundQuery newUnionAll
				requiresDistinct: false;
				addQuery: (initialQuery retrieveAll: anArray);
				addQuery: ((initialQuery class read: self resultClass)
							retrieveAll: anotherArray;
							yourself));
		yourself
]

{ #category : #converting }
AbstractReadQuery >> asFullQuery [
	^self.
]

{ #category : #recursing }
AbstractReadQuery >> asRecursiveQuery [
	"Return a RecursiveQuery with my values.  Only call within a larger method that provides the additional values I will then need."

	| newQuery |
	newQuery := RecursiveQuery new.
	newQuery requiresDistinct: false.
	newQuery addQuery: self.
	^newQuery
]

{ #category : #accessing }
AbstractReadQuery >> baseExpression [
	^base.
]

{ #category : #accessing }
AbstractReadQuery >> baseExpression: aBaseExpression [
	base := aBaseExpression.
]

{ #category : #caching }
AbstractReadQuery >> checkCacheWithParameters: aDictionary ifPresent: aBlock [
	| primaryKey result filteredResult |
	readsOneObject ifFalse: [^nil].
	self shouldRefresh ifTrue: [^nil].
	"Check if we have retrieval expressions for something other than the base. If so, we're not actually reading this object, or at least not just this object"
	self tracing retrievalExpressions do: [:each | each base isNil ifFalse: [^self]].
	primaryKey := self primaryKeyFrom: aDictionary.
	"The query did not specify all primary key fields or had other fields as well or similar."
	primaryKey isNil ifTrue: [^nil].
	"The query is for a horizontally-filtered subclass and had no fields (is Query readOneOf: MySubClass ?)."
	primaryKey == DatabaseRow emptySlot ifTrue: [^nil].
	"The query has null (or a null-equivalent value) in a foreign-key field (see #shouldForeignKeyValueBeTreatedAsNull). So we've found the entry, and we know it's nil."
	primaryKey = #() ifTrue: [^aBlock value: nil].
	"If it is expired, make sure we do the read but still refresh."
  	(session hasExpired: resultClass key: primaryKey) ifTrue: [
		self shouldRefresh: true.
		^nil].
	result := session 
		cacheAt: primaryKey
		forClass: resultClass
		ifNone: [^nil].
	filteredResult := session filterDeletionFrom: result.
	^filteredResult isNil ifFalse:
		[(session system shouldResetExpiryTimeForObjectOfClass: filteredResult class readFrom: self)
			ifTrue: [self session markAsCurrentOfClass: filteredResult class key: primaryKey].
		aBlock value: filteredResult].
]

{ #category : #validation }
AbstractReadQuery >> checkValidity [
	resultClass glorpCanHaveDescriptorDirectly ifFalse: [self error: 'resultClass must be a class'].
	self descriptor isNil ifTrue: [self error: 'No descriptor for ', self resultClass name].
	(ordering notNil and: [self descriptor supportsOrdering not]) ifTrue: [self error: 'The descriptor for ', self resultClass name, ' does not support ordering in queries'].
]

{ #category : #copying }
AbstractReadQuery >> copyAttributesTo: newQuery [
	"We're creating a new query similar to ourselves, but not a direct copy. Copy over the relevant attributes."

	super copyAttributesTo: newQuery.
	newQuery limit: self limit.
	newQuery offset: self offset.
	newQuery proxyType: self proxyType.
	newQuery shouldRefresh: self shouldRefresh.
]

{ #category : #accessing }
AbstractReadQuery >> defaultTracing [
	| defaultTracing |
	defaultTracing := Tracing new.
	defaultTracing base: base.
	^defaultTracing
]

{ #category : #executing }
AbstractReadQuery >> deleteFromDatabaseWithParameters: anArray [
	| command |
	self descriptor classesRequiringIndependentQueries size >1 ifTrue: [self error: 'Delete with where clause not yet supported for classes that cross tables.'].
	self class ~~ SimpleQuery ifTrue: [self error: 'Non-simple queries not yet supported for deletes with where clauses'].
	command := self deleteSqlWith: anArray.
	"Should this duplicate the error handling in rowsFromDatabasewithParameters:?"
	session accessor executeCommand: command returnCursor: false.
	^command rowCount.
]

{ #category : #executing }
AbstractReadQuery >> deleteWithParameters: parameterArray in: aSession [ 
	| |
	session := aSession.
	self checkValidity.
	self setUpExpressions.
	self setupTracing.
	^self deleteFromDatabaseWithParameters: parameterArray.
]

{ #category : #accessing }
AbstractReadQuery >> descriptor [
	^session descriptorFor: resultClass.
]

{ #category : #'boolean operations' }
AbstractReadQuery >> except: aQuery [
	^self minus: aQuery.
]

{ #category : #executing }
AbstractReadQuery >> executeWithParameters: parameterArray in: aSession [ 
	| |
	session := aSession.
	self requiresFullQuery 
		ifTrue: [^self asFullQuery executeWithParameters: parameterArray in: aSession].
	self checkValidity.
	self setUpExpressions.
	self checkCacheWithParameters: parameterArray ifPresent: [:hit | session register: hit. ^hit].
	self setupTracing.
	^self 
		readFromDatabaseWithParameters: parameterArray.
]

{ #category : #accessing }
AbstractReadQuery >> expectedRows [
	"If we have set a limit, we cannot expect to get more rows back."

	^self limit isNil
		ifTrue: [super expectedRows]
		ifFalse: [self limit]
]

{ #category : #testing }
AbstractReadQuery >> hasLimit [
	^self limit notNil.
]

{ #category : #testing }
AbstractReadQuery >> hasOffset [
	^self offset notNil and: [self offset > 0].
]

{ #category : #testing }
AbstractReadQuery >> hasTracing [
	"Return true if we've given this query a tracing already"
	^false.
]

{ #category : #initialize }
AbstractReadQuery >> initResultClass: aClass whereClause: theCriteria singleObject: aBoolean [ 
	resultClass := aClass.
	self whereClause: ((theCriteria isNil or: [theCriteria = true or: [theCriteria = false]]) ifTrue: [EmptyExpression on: theCriteria] ifFalse: [theCriteria]).
	readsOneObject := aBoolean.
	aBoolean ifTrue: [self limit: 1].
]

{ #category : #initialize }
AbstractReadQuery >> initialize [
	
	super initialize.
	proxyType := nil.
	shouldRefresh := false.
]

{ #category : #'boolean operations' }
AbstractReadQuery >> intersect: aQuery [
	aQuery shortCircuitEmptyReturn ifTrue: [^aQuery].
	self shortCircuitEmptyReturn ifTrue: [^self].
	^CompoundQuery newIntersect addQuery: self; addQuery: aQuery.
]

{ #category : #accessing }
AbstractReadQuery >> limit [
	^limit.
]

{ #category : #accessing }
AbstractReadQuery >> limit: anInteger [
	limit := anInteger.
]

{ #category : #testing }
AbstractReadQuery >> limitMakesSense [
	^self hasLimit not or: [self limit > 0].
]

{ #category : #'boolean operations' }
AbstractReadQuery >> minus: aQuery [
	aQuery shortCircuitEmptyReturn ifTrue: [^self].
	self shortCircuitEmptyReturn ifTrue: [^aQuery].
	^CompoundQuery newMinus addQuery: self; addQuery: aQuery.
]

{ #category : #accessing }
AbstractReadQuery >> offset [
	^offset
]

{ #category : #accessing }
AbstractReadQuery >> offset: anObject [
	offset := anObject.
]

{ #category : #copying }
AbstractReadQuery >> postCopy [
	super postCopy.
	base := BaseExpression new.
	whereClause := whereClause asGlorpExpressionOn: base.
	session isNil ifFalse: [self setUpExpressions].
]

{ #category : #preparing }
AbstractReadQuery >> prepare [
	prepared ifTrue: [^self].
	self setupTracing.
	prepared := true.
]

{ #category : #caching }
AbstractReadQuery >> primaryKeyFrom: aDictionary [
	"Construct a primary key from the given parameters."

	self prepare.
	(aDictionary
		anySatisfy:
			[:each | self session system shouldForeignKeyValueBeTreatedAsNull: each])
		ifTrue: [^#()].
	^self whereClause primaryKeyFromDictionary: aDictionary.
]

{ #category : #private }
AbstractReadQuery >> privateAnd: anExpression [
	"AND these two together without checking for common bases, rebuilding, etc. Everything had better be right"
	whereClause := whereClause AND: anExpression.
]

{ #category : #accessing }
AbstractReadQuery >> proxyType [
	"Answer the type of proxies the receiver should build when instantiating objects:
		nil - Do not build proxies.
		TimedProxy - Build TimedProxies.
		Proxy - Build Proxies."

	^proxyType
]

{ #category : #accessing }
AbstractReadQuery >> proxyType: aClass [
	
	proxyType := aClass.
]

{ #category : #executing }
AbstractReadQuery >> readFromDatabaseWithParameters: anArray [
	| answerStream result |
	answerStream := self rowsFromDatabaseWithParameters: anArray.
	^readsOneObject
		ifTrue: [result := answerStream next. answerStream release. result]
		ifFalse: [self resultCollectionFor: answerStream].
]

{ #category : #testing }
AbstractReadQuery >> requiresFullQuery [
	^false.
]

{ #category : #accessing }
AbstractReadQuery >> resultClass [
	^resultClass
]

{ #category : #accessing }
AbstractReadQuery >> resultType [
	"Return the database type that we are expecting to return from this query. This only makes sense if we're returning a single field. If we return a collection of types, just return nil here. If we return a mapped object, the #type message will cause an exception."
	self tracing retrievalExpressions size = 1 ifFalse: [^nil].
	^self tracing retrievalExpressions asArray first type.
]

{ #category : #'specifying retrievals' }
AbstractReadQuery >> retrieve: anExpression [
	self tracing retrieve: (self expressionBlockFor: anExpression).
]

{ #category : #recursing }
AbstractReadQuery >> retrieve: aSymbolOrBlock defineThenFollow: aSymbol recursivelyRetrieving: anotherSymbolOrBlock intersect: aQuery [
	"Convenience protocol - just a singular version of retrieveAll:...recursivelyRetrievingAll:..."

	^self
		retrieveAll: (Array with: aSymbolOrBlock)
		defineThenFollow: aSymbol
		recursivelyRetrievingAll: (Array with: anotherSymbolOrBlock)
		intersect: aQuery
]

{ #category : #recursing }
AbstractReadQuery >> retrieve: aSymbolOrBlock thenFollow: aSymbol recursivelyRetrieving: anotherSymbolOrBlock intersect: aQuery [
	"Convenience protocol - just a singular version of retrieveAll:...recursivelyRetrievingAll:..."

	^aQuery asRecursiveQuery
		mappingToCloseOver: aSymbol;
		retrievalMappingExpressions: (Array with: aSymbolOrBlock);
		unionQuery: (CompoundQuery newUnionAll
					requiresDistinct: false;
					addQuery: (self retrieve: aSymbolOrBlock);
					addQuery: ((self class read: self resultClass)
								retrieve: anotherSymbolOrBlock;
								yourself));
		yourself
]

{ #category : #'specifying retrievals' }
AbstractReadQuery >> retrieveAll: someExpressions [
	someExpressions do: [:each | self retrieve: each].
]

{ #category : #recursing }
AbstractReadQuery >> retrieveAll: anArray defineThenFollow: aSymbol recursiveQuery: aRecursionQuery retrievingAll: anotherArray intersect: aQuery [
	"As for retrieveAll:thenFollow:recursivelyRetrievingAll:where:intersect. but allowing a more detailed management of the recursion step, e.g. using the recurse mapping in the whereClause."

	^aQuery asRecursiveQuery
		mappingDefiner: aSymbol;
		retrievalMappingExpressions: anArray;
		unionQuery:
			(CompoundQuery newUnionAll
				requiresDistinct: false;
				addQuery: (self retrieveAll: anArray);
				addQuery: (aRecursionQuery retrieveAll: anotherArray));
		yourself
]

{ #category : #recursing }
AbstractReadQuery >> retrieveAll: anArray defineThenFollow: aSymbol recursivelyRetrievingAll: anotherArray intersect: aQuery [
	"Define the mapping in the recursive system, otherwise as for #retrieveAll:thenFollow:..."

	^aQuery asRecursiveQuery
		mappingDefiner: aSymbol;
		retrievalMappingExpressions: anArray;
		unionQuery:
			(CompoundQuery newUnionAll
				requiresDistinct: false;
				addQuery: (self retrieveAll: anArray);
				addQuery: ((self class read: self resultClass)
							retrieveAll: anotherArray;
							yourself));
		yourself
]

{ #category : #recursing }
AbstractReadQuery >> retrieveAll: anArray thenFollow: aSymbol recursiveQuery: aRecursionQuery retrievingAll: anotherArray intersect: aQuery [
	"As for retrieveAll:thenFollow:recursivelyRetrievingAll:where:intersect. but allowing a more detailed management of the recursion step, e.g. using the recurse mapping in the whereClause."

	^aQuery asRecursiveQuery
		mappingToCloseOver: aSymbol;
		retrievalMappingExpressions: anArray;
		unionQuery:
			(CompoundQuery newUnionAll
				requiresDistinct: false;
				addQuery: (self retrieveAll: anArray);
				addQuery: (aRecursionQuery retrieveAll: anotherArray));
		yourself
]

{ #category : #recursing }
AbstractReadQuery >> retrieveAll: anArray thenFollow: aSymbol recursivelyRetrievingAll: anotherArray intersect: aQuery [
	"Make me the initial query of a recursive read.  The retrieveAll array is an array of mapping names, all direct.  The mappingToCloseOver symbol is a self mapping that uses (all or some of) these direct mappings: it is the mapping whose closure we seek.  The retrieve arrays hold symbols or blocks (usually the latter) selecting what the iterative step will retrieve from the recursion table and/or, via the recurse mapping, from the main table(s).  Since both retrievals populate the same table, the two arrays must correspond in size and in ability to populate the same fields."

	^aQuery asRecursiveQuery
		mappingToCloseOver: aSymbol;
		retrievalMappingExpressions: anArray;
		unionQuery:
			(CompoundQuery newUnionAll
				requiresDistinct: false;
				addQuery: (self retrieveAll: anArray);
				addQuery: ((self class read: self resultClass)
							retrieveAll: anotherArray;
							yourself));
		yourself
]

{ #category : #'specifying retrievals' }
AbstractReadQuery >> retrieveMax: anExpression [
	self tracing retrieve: ((self expressionBlockFor: anExpression) asGlorpExpression get: #max).
]

{ #category : #'specifying retrievals' }
AbstractReadQuery >> retrieveMin: anExpression [
	self tracing retrieve: ((self expressionBlockFor: anExpression) asGlorpExpression get: #min).
]

{ #category : #'specifying retrievals' }
AbstractReadQuery >> retrieveSum: anExpression [
	self tracing retrieve: ((self expressionBlockFor: anExpression) asGlorpExpression get: #sum).
]

{ #category : #accessing }
AbstractReadQuery >> returnProxies [
	^proxyType notNil
]

{ #category : #accessing }
AbstractReadQuery >> returnProxies: aBoolean [
	
	aBoolean ifTrue: [proxyType := Proxy] ifFalse: [proxyType := nil].
]

{ #category : #testing }
AbstractReadQuery >> returnTimedProxies [
	^proxyType == TimedProxy
]

{ #category : #accessing }
AbstractReadQuery >> returnTimedProxies: aBoolean [

	aBoolean ifTrue: [proxyType := TimedProxy] ifFalse: [proxyType := nil]
]

{ #category : #executing }
AbstractReadQuery >> rowsFromDatabaseWithParameters: anArray [
	self subclassResponsibility.
]

{ #category : #accessing }
AbstractReadQuery >> setUpBase [
	base := whereClause isGlorpExpression
		ifTrue: [whereClause queryLevelBaseExpression]
		ifFalse: [BaseExpression new].
]

{ #category : #initialize }
AbstractReadQuery >> setUpBaseFromSession: aSession [
	"The parameter session should at least have the identical descriptor system instance as the session later supplied in the #execute: call, and this system should have its platform set.  Obviously, it is prudent simply to use the same session instance whenever possible.
	The usual reason for calling this method will be to let the query be sent #retrieve: blocks and/or AND:/OR: blocks that contain aggregation functions (essential) and/or functions with platform-specific expansions (essential if the platform's expansion is not the default one)."

    self session: aSession.
    self setUpBase.
    base descriptor:
        (aSession system descriptorFor: self resultClass).
]

{ #category : #executing }
AbstractReadQuery >> setUpExpressions [
	(whereClause isGlorpExpression and: [whereClause queryLevelBaseExpression notNil])
		ifTrue:
			[base := whereClause queryLevelBaseExpression.
			base hasDescriptor
				ifFalse: [base descriptor: (session descriptorFor: resultClass)]]
		ifFalse:
			[base isNil ifTrue: [base := BaseExpression new].
			base descriptor: (session descriptorFor: resultClass).
			whereClause := whereClause asGlorpExpressionOn: base in: self].
	ordering isNil
		ifFalse:
			[ordering := ordering
				collect:
					[:each | (self expressionBlockFor: each) asGlorpExpressionOn: base in: self]].
	grouping isNil 
		ifFalse:
			[grouping := grouping
				collect:
					[:each | (self expressionBlockFor: each) asGlorpExpressionOn: base in: self]].		
	tracing isNil ifFalse: [tracing updateBase: base].
	base descriptor typeResolver setUpExpressionsForQuery: self.
]

{ #category : #tracing }
AbstractReadQuery >> setupTracing [
	self setUpExpressions.
	self tracing setup.
	self tracing additionalExpressions do:
		[:each |
		each hasDescriptor ifTrue:
			[each descriptor trace: self tracing context: each].
		each validate].
]

{ #category : #testing }
AbstractReadQuery >> shortCircuitEmptyReturn [
	"If we have a literal false for criteria, we never need to go to the database.
	We also don't need to go to database if limit doesnt make sense in terms of knowing beforehand that no results will be returned"

	(whereClause class == EmptyExpression and: [whereClause isFalse]) ifTrue: [^true].
	self limitMakesSense ifFalse: [^true].
	^false.
]

{ #category : #testing }
AbstractReadQuery >> shortCircuitEmptyReturn: parameters [
	"We  need not go to the database if we can deduce beforehand that no results will be returned.  This is so if we have a literal false for criteria, or if we have a row limit and it is zero or negative;  obviously these are only ever likely to apply to queries being constructed programmatically.
	We will also get no results if we are asking whether the value of a non-NULLable field is NULL.  To check this third case, we must prepare the query, which can cause us to prepare a query earlier than we would expect."

	(whereClause class == EmptyExpression and: [whereClause isFalse]) ifTrue: [^true].
	self limitMakesSense ifFalse: [^true].
	self prepare.
	^whereClause shortCircuitOnNullComparison: parameters
]

{ #category : #preparing }
AbstractReadQuery >> shouldExpressionBeJoin: anExpression [
	"Return true if the expression should be a join in our context (which means it refers only to tables we have in our from list) or if it should be ANDed into the where clause). Only relevant if we're using ANSI joins"
	^anExpression
		allSatisfy:
			[:eachNode | 
			| queryBase |
			queryBase := eachNode queryLevelBaseExpression.
			queryBase isNil or: [	queryBase = self baseExpression]].
]

{ #category : #accessing }
AbstractReadQuery >> shouldRefresh [
	^shouldRefresh
]

{ #category : #accessing }
AbstractReadQuery >> shouldRefresh: aBoolean [
	shouldRefresh := aBoolean
]

{ #category : #accessing }
AbstractReadQuery >> tracing [
	tracing isNil ifTrue: [tracing := self defaultTracing].
	^tracing.
]

{ #category : #accessing }
AbstractReadQuery >> tracing: aTracing [
	tracing := aTracing.
	tracing updateBase: base.
	tracing setup.
]

{ #category : #'boolean operations' }
AbstractReadQuery >> unionAll: aQuery [
	aQuery shortCircuitEmptyReturn ifTrue: [^self].
	self shortCircuitEmptyReturn ifTrue: [^aQuery].
	^CompoundQuery newUnionAll addQuery: self; addQuery: aQuery.
]

{ #category : #executing }
AbstractReadQuery >> validateWhereClause [
	resultClass glorpCanHaveDescriptorDirectly ifFalse: [self error: 'Invalid result class for query'].
	whereClause isJoin ifFalse: [
		whereClause do: [:each | each validate]].
	tracing isNil ifTrue: [^self].
	tracing allTracings do: [:eachTracing |
		eachTracing do: [:eachExpressionNode | eachExpressionNode validate]].
]

{ #category : #accessing }
AbstractReadQuery >> whereClause [
	^whereClause
]

{ #category : #accessing }
AbstractReadQuery >> whereClause: anExpression [
	whereClause := anExpression.
	self setUpBase.
]
