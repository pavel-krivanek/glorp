"
I implement a recursive SQL query using a common table expression.  I use the state and behaviour I inherit from my superclass to define the final query that will actually return rows to the user, holding the anchor and recursive queries inside a compound query.

Instance Variables:
	mappingToCloseOver	<Symbol | RelationshipMapping>	the self-relationship that we will follow recursively
	retrievalMappingExpressions	<Collection of: Symbol | MappingExpression>	mapping expressions connecting the bases to the fields that will be cloned to the recursion table
	unionQuery	<CompondQuery>	contains the anchor and recursive queries

 Recursive queries contain the following elements (this example is in PostgreSQL form):

	""First we define the common table expression.""
	WITH RECURSIVE ancestor(primaryKey, trace, timeStamp) AS
	(	""An anchor query populates the first row(s) of the recursion.
		(SELECT primarykey, trace, timeStamp
			FROM tw_bundle
			WHERE primarykey = 529)	""id of some bundle whose ancestors we wil read""
	UNION	""A UNION ALL or similar (UNION, INTERSECT, etc.) unites the anchor query(ies) to the recursive query""
		(SELECT a2.primaryKey, a1.trace, a1.timeStamp
			FROM tw_bundle a1 INNER JOIN ancestor a2
							ON a1.primarykey = a2.trace)
	)	""Finally, we select the rows to return from the common table and others""
	SELECT t1.* from tw_bundle t1, ancestor t2
	WHERE t1.trace = t2.trace AND t1.timeStamp = t2.timeStamp

The above is a general form.  We can read only from the main bundle in each recursive step, just using the recursive table to hold the minimal (i.e. primary key equivalent for this query) values returned at each step and using them to determine the next step's where or join conditions.  For example:

WITH RECURSIVE ancestor(primaryKey, trace) AS
(
	(SELECT primarykey, trace
		FROM tw_bundle
		WHERE primarykey = 529)
UNION
	(SELECT a1.primaryKey, a1.trace
		FROM tw_bundle a1, ancestor a2
		WHERE  a1.primarykey = a2.trace)
)
SELECT t1.* from tw_bundle t1, ancestor t2
WHERE t1.primaryKey = t2.primaryKey

The following is equally valid on Postgres.  (The INNER JOIN is the ANSI form of joining, used by preference on some platforms.)

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
"
Class {
	#name : #RecursiveQuery,
	#superclass : #SimpleQuery,
	#instVars : [
		'mappingToCloseOver',
		'retrievalMappingExpressions',
		'unionQuery'
	],
	#category : #GlorpQueries
}

