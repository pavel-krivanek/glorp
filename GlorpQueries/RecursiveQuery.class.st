"
I implement a recursive SQL query using a common table expression.  I use the state and behaviour I inherit from my superclass to define the final query that will actually return rows to the user, holding my anchor and recursive queries inside a compound query.

Instance Variables:
 	fetchBaseExpression	<BlockClosure | GlorpExpression | nil>	if the recursive relation self-connects an alsoFetched class, not the primaryQuery's resultClass, give the alsoFetch expression
	mappingDefiner	<BlockClosure | nil>	if the self-relationship to be recursed over is not already in the system, define it in the cloned descriptor (the block parameter)
	mappingToCloseOver	<RelationshipMapping>	the self-relationship that we will follow recursively
	retrievalMappingExpressions	<Collection of: Symbol | MappingExpression>	mapping expressions connecting the bases to the fields (these are cloned to the recursion table)
	unionQuery	<CompoundQuery>	contains the anchor and recursive queries that between them populate the recursion table (the common table expession)

 Recursive queries contain the following elements (this example is in PostgreSQL form):

	""First we define the common table expression.""
	WITH RECURSIVE ancestor(primaryKey, trace, timeStamp) AS
	(	""An anchor query populates the first row(s) of the recursion.
		(SELECT primarykey, trace, timeStamp
			FROM tw_bundle
			WHERE primarykey = 529)	""id of some bundle whose ancestors we will read""
	UNION ALL	""unites the anchor query to the recursive query""
		(SELECT a2.primaryKey, a1.trace, a1.timeStamp
			FROM tw_bundle a1, ancestor a2
			WHERE a1.primarykey = a2.trace)
	)	""Finally, we select the rows to return from the common table and others""
	SELECT t1.* from tw_bundle t1, ancestor t2
	WHERE t1.trace = t2.trace AND t1.timeStamp = t2.timeStamp

The above SELECTs from both main and recursive tables in each recursive step.  We can instead SELECT only from the main bundle, using the recursive table to hold the minimal (e.g. primary key(s) or equivalent) values returned at each step and using them to determine the next step's WHERE or JOIN conditions.  For example:

	WITH RECURSIVE ancestor(primaryKey, trace) AS
	(
		(SELECT primarykey, trace
			FROM tw_bundle
			WHERE primarykey = 529)
	UNION ALL
		(SELECT a1.primaryKey, a1.trace
			FROM tw_bundle a1, ancestor a2
			WHERE  a1.primarykey = a2.trace)
	)
	SELECT t1.* from tw_bundle t1, ancestor t2
	WHERE t1.primaryKey = t2.primaryKey

In the code above, the recursion step's join is expressed as a WHERE clause for ease of reading.  Postgres is one of several platforms which are optimised to use ANSI Joins, rather than a WHERE clause, when joining.  Glorp generates SQL in ANSI Join form by default for such platforms.  Therefore (unless
 	useANSIJoins: false
is sent to the recursive query before executing), SQL generated for a PostgresPlatform subclass will in fact look like this:

	WITH RECURSIVE ancestor(primaryKey, trace) AS
	(
		(SELECT primarykey, trace
			FROM tw_bundle
			WHERE primarykey = 529)
	UNION
		(SELECT a1.primaryKey, a1.trace
			FROM tw_bundle a1 INNER JOIN ancestor a2
							ON a1.primarykey = a2.trace)
	)
	SELECT t1.* from tw_bundle t1, ancestor t2
	WHERE t1.primaryKey = t2.primaryKey

This is important in DB2.  DB2Platform>>supportsANSIJoinsWithRecursion returns false, so a RecursiveQuery sets 'useANSIJoins' to false on that platform.  However DB2 is unable to distinguish OUTER JOINS in ANSI syntax, so a RecursiveQuery using an OUTER JOIN will not run correctly there.

This class has no class-side instance creation protocol.  To create an instance, send a method in AbstractReadQuery's 'recursing' protocol to a final query (or send #asRecursiveQuery to the final query followed by a cascade of setters);  load the GlorpTest parcel to find examples such as

	(Query read: GlorpTreeNode where: [:each | each id = 9])
		retrieve: [:each | each parent id]
		thenFollow: #parent
		recursivelyRetrieving: [:each | each recurse parent id]
		intersect: (Query read: GlorpTreeNode).

This returns all GlorpTreeNodes that are descended from the id=9 node.
"
Class {
	#name : #RecursiveQuery,
	#superclass : #CompoundQuery,
	#instVars : [
		'mappingToCloseOver',
		'retrievalMappingExpressions',
		'unionQuery',
		'fetchBaseExpression',
		'mappingDefiner'
	],
	#category : #GlorpQueries
}

