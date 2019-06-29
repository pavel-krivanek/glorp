Extension { #name : #RelationExpression }

{ #category : #'*GlorpDatabase-preparing' }
RelationExpression >> condensePrimaryKeyComparison [
	"This tries to condense expressions of the form
		something relatedObject id = x
into
		something foreignKeyToRelatedObjectId = x
so saving a join (and making the thing work at all, in the case where x = nil).  If the join thus saved is an outer join, the expression should also be - and must be moved from the whereClause to the 'joins' instvar later in query preparation if ANSI syntax is to represent it so."

	| fieldBeingCompared baseObjectExpression join sourceField condensedExpression |
	(relation = #= or: [relation = #<>]) ifFalse: [^self].
	self leftChild mappedFields size = 1 ifFalse: [^self].
	fieldBeingCompared := self leftChild field.
	fieldBeingCompared class == DatabaseField ifFalse: [^self].
	fieldBeingCompared isPrimaryKey ifFalse: [^self].
	baseObjectExpression := self leftChild base.
	baseObjectExpression representsDerivedObject ifFalse: [^self].
	"If we have an expression for a join, don't even try."
	baseObjectExpression join isJoin ifFalse: [^self].
	join := baseObjectExpression join
				asGlorpExpressionOn: baseObjectExpression base.
	sourceField := join sourceForTarget: fieldBeingCompared ifNone: [^self].

	"OK, we've got a match, replace ourselves with the shortcut."
	condensedExpression := (sourceField isGlorpExpression
				and: [sourceField isConstantExpression])
					ifTrue: 
						[self rightChild get: relation withArguments: (Array with: sourceField)]
					ifFalse: 
						[(self leftChild base base getField: sourceField) get: relation
							withArguments: (Array with: self rightChild)].
	condensedExpression privateBeOuterJoin: join privateGetOuterJoin.
	^condensedExpression
]

{ #category : #'*GlorpDatabase-converting' }
RelationExpression >> generalExpressionPart [
	| left right |
	left := leftChild generalExpressionPart.
	right := rightChild generalExpressionPart.
	(left isNil and: [right isNil]) ifTrue: [^nil].
	left isNil ifTrue: [^right].
	right isNil ifTrue: [^left].
	^self.
]