{ #category : #'instance creation' }
RecursiveQuery class >> read: aClass where: anExpression retrieveAll: anArray thenFollow: aSymbol recursivelyRetrievingAll: anotherArray [
	"The recursivelyRead array is an array of mapping names, all direct.  The for symbol is a self mapping that uses the direct mappings; it is the mapping we will recurse over.  The retrieveAll array is an array of symbols or blocks (usually the latter) selecting what the iterative step will retrieve from the recursion table and, via the recurse mapping, the main table(s)."

	^(self new initResultClass: aClass whereClause: nil singleObject: false) 
		mappingToCloseOver: aSymbol;
		retrievalMappingExpressions: anArray;
		unionQuery:
			(CompoundQuery newUnionAll
				requiresDistinct: false;
				addQuery: ((self read: aClass where: anExpression)
							retrieveAll: anArray;
							yourself);
				addQuery: ((self read: aClass)
							retrieveAll: anotherArray;
							yourself));
		yourself
]

{ #category : #preparing }
RecursiveQuery >> addBoundExpressionsIn: aCommand [
	unionQuery addBoundExpressionsIn: aCommand.
	super addBoundExpressionsIn: aCommand.
]

{ #category : #recursing }
RecursiveQuery >> asRecursiveQuery [
	^self
]

{ #category : #recursing }
RecursiveQuery >> cloneDescriptor: aDescriptor for: aGlorpCanHaveDescriptorDirectly [
	| newDescriptor |
	newDescriptor := aDescriptor copy.
	newDescriptor system: self session system.
	newDescriptor classModel: aDescriptor classModel copy.
	newDescriptor classModel system: self session system.
	newDescriptor classModel privateAndBasicSetDescribedClass: aGlorpCanHaveDescriptorDirectly.
	self session system
		privateAndBasicAddDescriptorFor: aGlorpCanHaveDescriptorDirectly
		as: newDescriptor.
	^newDescriptor
]

{ #category : #executing }
RecursiveQuery >> executeWithParameters: parameterArray in: aSession [
	"Clone the system so we can add recursion mappings to its model during the run without affecting any other holder of the original system instance."

	| recursionDescriptor initialQuery iterativeQuery |
	initialQuery := unionQuery queries first.
	initialQuery
		session: aSession;
		setUpExpressions.
	retrievalMappingExpressions := initialQuery tracing allTracings last: retrievalMappingExpressions size.
	mappingToCloseOver isSymbol ifTrue:
		[mappingToCloseOver := initialQuery descriptor mappingForAttributeNamed: mappingToCloseOver].
	self session: aSession.
	^aSession
		useSystem: aSession system copy postCopyForRecursion
		while:	"I act as a dummy result class for the recursion table, thus 'for: self' in the next line."
			[recursionDescriptor := (self cloneDescriptor: initialQuery descriptor for: self)
				asRecursiveDescriptorOnMapping: mappingToCloseOver
				retrievingAll: retrievalMappingExpressions.
			iterativeQuery := unionQuery queries last.
			iterativeQuery session: aSession.
			iterativeQuery baseExpression descriptor: recursionDescriptor.
			iterativeQuery initResultClass: self whereClause: iterativeQuery whereClause singleObject: iterativeQuery readsOneObject.
			unionQuery session: aSession.
			self
				whereClauseJoining: (self cloneDescriptor: self descriptor for: self resultClass)
				toRecursion: recursionDescriptor.
			super executeWithParameters: parameterArray in: aSession]
]

{ #category : #testing }
RecursiveQuery >> glorpCanHaveDescriptorDirectly [
	"Use myself as the class mapped by my recursive table, simply to have an object for the descriptor system."

	^true
]

{ #category : #accessing }
RecursiveQuery >> mappingToCloseOver [
	^mappingToCloseOver
]

{ #category : #accessing }
RecursiveQuery >> mappingToCloseOver: aSymbol [
	mappingToCloseOver := aSymbol.
]

{ #category : #printing }
RecursiveQuery >> name [
	"This can get called if users inspect the recursive mapping or class model or iterativeQuery in my compoundQuery that use me as their describedClass or resultClass.  Avoid an error in printOn: be providing something."

	^self printString
]

{ #category : #preparing }
RecursiveQuery >> prepare [
	super prepare.
	unionQuery prepare.
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

{ #category : #accessing }
RecursiveQuery >> unionQuery [
	^unionQuery
]

{ #category : #accessing }
RecursiveQuery >> unionQuery: aCompoundQuery [
	unionQuery := aCompoundQuery.
]

{ #category : #executing }
RecursiveQuery >> whereClauseJoining: aDescriptor toRecursion: anotherDescriptor [
	"Create a 'recursed' mapping from the recursion table back to the original.  We could use #reverseMapping to get it from the 'recurse' mapping, but for now,create it in parts for greater contro and clarity.  Then restrict the final query to rows that map to the recursion table."

	| recursionBackJoin localClassModel recursionBackAttribute recursionBackMapping |
	recursionBackJoin := (anotherDescriptor mappingForAttributeNamed: 'recurse' asSymbol) join inverseJoin.
	localClassModel := aDescriptor classModel.
	recursionBackAttribute := localClassModel attributeNamed: 'recursed'.
	recursionBackMapping := aDescriptor oneToOneMapping.
	recursionBackMapping attributeName: recursionBackAttribute name.
	recursionBackMapping referenceClass: self.
	recursionBackMapping join: recursionBackJoin.
	recursionBackMapping beForPseudoVariable.
	self baseExpression descriptor: aDescriptor.
	self AND: [:each | each recursed notNil].
]
