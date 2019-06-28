"
All my tests fail on SQLite and MySQL (they do not yet support recursion).

I test storing read data in common table expression and using it for recursive reads.  Use
	GlorpRecursionTest new writeCitiesNoCycles
or
	GlorpRecursionTest new writeCitiesWithCycles
to populate the database if you need to study the test code in situ.  Then do
	GlorpDemoTablePopulatorResource invalidateSetup.
and run one of my tests to remove it.
"
Class {
	#name : #GlorpRecursionTest,
	#superclass : #GlorpMappingDBTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpRecursionTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'support-cities' }
GlorpRecursionTest >> cities [
	"GlorpRecursionTest new cities"

	| cities |
	cities := Dictionary new.
	#( 'Boston' 'New York' 'Washington' 'Cinncinati' 'Chicago' 'St. Louis' 'Kansas City' 'Oklahoma City' 'Denver' 'Houston' 'Dallas' 'Phoenix' 'New Orleans'
	'Atlanta' 'Seattle' 'Portland' 'Miami'  'Baltimore' 'Nashville' 'Salt Lake City' 'Portland' 'Elko' 'Reno' 'San Francisco' 'Los Angeles' 'Dallas' 'Seattle' 'Atlanta' 'Miami')
	inject: 1 into: [:nextId :name| 
		cities at: name put:  ((GlorpCity new) name: name; id: nextId).
		nextId+1].
	^cities
]

