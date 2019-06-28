"
This is a query that has more than one subquery, combined by expressions like UNION ALL or INTERSECTION. It doesn't do all that much except print its subqueries and combine them according to the operation.

Instance Variables:
	operation	<String>	The name of the operation we are using to combine the queries.
	primaryQuery	<Query>	The first query that we contain. This determines what objects we actually return. All of the queries should match up in terms of what they return, or the database is unlikely to accept this as a valid query.
	queries	<(SequenceableCollection of: SimpleQuery)>	The queries we contain.
"
Class {
	#name : #CompoundQuery,
	#superclass : #Query,
	#instVars : [
		'queries',
		'operation',
		'primaryQuery',
		'requiresDistinct'
	],
	#category : #GlorpQueries
}

{ #category : #'instance creation' }
CompoundQuery class >> newIntersect [
	^self new operation: #INTERSECT.
]

{ #category : #'instance creation' }
CompoundQuery class >> newMinus [
	^self new operation: #EXCEPT.
]

{ #category : #'instance creation' }
CompoundQuery class >> newUnionAll [
	^self new operation: #'UNION ALL'.
]

{ #category : #'VisualWorks metadata' }
CompoundQuery class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'boolean operations' }
CompoundQuery >> AND: anExpression [
	"If intentionally sent to a comppund query, presumably we want each and every contained query limited by the ANDed clause.  (if the parameter is an expression, not a block, the  ANDing will rebase it, thus avoiding identity - leading to wrong table aliases and bound expressions - across queries.)"

	queries do: [:each | each AND: anExpression].
]

{ #category : #preparing }
CompoundQuery >> addBoundExpressionsIn: aCommand [
	queries do: [:each | each addBoundExpressionsIn: aCommand].
]

{ #category : #accessing }
CompoundQuery >> addQuery: aQuery [
	queries isEmpty ifTrue: [primaryQuery := aQuery].
	queries add: aQuery.
]

{ #category : #preparing }
CompoundQuery >> aliasDuplicateFieldNames: anOrderedCollection [ 
	queries do: [:each | each aliasDuplicateFieldNames: anOrderedCollection ]
]

{ #category : #accessing }
CompoundQuery >> baseExpression [
	^primaryQuery baseExpression.
]

{ #category : #preparing }
CompoundQuery >> copyOfBuilders [
	^primaryQuery copyOfBuilders
]

{ #category : #copying }
CompoundQuery >> copyOfBuildersFor: aGlorpCursoredStream [
	"If my queries return a constant, do not assume it has the same value in each query;  change the builder to show this."

	^self copyOfBuilders collect: 
		[:each | each onCompoundCursor: aGlorpCursoredStream]
]

{ #category : #'boolean operations' }
CompoundQuery >> except: aQuery [
	^self minus: aQuery.
]

{ #category : #executing }
CompoundQuery >> executeWithParameters: parameterArray in: aSession [
	session := aSession.
	^self 
		readFromDatabaseWithParameters: parameterArray.
]

{ #category : #initializing }
CompoundQuery >> initialize [
	super initialize.
	requiresDistinct := true.
	queries := OrderedCollection new: 3.
]

{ #category : #testing }
CompoundQuery >> isIntersect [
	^operation = #INTERSECT.
]

{ #category : #testing }
CompoundQuery >> isMinus [
	^operation = #EXCEPT.
]

{ #category : #testing }
CompoundQuery >> isUnionAll [
	^operation = #'UNION ALL'.
]

{ #category : #accessing }
CompoundQuery >> joins [
	^queries inject: #() into: [:sum :each | sum, each joins].
]

{ #category : #accessing }
CompoundQuery >> limit [
	^primaryQuery limit.
]

{ #category : #accessing }
CompoundQuery >> limit: anInteger [
	"We currently ignore limit sets and use the one from our contained queries."
	^self.
]

{ #category : #accessing }
CompoundQuery >> mightHaveDuplicateRows [
	^primaryQuery mightHaveDuplicateRows.
]

{ #category : #'boolean operations' }
CompoundQuery >> minus: aQuery [
	aQuery shortCircuitEmptyReturn ifTrue: [^self].
	^CompoundQuery newMinus addQuery: self; addQuery: aQuery.
]

{ #category : #accessing }
CompoundQuery >> offset [
	^primaryQuery offset.
]

{ #category : #accessing }
CompoundQuery >> offset: anInteger [
	"We currently ignore offset sets and use the one from our contained queries."
	^self.
]

{ #category : #accessing }
CompoundQuery >> operation: aString [
	operation := aString.
]

{ #category : #copying }
CompoundQuery >> postCopy [

	super postCopy.
	queries := queries collect: [:each | each copy].
	primaryQuery := queries first.
]

{ #category : #preparing }
CompoundQuery >> prepare [
	"Aliasing must be done after sub-query preparation, so each query's 'fields' instvar is set, and after ordering and grouping, since the user must themselves alias same-name fields if they use them for either.  Absurdly, Oracle, SQLServer and MySQL will not tolerate two unaliased fields in different tables but of the same name in a compound query, so aliasing may also be used merely to avoid that issue.
	On some platforms, subqueries cannot have ordering:  see #prepareOrderingAround:'s commentß."

	| aliasing |
	aliasing := OrderedCollection new.
	self prepareOrderingAround:
		[queries do: [:each | each session: session].
		queries do: [:each | each prepare]].
	ordering isNil ifFalse:
		[ordering := ordering collect:
			[:each || orderingExpression |
			orderingExpression := (self expressionBlockFor: each) asGlorpExpressionOn: primaryQuery baseExpression.
			orderingExpression class == PseudoColumnFunction
				ifFalse: [orderingExpression]
				ifTrue:
					[aliasing add: ((FieldExpression forField: orderingExpression field basedOn: primaryQuery baseExpression) alias: orderingExpression alias).
					FieldExpression forField: (orderingExpression field copy name: orderingExpression alias) basedOn: primaryQuery baseExpression]]].
	grouping isNil ifFalse:
		[grouping := grouping collect:
			[:each | (self expressionBlockFor: each) asGlorpExpressionOn: primaryQuery baseExpression]].
	(aliasing isEmpty and: [self platform supportsDuplicateFieldNamesInCompoundQueries]) ifFalse:
		[queries do: [:each | each aliasDuplicateFieldNames: aliasing]].
]

{ #category : #preparing }
CompoundQuery >> prepareOrderingAround: aBlock [
	"(We may need to make the following fixes for grouping as well, but for now, we just look at ordering.)  On some platforms, subqueries cannot have ordering.  If any (sub)queries are ordered at the start of this method, flag the query as unrunnable on this platform and invite the user to rewrite with the order set on this query.  Because we do that, we know that if the subqueries are ordered after they are prepared (on a platform that does not support subqueries being ordered), then their ordering was generated by their mappings and the user cannot rewrite it.  We therefore pull it from them to the outer query.  BE AWARE: the current implementation pulls the ordering from primaryQuery and assumes that the other subqueries have the same ordering or that the primaryQuery's ordering is acceptable for all.  Ideally, this equality would be checked and some kind of unification done if it were absent, but (even if there is a general right answer in such a case) implementation will wait till we have one to study.  Menahwile, the only notification raised to the user is when the primaryQuery has no mapping-generated ordering but another subquery has:  in that case, the query will fail on an unsupporting platform, revealing the problem.
	Since we nil primaryQuery ordering along with the others after applying its ordering to the compound query, reentering this method will be a no-op.  (N.B.:  if an unprepared subquery were added to tgis query after preparation, that might not be true, but arguably the case is pathological anyway.)"

	self platform supportsOrderedSubqueriesInCompoundQueries ifTrue: [^aBlock value].
	(queries allSatisfy: [:each | each hasOrdering not]) ifFalse:
		[self error: 'Any ordering clause(s) must be on this ', operation, ' query, not a subquery, if running on ', self platform kind].
	aBlock value.	"subqueries have no orderings on entry, but mappings may apply orderings in #prepare"
	primaryQuery hasOrdering ifFalse: [^self].
	primaryQuery ordering do: [:each | self orderBy: each].
	queries do: [:each | each setOrdering: nil].
]

{ #category : #accessing }
CompoundQuery >> primaryQuery: aQuery [
	primaryQuery := aQuery.
]

{ #category : #printing }
CompoundQuery >> printCompoundSelectAliasesOn: aStream [
	"The caller has already checked that we need a wrapper query and that the platform supportsAliasInCompoundQuery so we do not need to check it again here.  If there are no ordering or grouping fields, we merely use the first aliased table name (which will almost certainly be the first table name - an exception is if a RecursiveQuery has forced the unaliased recursion table name into the tablesToPrint).  If there are, the ordering and/or grouping fields may not all be on one table.  We use the aliased table that has the largest number and rename the aliases of any others while printing the ordering and grouping SQL, so all fields refer to the compound alias."

	| tracedExpressionFields compoundAliasTable switchedAliases |
	tracedExpressionFields := IdentityDictionary new.
	ordering isNil ifFalse:
		[ordering do:
			[:each |
			each hasField ifTrue:
				[(tracedExpressionFields at: each field asField table ifAbsentPut: [OrderedCollection new]) add: each]]].
	grouping isNil ifFalse:
		[grouping do:
			[:each |
			each hasField ifTrue:
				[(tracedExpressionFields at: each field asField table ifAbsentPut: [OrderedCollection new]) add: each]]].
	tracedExpressionFields isEmpty
		ifTrue:	"the first table that is not the unaliased recursion table will do"
			[compoundAliasTable := primaryQuery tablesToPrint
				detect: [:each | each isAliased]
				ifNone: [self halt: 'This should not happen']]
		ifFalse:	"choose the table with the most ordering or grouping fields"
			[compoundAliasTable := ((2 to: tracedExpressionFields size)
				inject: tracedExpressionFields values first
				into: [:prev :index || next | next := tracedExpressionFields values at: index.
					prev size < next size ifTrue: [next] ifFalse: [prev]]) first field asField table.
			tracedExpressionFields removeKey: compoundAliasTable].
	aStream nextPutAll: ' '.
	compoundAliasTable printSQLOn: aStream withParameters: nil.
	"If not all fields are on the same table, switch the alias while printing."
	switchedAliases := IdentityDictionary new.
	tracedExpressionFields keys do:
		[:aliasedTable |
		switchedAliases at: aliasedTable put: aliasedTable name.
		aliasedTable name: compoundAliasTable name].
	[super printCompoundSelectAliasesOn: aStream]
		ensure: [switchedAliases keysAndValuesDo:
				[:aliasedTable :aliasName |
				aliasedTable name: (switchedAliases at: aliasedTable)]].
]

{ #category : #printing }
CompoundQuery >> printOperationOn: aCommand [
	aCommand space.
	aCommand nextPutAll: (self platform compoundOperationFor: operation).
	aCommand space.
]

{ #category : #accessing }
CompoundQuery >> proxyType [
	^primaryQuery proxyType.
]

{ #category : #accessing }
CompoundQuery >> proxyType: aClass [	
	"We currently ignore proxy types and use the ones from our main query."
	^self.
]

{ #category : #accessing }
CompoundQuery >> queries [
	^queries
]

{ #category : #accessing }
CompoundQuery >> queries: aCollectionOfQueries [
	queries := aCollectionOfQueries
]

{ #category : #executing }
CompoundQuery >> readFromDatabaseWithParameters: anArray [
	| answerStream result |
	answerStream := self rowsFromDatabaseWithParameters: anArray.
	^self readsOneObject
		ifTrue: [result := answerStream next. answerStream release. result]
		ifFalse: [self resultCollectionFor: answerStream].
]

{ #category : #accessing }
CompoundQuery >> requiresDistinct [
	^requiresDistinct
]

{ #category : #accessing }
CompoundQuery >> requiresDistinct: aBoolean [
	requiresDistinct := aBoolean.
]

{ #category : #accessing }
CompoundQuery >> resultClass [
	^primaryQuery resultClass.
]

{ #category : #'sql generation' }
CompoundQuery >> rewriteExcept [
	"Rewrite any EXCEPT operation we have into a NOT EXISTS test with a correlated subselect. Only a CompoundQuery would have an EXCEPT"
	
	| |
	operation == #EXCEPT ifFalse: [^self].
	queries := queries collect: [:each | each rewriteExcept].
	^self rewriteSetOperationUsing: #notExists:
]

{ #category : #'sql generation' }
CompoundQuery >> rewriteIntersect [
	"Rewrite any INTERSECT operation we have into an EXISTS test for a correlated subselect. Only a CompoundQuery would have an intersect"
	
	| |
	operation == #INTERSECT ifFalse: [^self].
	queries := queries collect: [:each | each rewriteIntersect].
	^self rewriteSetOperationUsing: #exists:
]

{ #category : #'sql generation' }
CompoundQuery >> rewriteSetOperationUsing: aSelector [
	"Rewrite any INTERSECT OR EXCEPT operation we have into a correlated EXISTS or NOT EXISTS test, respectively. We take the sub-query, and AND into it a constraint that its base expression is equal to the first queries base expression, and then do either an exists: or a notExists:, depending on aSelector."
	
	| newQuery |
	newQuery := primaryQuery copy.
	2 to: queries size do:
		[:i || q expression mainExpression | q := (queries at: i) copy.
		expression := RelationExpression new
			relation: #=; leftChild: newQuery baseExpression; rightChild: q baseExpression.
		mainExpression := RelationExpression new
			relation: #AND; leftChild: q whereClause; rightChild: expression.
		q whereClause: mainExpression.
		newQuery AND: [:each | each perform: aSelector with: q]].
	^newQuery
]

{ #category : #executing }
CompoundQuery >> rowsFromDatabaseWithParameters: anArray [
	^session accessor
		executeCommand: (self sqlWith: anArray)
		returnCursor: true.
]

{ #category : #initializing }
CompoundQuery >> setUpBaseFromSession: aSession [
	primaryQuery setUpBaseFromSession: aSession.
]

{ #category : #testing }
CompoundQuery >> shortCircuitEmptyReturn [
	^false.
]

{ #category : #accessing }
CompoundQuery >> shouldRefresh [
	^primaryQuery shouldRefresh.
]

{ #category : #accessing }
CompoundQuery >> shouldRefresh: aBoolean [
	"We currently ignore sets of this, and use the value from our primary query."
	^self.
]

{ #category : #printing }
CompoundQuery >> sqlString [
	"Mostly for debugging"
	^(self sqlWith: #()) sqlString.
]

{ #category : #printing }
CompoundQuery >> tablesToPrint [
	^primaryQuery tablesToPrint
]

{ #category : #accessing }
CompoundQuery >> tracing [
	^primaryQuery tracing.
]

{ #category : #'boolean operations' }
CompoundQuery >> unionAll: aQuery [
	aQuery shortCircuitEmptyReturn ifTrue: [^self].
	^self isUnionAll
		ifTrue:
			[queries add: aQuery.
			self]
		ifFalse:
			[(CompoundQuery newUnionAll)
				addQuery: self;
				addQuery: aQuery].
]

{ #category : #testing }
CompoundQuery >> useANSIJoins: aBoolean [
	queries do: [:each | each useANSIJoins: aBoolean].
]

{ #category : #accessing }
CompoundQuery >> whereClause [
	| allCriteria |
	allCriteria := queries inject: #() into: [:sum :each | sum, each whereClause].
	^ExpressionGroup new addAll: allCriteria	"this #addAll: returns self, not its parameter"
]