{ #category : #'VisualWorks metadata' }
RecursiveQuery class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'boolean operations' }
RecursiveQuery >> AND: anExpression [
	"Apply to the anchor query (but not the recursive one) and all the main queries.  (if the parameter is an expression, not a block, the  ANDing will rebase it, thus avoiding identity - leading to wrong table aliases and bound expressions - across queries.)"

	unionQuery queries first AND: anExpression.
	super AND: anExpression.
]

{ #category : #preparing }
RecursiveQuery >> addBoundExpressionsIn: aCommand [
	unionQuery addBoundExpressionsIn: aCommand.
	super addBoundExpressionsIn: aCommand.
]

{ #category : #executing }
RecursiveQuery >> ancestorMappingVia: aDescriptor to: anotherDescriptor [
	"If we have a complete set of primary key fields from the ancestor, set up a back-mapping to them."

	| ancestralPrimaryKeyExpressions recursionTable referenceTable ancestralMappingExpressions |
	recursionTable := aDescriptor table.
	referenceTable := anotherDescriptor table.
	ancestralMappingExpressions := retrievalMappingExpressions select:
		[:each |
		each class == MappingExpression and:
			[each allSatisfy: [:eachBase | eachBase class ~~ MappingExpression or: [eachBase name ~= mappingToCloseOver attributeName]]]].
	ancestralPrimaryKeyExpressions := ancestralMappingExpressions select:
		[:each |
		each mapping field table == referenceTable
		and: [(anotherDescriptor table hasPrimaryKeyConstraints not or: [each mapping field isPrimaryKey])
		and: [fetchBaseExpression isNil
				ifTrue: [each base base == nil]	"use printString for safety till we get fetchBaseExpression from the right place"
				ifFalse: [each base printString = fetchBaseExpression printString]]]].
	ancestralPrimaryKeyExpressions size = 1	"check it is primaryKey or table has only one field"
		ifTrue: [ancestralPrimaryKeyExpressions := ancestralPrimaryKeyExpressions first]	"cheat for now"
		ifFalse: [ancestralPrimaryKeyExpressions isEmpty
				ifFalse: [self halt: 'Tell Niall to finish this method']
				ifTrue: [^self]]	"user did not provide retrievals for it so does not want it".
	(anotherDescriptor newMapping: RecursiveMapping)
		beForPseudoVariable;
		attributeName: mappingToCloseOver attributeName, 'Recursively';	"attributeName converts param to symbol, so we need not"
		referenceClass: mappingToCloseOver referenceClass;
		collectionType: GlorpRecursiveCollection;
		useLinkTable;	"i.e. use the recursion table"
		join: (Join from: ancestralPrimaryKeyExpressions mapping field to: (recursionTable fieldNamed: ancestralPrimaryKeyExpressions commonTableExpressionName));
		reverseJoin: (Join from: (anotherDescriptor mappingForAttributeNamed: #recursed) field to: ancestralPrimaryKeyExpressions mapping field).
]

{ #category : #recursing }
RecursiveQuery >> asRecursiveQuery [
	^self
]

{ #category : #'sql generation' }
RecursiveQuery >> ensureRecursionTableToPrint [
	"Ensure we join to the recursion table.  If there is no use of the #recursed mapping in the whereClause, the ordering, the grouping or the retrievals then add it to the mainQuery.  We do not bother to alias the recursion table in this case since we know it has no reference other than the one we are now inserting.  (The coding assumes the mainQuery is a SimpleQuery or a CompoundQuery whose primaryQuery is a SimpleQuery.)
	A side effect of this is to initialize 'tablesToPrint' early.  In #printANSITablesOn:, the lazy computation of #tablesToPrint would be, by a few statements, just too lazy (i.e. too late) to supply the JoinPrinter with the correct join list in the case that we add a join if our tablesToPrint does not already include the recursion table, so it is good we force the computation early."

	| otherTablesToPrint |
	otherTablesToPrint := primaryQuery tablesToPrint.	"ASSUMES primaryQuery is simple - fix with #primaryQuery method on CompoundQuery and Query"
	(otherTablesToPrint anySatisfy:
		[:eachTable || eachParentName | eachParentName := eachTable unaliasedName.
		12 < eachParentName size and:	"unlikely a table would be named _part_ of the match, e.g. 'Recursion' but guard against index error"
			[(1 to: 12) allSatisfy:
				[:eachIndex |
				('RecursionOn_' at: eachIndex) = (eachParentName at: eachIndex)]]])
		ifFalse:	"add a join to the recursion table in the primaryQuery"
			[([:each | each recursed] asGlorpExpressionOn:
					(fetchBaseExpression isNil ifTrue: [primaryQuery baseExpression] ifFalse: [primaryQuery tracing allTracings last]))
				additionalExpressions do:
					[:each |
					(primaryQuery addJoin: each) do:
						[:eachJoin | eachJoin allTablesToPrint do:
							[:eachTable |
							(otherTablesToPrint includes: eachTable) ifFalse: [otherTablesToPrint add:eachTable]]]]].
	^otherTablesToPrint
]

{ #category : #executing }
RecursiveQuery >> executeWithParameters: parameterArray in: aSession [
	"Clone the system so we can add recursion mappings to its model during the run without affecting any other holder of the original system instance.  Conveniently, CompoundQueries do not use the 'prepare' instvar;  we therefore use it to mark whether we have prepared the recursive system.  (This should in fact overlap with having prepared my contained queries in all but pathological cases.)
	DB2Platform objects to ANSI joins in a recursive query so we force them off.  (Note that this prevents DB2 from combining recursion and OUTER JOINS since it also replies false to #useMicrosoftOuterJoins.)"

	| initialQuery recursionDescriptor iterativeQuery referenceClass referenceDescriptor referenceExpression |
	session := aSession.
	primaryQuery session: session.
	unionQuery session: session.
	aSession platform supportsANSIJoinsWithRecursion ifFalse: [primaryQuery useANSIJoins: false].
	unionQuery useANSIJoins: primaryQuery useANSIJoins.
	prepared ifTrue:
		[^session
			useSystem: unionQuery queries last baseExpression descriptor system
			while: [super executeWithParameters: parameterArray in: aSession]].
	^session
		useSystem: session system copy postCopyForRecursion
		while:	"ensure base is set (it already will be if fetchBaseExpression isGlorpExpression) ..."
			[primaryQuery baseExpression isNil ifTrue: [primaryQuery setUpBaseFromSession: session].
			primaryQuery baseExpression descriptor:	"... and its descriptor uses the copied system"
				((session system descriptorFor: primaryQuery resultClass) system: session system).
			fetchBaseExpression isNil
				ifTrue:
					[referenceClass := primaryQuery resultClass.	"or should we use initialQuery resultClass?"
					referenceExpression := primaryQuery baseExpression]
				ifFalse:
					[fetchBaseExpression := fetchBaseExpression asGlorpExpressionOn: primaryQuery baseExpression.
					referenceClass := fetchBaseExpression referenceClass.
					referenceExpression := fetchBaseExpression].
			initialQuery := unionQuery queries first.
			initialQuery session: session.
			referenceDescriptor := self session system cloneDescriptorOfClass: referenceClass for: referenceClass.
			primaryQuery resultClass == referenceDescriptor describedClass ifTrue:
				[primaryQuery baseExpression descriptor: referenceDescriptor].
			"The recursion mapping (and more) may be added to the cloned system just for this recursion."
			
			"Check isSymbol as a performance tweak - we could instead call the ifFalse branch"
			mappingToCloseOver := mappingDefiner isNil
				ifFalse: [mappingDefiner value: referenceDescriptor]
				ifTrue: [mappingToCloseOver isSymbol
						ifTrue: [referenceDescriptor mappingForAttributeNamed: mappingToCloseOver]
						ifFalse: [((self expressionBlockFor: mappingToCloseOver) asGlorpExpressionOn: referenceExpression) mapping]].
			initialQuery setUpExpressions.
			retrievalMappingExpressions := initialQuery tracing allTracings last: retrievalMappingExpressions size.
	
			"I act as a dummy result class for the recursion table, thus 'for: self' in the next line."
			recursionDescriptor := (self session system cloneDescriptorOfClass: referenceClass for: self)
				asRecursiveDescriptorOnMapping: mappingToCloseOver
				retrievingAll: retrievalMappingExpressions.
			iterativeQuery := unionQuery queries last.
			iterativeQuery session: session.
			iterativeQuery baseExpression descriptor: recursionDescriptor.
			iterativeQuery initResultClass: self whereClause: iterativeQuery whereClause singleObject: iterativeQuery readsOneObject.
			self recursedBackMappingFrom: referenceDescriptor to: recursionDescriptor.
			self ancestorMappingVia: recursionDescriptor to: referenceDescriptor.
			prepared := true.	"exploit the non-use of 'prepared' by compound queries"
			super executeWithParameters: parameterArray in: aSession]
]

{ #category : #converting }
RecursiveQuery >> fetchBaseExpression: aBlockClosureOrExpression [
	fetchBaseExpression := aBlockClosureOrExpression.
]

{ #category : #testing }
RecursiveQuery >> glorpCanHaveDescriptorDirectly [
	"Use myself as the class mapped by my recursive table, simply to have an object for the descriptor system."

	^true
]

{ #category : #accessing }
RecursiveQuery >> mappingDefiner: aOneArgBlock [
	"The parameter is the cloned referenceDescriptor.  If no suitable mapping for the recursion exists in the system, use ...defineThenFollow:... instead of ...thenFollow: ... to call this method.  The parameter must returns a mapping when evaluated with value the reference descriptor.  The block may also extract the system from the recferenceDescriptor and add mappings for the recursion to exploit if desired."

	mappingDefiner := aOneArgBlock.
]

{ #category : #accessing }
RecursiveQuery >> mappingToCloseOver [
	^mappingToCloseOver
]

{ #category : #accessing }
RecursiveQuery >> mappingToCloseOver: aSymbolOrBlock [
	"An existing mapping is identified by its name (a symbol) or by a block that defines a mapping expression.  If no suitable mapping for the recursion exists in the system, use ...defineThenFollow:... instead of ...thenFollow: ..."
	
	mappingToCloseOver := aSymbolOrBlock.
]

{ #category : #printing }
RecursiveQuery >> name [
	"This can get called if users inspect the recursive mapping or class model or iterativeQuery in my compoundQuery that use me as their describedClass or resultClass.  Avoid an error in #printOn: by providing something."

	^self printString
]

{ #category : #copying }
RecursiveQuery >> postCopy [
	"Copying re-validates my queries' whereClauses, which may contain recursion mappings undefined in the main system. As they have been and/or will be validated at the proper time, just resume any validation errors raised.  TBR:  should we check that the last characters of the error's message text are 'Recursively' or 'recurse or whatever (as this is the case where the error will not signify)?"

	[unionQuery := unionQuery copy.
	super postCopy]
		on: ValidationError
		do: [:ex | ex resume]
]

{ #category : #preparing }
RecursiveQuery >> prepare [
	unionQuery prepare.
	super prepare.
]

{ #category : #preparing }
RecursiveQuery >> prepareOrderingAround: aBlock [
	"Recursive queries have already addressed known ordering issues.  Do not use the super implementor here until its inteaction with the existing ordering issues is assesed."

	aBlock value.
]

{ #category : #executing }
RecursiveQuery >> recursedBackMappingFrom: aDescriptor to: anotherDescriptor [
	"Create a 'recursed' mapping from the recursion target back to the recursion table.  (We could use #reverseMapping to get it from the 'recurse' mapping, but for now, create it in parts for greater control and clarity.)"

	| recursionBackJoin localClassModel recursionBackAttribute recursionBackMapping |
	recursionBackJoin := (anotherDescriptor mappingForAttributeNamed: 'recurse' asSymbol) join inverseJoin.
	localClassModel := aDescriptor classModel.
	recursionBackAttribute := localClassModel attributeNamed: 'recursed'.
	recursionBackMapping := aDescriptor oneToOneMapping.
	recursionBackMapping attributeName: recursionBackAttribute name.
	recursionBackMapping referenceClass: self.
	recursionBackMapping join: recursionBackJoin.
	recursionBackMapping beForPseudoVariable.
]

{ #category : #accessing }
RecursiveQuery >> retrievalMappingExpressions: someSymbols [
	retrievalMappingExpressions := someSymbols.
]

{ #category : #executing }
RecursiveQuery >> sqlWith: aDictionary [
	self prepare.
	^RecursiveCommand
		forQuery: self
		parameters: aDictionary
		useBinding: session useBinding
		session: session.
]

{ #category : #'initialize-release' }
RecursiveQuery >> start: initialQuery retrieveAll: anArray recursivelyRetrievingAll: anotherArray [
	"This convenience protocol simplifies setting these three interrelated parameters in a cascade."

	self
		retrievalMappingExpressions: anArray;
		unionQuery:
			(CompoundQuery newUnionAll
				requiresDistinct: false;
				addQuery: (initialQuery retrieveAll: anArray);
				addQuery: ((initialQuery class read: self resultClass)
							retrieveAll: anotherArray;
							yourself)).
]

{ #category : #'boolean operations' }
RecursiveQuery >> unionAll: aQuery [
	operation isNil ifFalse: [^super unionAll: aQuery].
	aQuery shortCircuitEmptyReturn ifTrue: [^self].
	"self requiresDistinct: true.	we assume not;  to review"
	self operation: #'UNION ALL'.
	queries add: aQuery.
	"^self"
]

{ #category : #accessing }
RecursiveQuery >> unionQuery [
	^unionQuery
]

{ #category : #accessing }
RecursiveQuery >> unionQuery: aCompoundQuery [
	unionQuery := aCompoundQuery.
]