{ #category : #'support-cities' }
GlorpRecursionTest >> citiesGraphWithCycles [
	"GlorpRecursionTest new citiesGraphWithCycles
	Add a backwards link for every forward link."

	| graphNodes|
	graphNodes := self citiesGraphWithNoCycles.
	graphNodes copy do: [:node| graphNodes add: ((node nextCity) addNextCity: (node city) distance: (node distance)) ].
	^graphNodes
]

{ #category : #'support-cities' }
GlorpRecursionTest >> citiesGraphWithNoCycles [
	"GlorpRecursionTest new citiesGraphWithNoCycles"
	
	| cities graphNodes|
	cities := self cities.
	graphNodes := OrderedCollection new.
	graphNodes add: ((cities at: 'Boston') addNextCity: (cities at: 'New York') distance: 240).
	graphNodes add: ((cities at: 'Boston') addNextCity: (cities at: 'Chicago') distance: 1000).
	graphNodes add: ((cities at: 'New York') addNextCity: (cities at: 'Chicago') distance: 800).
	graphNodes add: ((cities at: 'New York') addNextCity: (cities at: 'Washington') distance: 200).
	graphNodes add: ((cities at: 'Washington') addNextCity: (cities at: 'Atlanta') distance: 650).
	graphNodes add: ((cities at: 'Atlanta') addNextCity: (cities at: 'Miami') distance: 650).
	graphNodes add: ((cities at: 'Atlanta') addNextCity: (cities at: 'Dallas') distance: 750).
	graphNodes add: ((cities at: 'Chicago') addNextCity: (cities at: 'St. Louis') distance: 350).
	graphNodes add: ((cities at: 'St. Louis') addNextCity: (cities at: 'Kansas City') distance: 250).
	graphNodes add: ((cities at: 'Kansas City') addNextCity: (cities at: 'Oklahoma City') distance: 320).
	graphNodes add: ((cities at: 'Kansas City') addNextCity: (cities at: 'Denver') distance: 600).
	graphNodes add: ((cities at: 'Oklahoma City') addNextCity: (cities at: 'Denver') distance: 600).
	graphNodes add: ((cities at: 'Oklahoma City') addNextCity: (cities at: 'Dallas') distance: 200).
	graphNodes add: ((cities at: 'Denver') addNextCity: (cities at: 'Salt Lake City') distance: 1000).
	graphNodes add: ((cities at: 'Salt Lake City') addNextCity: (cities at: 'Elko') distance: 250).
	graphNodes add: ((cities at: 'Salt Lake City') addNextCity: (cities at: 'Portland') distance: 800).
	graphNodes add: ((cities at: 'Elko') addNextCity: (cities at: 'Reno') distance: 250).
	graphNodes add: ((cities at: 'Reno') addNextCity: (cities at: 'San Francisco') distance: 220).
	graphNodes add: ((cities at: 'San Francisco') addNextCity: (cities at: 'Los Angeles') distance: 390).
	graphNodes add: ((cities at: 'San Francisco') addNextCity: (cities at: 'Portland') distance: 650).
	graphNodes add: ((cities at: 'Portland') addNextCity: (cities at: 'Seattle') distance: 180).
	^graphNodes
]

{ #category : #'support-nodes' }
GlorpRecursionTest >> recursiveQueryFromRoot [
	"Hardcodedly-construct the recursive query."

	| recursiveQuery initialQuery intersectQuery |
	initialQuery := Query read: GlorpRootNode where: [:each | each id = 1].
	intersectQuery := Query read: GlorpRootNode where: [:each | each id = 1].	"this where probably needless"
	intersectQuery alsoFetch: [:each | each root].
	intersectQuery alsoFetch: [:each | each root childrenRecursively].
	recursiveQuery := initialQuery
		retrieveAll:
			(Array
				with: [:each | each root id]
				with: [:each | each root children id])
		thenFollow: #children
		recursivelyRetrievingAll: (Array
				with: [:each | each rootid]
				with: [:each | each recurse children id])
		intersect: intersectQuery.
	recursiveQuery fetchBaseExpression: [:each | each root].
	intersectQuery orderBy: [:each | each root childrenRecursively id].
	^recursiveQuery
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadAncestors [
	"In a single round trip to the database, get all 3 ancestors of node 9 by recursively reading them.  In this test we retrieve the id as well as the parent id, for no reason except to test we can have additional fields in the recursion table."

	| allNodes recursiveQuery |
	session platform canRecurse ifFalse: [^self].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query readOneOf: GlorpTreeNode where: [:each | each id = 9])
				retrieveAll: (Array with: [:each | each parent id])
				thenFollow: [:each | each parent]
				recursivelyRetrievingAll: (Array with: [:each | each recurse parent id])
				intersect: (Query read: GlorpTreeNode).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 3.
		self assert: (allNodes collect: [:each | each id]) asSet = (Set with: 4 with: 2 with: 1)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadAncestorsOrdered [
	"In a single round trip to the database, get all 3 ancestors of node 9 by recursively reading them.  In this test we retrieve the id as well as the parent id, for no reason except to test we can have additional fields in the recursion table."

	| allNodes recursiveQuery |
	session platform canRecurse ifFalse: [^self].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query readOneOf: GlorpTreeNode where: [:each | each id = 9])
				retrieve: [:each | each parent id]
				thenFollow: #parent
				recursivelyRetrieving: [:each | each recurse parent id]
				intersect: ((Query read: GlorpTreeNode) orderBy: [:each | each recursed parentid descending]; yourself).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 3.
		self assert: (allNodes collect: [:each | each id]) asArray = #(4 2 1)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadAncestorsOrderedReverse [
	"The main purpose of this test is just to demonstrate the use of #start:retrieveAll:recursivelyRetrievingAll: in a cascade creating a recursive query."

	| allNodes recursiveQuery mainQuery |
	session platform canRecurse ifFalse: [^self].
	self inTransactionDo: 
		[self writeNodeWithDescendants.
		session reset.
		mainQuery := Query read: GlorpTreeNode.
		mainQuery orderBy: [:each | each recursed parentid].
		recursiveQuery := mainQuery asRecursiveQuery
			mappingToCloseOver: #parent;
			start: (Query readOneOf: GlorpTreeNode where: [:each | each id = 9])
			retrieveAll: (Array with: [:each | each parent id])
			recursivelyRetrievingAll: (Array with: [:each | each recurse parent id]);
			yourself.
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 3.
		self assert: (allNodes collect: [:each | each id]) asArray = #(1 2 4)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadChildUnionAncestorsOrdered [
	"In a single round trip to the database, get all 3 ancestors of node 9 by recursively reading them, then union them to the child.  This test exposes issues in the initialization of recursive queries that need to be addressed so then can interact with others."

	| allNodes recursiveQuery selfWithAllQuery |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query readOneOf: GlorpTreeNode where: [:each | each id = 9])
				retrieve: [:each | each parent id]
				thenFollow: #parent
				recursivelyRetrieving: [:each | each recurse parent id]
				intersect: (Query read: GlorpTreeNode).
		selfWithAllQuery := recursiveQuery unionAll:
			(Query read: GlorpTreeNode where: [:each | each id = 9]).
		selfWithAllQuery orderBy: [:each | each id descending].
		allNodes := session execute: selfWithAllQuery.
		self assert: allNodes size = 4.
		self assert: (allNodes collect: [:each | each id]) asArray = #(9 4 2 1)].
]

{ #category : #'test-aliasing' }
GlorpRecursionTest >> testReadChildUnionDecrementIdBlockDefined [
	"Within the recursion, define a temporary mapping from a node to a node whose id is one less.  Use it to recurse back to node1 from node9.  This exercise (although pointless in itself) tests both relationally-defined join sources and, more importantly, temporary relationships defined within a recursion."

	| allNodes recursiveQuery selfUnionRecurseQuery |
	session platform canRecurse ifFalse: [^self].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery := (Query read: GlorpTreeNode where: [:each | each id = 9])
			retrieve: [:each | each decrementIdNode id]
			defineThenFollow: [:anotherDescriptor |
				anotherDescriptor oneToOneMapping
					attributeName: #decrementIdNode;
					beForPseudoVariable;
					referenceClass: GlorpTreeNode;
					join: (Join
							from: ([:each | (((each getTable: 'TREE_NODE') getField: 'ID') - 1) alias: 'DefaultAlias']
													asGlorpExpressionForDescriptor: anotherDescriptor)
							to: (anotherDescriptor table fieldNamed: 'ID'))]
			recursivelyRetrieving: [:each | each recurse decrementIdNode id]
			intersect: (Query read: GlorpTreeNode).
		selfUnionRecurseQuery := recursiveQuery unionAll:
			(Query read: GlorpTreeNode where: [:each | each id = 9]).
		selfUnionRecurseQuery orderBy: [:each | each id descending].
		allNodes := session execute: selfUnionRecurseQuery.
		self assert: allNodes size = 9.
		self assert: (allNodes collect: [:each | each id]) asArray = #(9 8 7 6 5 4 3 2 1)].
]

{ #category : #'tests-cities' }
GlorpRecursionTest >> testReadCitiesGraphAvoidCycles [
	"This test retrieves the full path, the depth, and whether the path contains a cycle, from the recursion table.  It uses a WHERE clause to fetch only the paths leading to the target city.  It uses an ORDER BY clause to show the shortest paths first.  It uses the #prepend: function to switch the order of elements in the query block, since the block parser (MessageArchiver) requires a DatabaseField-related object to begin its parsing process;  without the #prepend:, the parser would see a string and switch to the Smalltalk parser."

	| allNodes recursiveQuery startingCity endingCity recursionQuery startingDepth maxDepth varchar3 varcharM |
	session platform canRecurse ifFalse: [^true].
	"Retrieving boolean 'isCycle' to a SELECT field requires additional handling on some platforms.
	(See removed method #testReadCitiesGraphWithProtectionRetrieve for retrieve-part handling.)"
	session platform isPostgreSQLPlatform ifFalse: [^self].
	"self skipUnless: session platform isPostgreSQLPlatform
		description:  'GLORP cannot (yet) retrieve boolean to SELECT field on ', session platform class kind."
	maxDepth := 15.
	varchar3 := session platform varchar: 3.
	varcharM := session platform varchar: maxDepth * 5.	"Holds maximum expected path, like (1)(2)(3)(4), assuming 3-digit city numbers."
	self inTransactionDo: 
		[self writeCitiesWithCycles.
		session reset.
		startingCity := session readOneOf: GlorpCity where: [:each | each name = 'Boston'].
		endingCity := session readOneOf: GlorpCity where: [:each | each name = 'Los Angeles'].
		startingDepth := 0 asGlorpExpression alias: #depth.
		recursionQuery := Query read: GlorpCity where:
			[:each | each depth < maxDepth & [(each recurse id = endingCity id) not] & [each isCycle = false]].
		recursiveQuery := (Query read: GlorpCity where: [:each | each id = startingCity id])
			retrieveAll: (OrderedCollection new
						add: [:each | each id];
						add: [:each | each nextCities key];
						add: [:each | each nextCities value];
						add: [:each | startingDepth];
						add: [:each | (each getConstant: '(' , startingCity id printString , ')' alias: #path) cast: varcharM];
						add: [:each | each getConstant: false alias: #isCycle];
						asArray)
			thenFollow: #nextCities
			recursiveQuery: recursionQuery
			retrievingAll: (OrderedCollection new		"each=>recursion table,  recurse=>GlorpCity table."
						add: [:each | each recurse id];
						add: [:each | each recurse nextCities key];
						add: [:each | each nextCitiesvalue + each recurse nextCities value];
						add: [:each | each depth + 1 cast: Integer];
						add: [:each | each path , '(' , (each recurse id cast: varchar3) , ')' cast: varcharM];
						add: [:each | each path like: (((each recurse id cast: varchar3) prepend: '%(') , ')%' cast: varcharM)];
						asArray)
			intersect: ((Query read: GlorpCity) 	"each is this query, recursed=>recursion table."
						retrieveAll: (OrderedCollection new
							add: [:each | each recursed id];
							add: [:each | each recursed nextCitieskey];
							add: [:each | each recursed nextCitiesvalue];
							add: [:each | each recursed depth];
							add: [:each | each recursed path];
							add: [:each | each recursed isCycle];
							asArray);
						orderBy: [:each | each recursed nextCitiesvalue];
						whereClause: [:each | each recursed nextCitieskey = endingCity id]).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes notEmpty.
		allNodes do: [:node | self assert: (node at: 2) = endingCity id]].
]

{ #category : #'tests-cities' }
GlorpRecursionTest >> testReadCitiesGraphKeysAndValuesSimple [
	"Follow the graph, summing the distance traveled, incrementing depth,  appending to path and identifying cycles.  Records cycles, and stops at destination city, or depth>11, or when in a cycle."

	| allNodes recursiveQuery startingCity recursionQuery endingCity |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeCitiesNoCycles.
		session reset.
		startingCity := session readOneOf: GlorpCity where: [:each| each name = 'Boston'].
		endingCity := session readOneOf: GlorpCity where: [:each| each name = 'Los Angeles'].
		recursionQuery := Query read: GlorpCity where:
			[:each |(each recurse id = endingCity id) not].
		recursiveQuery := 
			(Query read: GlorpCity where: [:each | each id = startingCity id])
				retrieveAll:
					(OrderedCollection new
						add: [:each| each id];
						add: [:each| each nextCities key];
						add: [:each| each nextCities value];
						asArray)
				thenFollow: #nextCities
				recursiveQuery: recursionQuery
				retrievingAll: 		"each=>recursion table,  recurse=>GlorpCity table."
					(OrderedCollection new
						add: [:each | each recurse id];
						add: [:each | each recurse nextCities key];
						add: [:each | each nextCitiesvalue + each recurse nextCities value];
						asArray)
				intersect: ((Query read: GlorpCity) retrieveAll:	"recursed=>recursion table."
					(OrderedCollection new
						add: [:each| each recursed id];
						add: [:each| each recursed nextCitieskey];
						add: [:each| each recursed nextCitiesvalue];
						asArray)).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 55].
]

{ #category : #'tests-cities' }
GlorpRecursionTest >> testReadCitiesGraphKeysOnlySimple [
	"Follow the graph, summing the distance traveled, incrementing depth, appending to path and identifying cycles.  Records cycles, and stops at destination city, or depth>11, or when in a cycle."

	| allNodes recursiveQuery startingCity recursionQuery endingCity |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeCitiesNoCycles.
		session reset.
		startingCity := session readOneOf: GlorpCity where: [:each| each name = 'Boston'].
		endingCity := session readOneOf: GlorpCity where: [:each| each name = 'Los Angeles'].
		recursionQuery := Query read: GlorpCity where:
			[:each |(each recurse id = endingCity id) not].
			"[:each |(each recurse nextCities key = 11) not]."
		recursiveQuery := 
			(Query read: GlorpCity where: [:each | each id = startingCity id])
				retrieveAll:
					(OrderedCollection new
						add: [:each| each id];
						add: [:each| each nextCities key];
						asArray)
				thenFollow: #nextCities
				recursiveQuery: recursionQuery
				retrievingAll: 			"each=>recursion table,  recurse=>GlorpCity table."
					(OrderedCollection new
						add: [:each | each recurse id];
						add: [:each | each recurse nextCities key];
						asArray)
				intersect: ((Query read: GlorpCity) retrieveAll:	"recursed=>recursion table."
					(OrderedCollection new
						add: [:each| each recursed id];
						add: [:each| each recursed nextCitieskey];
						asArray)).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 55].
]

{ #category : #'test-aliasing' }
GlorpRecursionTest >> testReadCitiesViaAliasedPrefix [
	"This test retrieves the full path, the depth, and whether the path contains a cycle, from the recursion table.  It uses a WHERE clause to fetch only the paths leading to the target city.  It uses an ORDER BY clause to show the shortest paths first.  It uses the #prepend: function to switch the order of elements in the query block, since the block parser (MessageArchiver) requires a DatabaseField-related object to begin its parsing process;  without the #prepend:, the parser would see a string and switch to the Smalltalk parser."

	| allNodes recursiveQuery startingCity recursionQuery startingDepth maxDepth |
	session platform canRecurse ifFalse: [^true].
	maxDepth := 5.
	self inTransactionDo: 
		[self writeCitiesWithCycles.
		session reset.
		startingCity := session readOneOf: GlorpCity where: [:each | each name = 'Boston'].
		startingDepth := 0 asGlorpExpression alias: #depth.
		recursionQuery := Query read: GlorpCity where: [:each | each depth < maxDepth].
		recursiveQuery := (Query read: GlorpCity where: [:each | each id = startingCity id])
			retrieveAll: (Array
						with: [:each | each wordLengthCityId id]
						with: [:each | startingDepth])
			defineThenFollow: [:anotherDescriptor |
				anotherDescriptor oneToOneMapping
					attributeName: #wordLengthCityId;
					beForPseudoVariable;
					referenceClass: GlorpCity;
					join: (Join
							from: ([:each | (((each getTable: 'CITIES') getField: 'name') length) alias: 'nameLength']
												asGlorpExpressionForDescriptor: anotherDescriptor)
							to: (anotherDescriptor table fieldNamed: 'id'))]
			recursiveQuery: recursionQuery
			retrievingAll: (Array
						with: [:each | each recurse wordLengthCityId id]
						with: [:each | each depth + 1 cast: Integer])
			intersect: ((Query read: GlorpCity)
						orderBy: [:each | each recursed depth];
						whereClause: [:each | each recursed wordLengthCityIdid < 26]).
		allNodes := session execute: recursiveQuery.
		(2 to: allNodes size)
			inject: allNodes first
			into: [:prev :index || next | next := allNodes at: index.
				self assert: prev name size = next id.
				next].
		self assert: allNodes size = 6].
]

{ #category : #'test-aliasing' }
GlorpRecursionTest >> testReadDecrementIdBlockDefined [
	"Within the recursion, define a temporary mapping from a node to a node whose id is one less.  Use it to recurse back to node1 from node9.  This exercise (although pointless in itself) tests both relationally-defined join sources and, more importantly, temporary relationships defined within a recursion."

	| allNodes recursiveQuery |
	session platform canRecurse ifFalse: [^self].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery := (Query readOneOf: GlorpTreeNode where: [:each | each id = 9])
			retrieve: [:each | each decrementIdNode id]
			defineThenFollow: [:anotherDescriptor | 
				anotherDescriptor oneToOneMapping
					attributeName: #decrementIdNode;
					beForPseudoVariable;
					referenceClass: GlorpTreeNode;
					join: (Join
							from: ([:each | (((each getTable: 'TREE_NODE') getField: 'ID') - 1) alias: 'DefaultAlias']
												asGlorpExpressionForDescriptor: anotherDescriptor)
							to: (anotherDescriptor table fieldNamed: 'ID'))]
			recursivelyRetrieving: [:each | each recurse decrementIdNode id]
			intersect: (Query read: GlorpTreeNode).
		recursiveQuery orderBy: [:each | each id descending].
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 8.
		self assert: (allNodes collect: [:each | each id]) asArray = #(8 7 6 5 4 3 2 1)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadDescendants [
	"In a single round trip to the database, get all 8 descendants of node 1 by recursively reading them.  Do not make any explicit use of the 'recursed' mapping in whereClause, ordering or grouping, thus testing that the intersecting Query will be joined to the recursion anyway."

	| allNodes recursiveQuery |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query read: GlorpTreeNode where: [:each | each id = 1])
				retrieveAll:
					(Array with: [:each | each children id])
				thenFollow: [:each | each children]
				recursivelyRetrievingAll:
					(Array with: [:each | each recurse children id])
				intersect: (Query read: GlorpTreeNode).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 8.
		self assert: (allNodes collect: [:each | each id]) sort asArray = #(2 3 4 5 6 7 8 9)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadDescendantsDepthOrdered [
	"Return depth as well as order by it, to show we can return constnats whose values are not the same in all rows.  In a single round trip to the database, get all 8 descendants of node 1 by recursively reading them.  Use the 'recursed' mapping to order the final query."

	| allNodes recursiveQuery startingDepth |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		startingDepth := 1 asGlorpExpression alias: #depth.
		recursiveQuery :=
			(Query read: GlorpTreeNode where: [:each | each id = 1])
				retrieveAll: (Array
							with: [:each | each children id]
							with: [:each | startingDepth])
				thenFollow: #children
				recursivelyRetrievingAll: (Array
									with: [:each | each recurse children id]
									with: [:each | each depth + 1 cast: Integer])	"SQLServer seems to need the cast - OR IS IT DB2?"
				intersect: ((Query read: GlorpTreeNode)
							orderBy: [:each | each recursed depth];
							orderBy: [:each | each id];
							retrieveAll: (Array with: [:each | each id] with: [:each | each recursed depth])
							yourself).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 8.
		self assert: allNodes = #(#(2 1) #(3 1) #(4 2) #(5 2) #(6 2) #(7 2) #(8 2) #(9 3))].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadDescendantsIdOrdered [
	"In a single round trip to the database, get all 8 descendants of node 1 by recursively reading them.  Use the 'recursed' mapping to order the final query."

	| allNodes recursiveQuery |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query read: GlorpTreeNode where: [:each | each id = 1])
				retrieve: [:each | each children id]
				thenFollow: #children
				recursivelyRetrieving: [:each | each recurse children id]
				intersect: ((Query read: GlorpTreeNode) orderBy: [:each | each recursed childrenid]; yourself).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 8.
		self assert: (allNodes collect: [:each | each id]) asArray = #(2 3 4 5 6 7 8 9)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadParentUnionDescendantsWithRootId [
	"In a single round trip to the database, get all 8 descendants of node 1 by recursively reading them.  Have node 1's id in each row too.  Do not make any explicit use of the 'recursed' mapping in whereClause, ordering or grouping, thus testing that the intersecting Query will be joined to the recursion anyway."

	| allNodes recursiveQuery selfWithAllQuery |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query read: GlorpTreeNode where: [:each | each id = 1])
				retrieveAll:
					(Array
						with: [:each | each id]
						with: [:each | each children id])
				thenFollow: #children
				recursivelyRetrievingAll:
					(Array
						with: [:each | each id]
						with: [:each | each recurse children id])
				intersect: (Query read: GlorpTreeNode where: [:each | each recursed id = 1]).
		selfWithAllQuery := recursiveQuery unionAll:
			(Query read: GlorpTreeNode where: [:each | each id = 1]).
		allNodes := session execute: selfWithAllQuery.
		self assert: allNodes size = 9.
		self assert: (allNodes collect: [:each | each id]) sort asArray = #(1 2 3 4 5 6 7 8 9)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadParentUnionDescendentsOrdered [
	"In a single round trip to the database, get all 8 descendants of node 1 by recursively reading them.  Use the 'recursed' mapping to order the final query."

	| allNodes recursiveQuery selfWithAllQuery |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query read: GlorpTreeNode where: [:each | each id = 1])
				retrieveAll: (Array with: [:each | each children id])
				thenFollow: #children
				recursivelyRetrievingAll:
					(Array with: [:each | each recurse children id])
				intersect: (Query read: GlorpTreeNode).
		selfWithAllQuery := recursiveQuery unionAll:
			(Query read: GlorpTreeNode where: [:each | each id = 1]).
		selfWithAllQuery orderBy: [:each | each id].
		allNodes := session execute: selfWithAllQuery.
		self assert: allNodes size = 9.
		self assert: (allNodes collect: [:each | each id]) asArray = #(1 2 3 4 5 6 7 8 9)].
]

{ #category : #'tests-nodes-unrecursive' }
GlorpRecursionTest >> testReadRoot [
	"Get the root and verify it has a proxy to the root TreeNode whose iterated children comprise the whole tree."

	| allNodes outerQuery rootNode index |
	session platform canRecurse ifFalse: [^self].
	self inTransactionDo:
		[self writeRootForNode: self writeNodeWithDescendants.
		session reset.
		"recursiveQuery :=
			(Query read: GlorpTreeNode where: [:each | each id = 1])
				retrieveAll: (Array with: [:each | each children id])
				thenFollow: #children
				recursivelyRetrievingAll:
					(Array with: [:each | each recurse children id])
				intersect: (Query read: GlorpTreeNode).
		selfWithAllQuery := recursiveQuery unionAll:
			(Query readOneOf: GlorpTreeNode where: [:each | each id = 1]).
		selfWithAllQuery orderBy: [:each | each id]."
		outerQuery := Query readOneOf: GlorpRootNode where: [:each | each id = 1].
		rootNode := session execute: outerQuery.
		self assert: rootNode root class == Proxy.
		self deny: rootNode root isInstantiated.
		allNodes := OrderedCollection with: rootNode root yourSelf.
		index := 1.
		[index  > allNodes size] whileFalse:
			[allNodes addAll: (allNodes at: index) children.
			index := index + 1].
		self assert: allNodes size = 9.
		self assert: (allNodes collect: [:each | each id]) asArray sort = #(1 2 3 4 5 6 7 8 9)].
]

{ #category : #'tests-nodes-unrecursive' }
GlorpRecursionTest >> testReadRootAlsoFetchTree [
	"Read the root node, alsoFetch its root.  Verify it has no proxy to the root TreeNode but that that node's children have not been read."

	| outerQuery rootNode |
	session platform canRecurse ifFalse: [^self].
	"By default d #children proxies; until this test is developed further to replace the proxy checks at the end with something better, ensure that it does in case the test run configuration might have altered it."
	((session system descriptorFor: GlorpTreeNode) mappingForAttributeNamed: #children) shouldProxy: true.
	self inTransactionDo:
		[self writeRootForNode: self writeNodeWithDescendants.
		session reset.
		outerQuery := Query readOneOf: GlorpRootNode where: [:each | each id = 1].
		outerQuery := outerQuery alsoFetch: #root.
		rootNode := session execute: outerQuery].
		self deny: rootNode root class == Proxy.
		self assert: rootNode root children class == Proxy.
		self deny: rootNode root children isInstantiated.
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadRootAlsoFetchTreeRecursively [
	"Use this test to slim the API for also-fetching recursively.  Much of what we specify below could be calculated from fewer parameters, or moved to utility methods. "

	| allNodes rootNode recursiveQuery intersectQuery |
	session platform canRecurse ifFalse: [^self].
	self inTransactionDo:
		[self writeRootForNode: self writeNodeWithDescendants.
		session reset.
		self assert: (session cacheForClass: GlorpTreeNode) numberOfElements = 0.

		intersectQuery := Query read: GlorpRootNode where: [:each | each id = 1].
		recursiveQuery := intersectQuery
			alsoFetch: [:each | each root];
			orderBy: [:each | each root id];
			orderBy: [:each | each root childrenRecursively id];
			alsoFetchRecursively: [:each | each root childrenRecursively]	
			retrieveAll: (Array
				with: [:each | each root id]
				with: [:each | each root children id])
			thenFollow: [:each | each children]
			recursivelyRetrievingAll: (Array
				with: [:each | each rootid]
				with: [:each | each recurse children id]).

		rootNode := (session execute: recursiveQuery) first.
		self deny: rootNode root class == Proxy.
		allNodes := OrderedCollection new.
		(session cacheForClass: GlorpTreeNode) do:
			[:each | allNodes add: each].
		self assert: allNodes size = 9.
		self assert: (allNodes collect: [:each | each id]) asArray sort = #(1 2 3 4 5 6 7 8 9)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadRootAlsoFetchTreeRecursivelyDepthwise [
	"Use this test to slim the API for also-fetching recursively.  Much of what we specify below could be calculated from fewer parameters, or moved to utility methods. "

	| allNodes rootNode recursiveQuery intersectQuery startingDepth |
	session platform canRecurse ifFalse: [^self].
	self inTransactionDo:
		[self writeRootForNode: self writeNodeWithDescendants.
		session reset.
		self assert: (session cacheForClass: GlorpTreeNode) numberOfElements = 0.

		startingDepth := 0 asGlorpExpression alias: #depth.
		intersectQuery := Query read: GlorpRootNode where: [:each | each id = 1].
		recursiveQuery := intersectQuery
			alsoFetch: [:each | each root childrenRecursively parent];
			alsoFetch: [:each | each root];
			orderBy: [:each | each root id];
			orderBy: [:each | each root childrenRecursively recursed depth];
			alsoFetchRecursively: [:each | each root childrenRecursively]
			retrieveAll: (Array
				with: [:each | each root id]
				with: [:each | each root children id]
				with: [:each | startingDepth])
			thenFollow: #children
			recursivelyRetrievingAll: (Array
				with: [:each | each rootid]
				with: [:each | each recurse children id]
				with: [:each | each depth + 1 cast: Integer]).
		rootNode := (session execute: recursiveQuery) first.
		self deny: rootNode root class == Proxy.
		allNodes := OrderedCollection new.
		(session cacheForClass: GlorpTreeNode) do:
			[:each | allNodes add: each].
		self assert: allNodes size = 9.
		self assert: (allNodes collect: [:each | each id]) asArray sort = #(1 2 3 4 5 6 7 8 9)].
		allNodes do: [:each | each id = 1 ifFalse: [self deny: each parent class == Proxy]].
		allNodes do: [:each | self deny: each children class == Proxy].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadRootAlsoFetchTreeUsingRecursiveQuery [
	"Read the root node and alsoFetch its tree recursively.  Verify all 9 nodes are in the session cache.  If the relation did not use a linkTable, the whole tree would be explicitly constructed from the root;  as it is, we must fetch the parent explicitly to do this or exploit or ordering better: TBD."

	| allNodes rootNode selfWithAllQuery |
	session platform canRecurse ifFalse: [^self].
	"By default #parent and #children both proxy; until this test is developed further to replace the proxy checks at the end with something better, ensure that they do in case the test run configuration might have altered it."
	((session system descriptorFor: GlorpTreeNode) mappingForAttributeNamed: #parent) shouldProxy: true.
	((session system descriptorFor: GlorpTreeNode) mappingForAttributeNamed: #children) shouldProxy: true.
	self inTransactionDo:
		[self writeRootForNode: self writeNodeWithDescendants.
		session reset.
		self assert: (session cacheForClass: GlorpTreeNode) numberOfElements = 0.
		selfWithAllQuery := self recursiveQueryFromRoot.
		rootNode := (session execute: selfWithAllQuery) first.
		self deny: rootNode root class == Proxy.
		allNodes := OrderedCollection new.
		(session cacheForClass: GlorpTreeNode) do:
			[:each | allNodes add: each].
		self assert: allNodes size = 9.
		self assert: (allNodes collect: [:each | each id]) asArray sort = #(1 2 3 4 5 6 7 8 9)].
		allNodes do: [:each | self assert: each parent class == Proxy].
		allNodes do: [:each | self assert: each children class == Proxy].
]

{ #category : #'tests-cities' }
GlorpRecursionTest >> testReadWriteCitiesNoCycles [
	| cities |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeCitiesNoCycles.
		session reset.
		cities := session read: GlorpCity.
		self assert: cities size > 10.
		cities do:
			[:city || links |
			links := city nextCities yourSelf.
			self deny: links isNil.
			self assert: (links notEmpty or: [#(6 25 26 27 29) includes: city id])]].
]

{ #category : #'tests-cities' }
GlorpRecursionTest >> testReadWriteCitiesWithCycles [
	| cities |
	session platform canRecurse ifFalse: [^true].
	self inTransactionDo:
		[self writeCitiesWithCycles.
		session reset.
		cities := session read: GlorpCity.
		self assert: cities size > 10.
		cities do:
			[:city || links |
			links := city nextCities yourSelf.
			self deny: links isNil.
			self deny: links isEmpty]].
]

{ #category : #'support-cities' }
GlorpRecursionTest >> writeCitiesNoCycles [

	| graphNodes  |
	graphNodes := self citiesGraphWithNoCycles.
	session inUnitOfWorkDo: 
			[graphNodes do: [:node | session register: node]]
]

{ #category : #'support-cities' }
GlorpRecursionTest >> writeCitiesWithCycles [
	| graphNodes  |
	graphNodes := self citiesGraphWithCycles.
	session inUnitOfWorkDo: 
			[graphNodes do: [:node | session register: node]]
]

{ #category : #'support-nodes' }
GlorpRecursionTest >> writeNodeWithChildren [
	| node1 node2 node2a |
	node1 := GlorpTreeNode new id: 1.
	node2 := GlorpTreeNode new id: 2.
	node2a := GlorpTreeNode new id: 3.
	node1 addChild: node2.
	node1 addChild: node2a.
	session inUnitOfWorkDo: [session register: node1].
]

{ #category : #'support-nodes' }
GlorpRecursionTest >> writeNodeWithDescendants [
	| node1 node2a node2b node3aa node3ab node3ac node3ba node3bb node4aaa |
	node4aaa:= GlorpTreeNode new id: 9.
	node3bb := GlorpTreeNode new id: 8.
	node3ba := GlorpTreeNode new id: 7.
	node3ac := GlorpTreeNode new id: 6.
	node3ab := GlorpTreeNode new id: 5.
	(node3aa := GlorpTreeNode new id: 4)
		addChild: node4aaa.
	(node2b := GlorpTreeNode new id: 3)
		addChild: node3ba; addChild: node3bb.
	(node2a := GlorpTreeNode new id: 2)
		addChild: node3aa; addChild: node3ab; addChild: node3ac.
	(node1 := GlorpTreeNode new id: 1)
		addChild: node2a; addChild: node2b.
	session inUnitOfWorkDo: [session register: node1].
	^node1
]

{ #category : #'support-nodes' }
GlorpRecursionTest >> writeRootForNode: aGlorpTreeNode [
	| rootNode |
	rootNode := GlorpRootNode new
		id: aGlorpTreeNode id;	"just a random way of getting an id"
		root: aGlorpTreeNode;
		yourself.
	session inUnitOfWorkDo: [session register: rootNode].
	^rootNode
]
