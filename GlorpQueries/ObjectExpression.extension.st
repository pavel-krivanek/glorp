Extension { #name : #ObjectExpression }

{ #category : #'*GlorpQueries-api-aggregates' }
ObjectExpression >> aggregate: anExpression as: aggregateFunctionName where: whereExpression [
	"This is the most general form of aggregation convenience method, and other aggregations, e.g. sqlCount, are implemented in terms of it.  This method creates a subselect out of the expression that is our argument (anExpression), returning an aggregation expression based on it.  For example,
	session read: GlorpCustomer where:
		[:each | (each aggregate: each accounts as: #countStar where: [:acct | acct price > 1000]) = 1].
would find all customers who had exactly one account whose value exceeded 1000."

	| q expression next objectExpression retrievalExpression basicExpression |
	"We may be passed an expression corresponding to either a field, or to a full object, depending on the aggregate function. In either case, build backwards from the first full object"
	objectExpression := anExpression mapping isRelationship
		ifTrue: [anExpression] ifFalse: [anExpression base].
	q := Query read: objectExpression referenceClass.
	expression := q baseExpression.
	next := objectExpression.
	[next base isNil or: [next class == SubSelectBaseExpression]] whileFalse:
		[expression := next mapping addPhantomMappingExpressionOn: expression.
		next := next base].
	"We have to force construct the equality expression, because we don't want 'self' rebuilt onto the other base"
	expression := RelationExpression new outerJoin: false; relation: #=; leftChild: expression; rightChild: self.
	q whereClause: expression.
	"We need to rebuild the thing we're using to retrieve in the right context. Also, if we're called directly, the symbol may be wrapped as a constantExpression. Unwrap it"
	basicExpression := anExpression rebuildOn: q baseExpression startingFrom: objectExpression.
	retrievalExpression := (basicExpression get: aggregateFunctionName asGlorpExpression value).
	q retrieve: retrievalExpression.
	whereExpression == nil ifFalse:
		[q AND: (whereExpression asGlorpExpressionOn: basicExpression)].
	^q asGlorpExpressionOn: self ultimateBaseExpression.
]

{ #category : #'*GlorpQueries-api-aggregates' }
ObjectExpression >> existenceCheck: anExpression as: functionName [
	"Make a subselect of the expression that is our argument, returning it wrapped in either an exists or a not exists, e.g. 
	session read: GlorpCustomer where: 	[:each |  
		each existenceCheck: eachCust accounts as: #exists:].
	This is the most general form of existence checking convenience method, others are implemented in terms of it. It's very similar to aggregate:as:where:, but simpler."

	| q expression next objectExpression |
	"We may be passed an expression corresponding to either a field, or to a full object, depending on the aggregate function. In either case, build backwards from the first full object"
	objectExpression := anExpression mapping isRelationship 
		ifTrue: [anExpression] ifFalse: [anExpression base].
	q := Query read: objectExpression mapping referenceClass.
	expression := q baseExpression.
	next := objectExpression.
	[next base isNil] whileFalse: [
		expression := next mapping addPhantomMappingExpressionOn: expression.
		next := next base].
	"We have to force construct the equality expression, because we don't want 'self' rebuilt onto the other base"
	expression := RelationExpression new outerJoin: false; relation: #=; leftChild: expression; rightChild: self.
	q whereClause: expression.
	"Just read back a literal constant, we don't actually care about the data"
	q retrieve: ([:each | 'x' ] asGlorpExpression getFunction: #distinct withArguments: #()).
	^self get: functionName withArguments: (Array with: (q asGlorpExpressionOn: self ultimateBaseExpression)).
]
