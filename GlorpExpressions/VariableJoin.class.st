"
This represents a join that could be to multiple different tables, e.g. when using horizontal inheritance.

Instance Variables:
	joins	<Dictionary from: Class to: Join>	description of joins


"
Class {
	#name : #VariableJoin,
	#superclass : #Object,
	#instVars : [
		'joins'
	],
	#category : #'GlorpExpressions-Glorp'
}

{ #category : #'instance creation' }
VariableJoin class >> new [
	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
VariableJoin class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
VariableJoin >> addJoinFor: aClass as: aJoin [
	joins at: aClass put: aJoin.
]

{ #category : #accessing }
VariableJoin >> allSourceFields [
	"We assume that variable joins vary in the targets, not the in sources."
	^self anyJoin allSourceFields
]

{ #category : #accessing }
VariableJoin >> allTargetFields [
	^joins inject: OrderedCollection new into: [:sum :each | sum addAll: each allTargetFields. sum].
]

{ #category : #accessing }
VariableJoin >> anyJoin [
	^joins detect: [:each | true].
]

{ #category : #preparing }
VariableJoin >> asExpressionJoiningSource: sourceExpression toTarget: targetExpression [
	| expression |
	joins do:
		[:each |
		expression := (each asExpressionJoiningSource: sourceExpression toTarget: targetExpression) OR: expression].
	^expression
]

{ #category : #converting }
VariableJoin >> asGeneralGlorpExpression [
	"We know that we represent querying for an abstract class, so we don't want to convert ourselves to a join form, but rather just to a source mapping form. There are some assumptions in here, but it should work for the basic cases anyway."

	| base expression anyJoin descriptor |
	anyJoin := self anyJoin.
	base := anyJoin base.
	descriptor := base system findDescriptorForTable: anyJoin allTargetFields first table.
	expression := EmptyExpression new base: base.
	anyJoin mappableFieldsDo: [:source :target |
		| mapping thingToCompare |
		mapping := descriptor mappingForField: target.
		thingToCompare := mapping isNil
			ifTrue: [base getField: target]
			ifFalse: [base get: mapping attributeName].
		expression := expression AND: (thingToCompare get: #= withArguments: (Array with: (source asGlorpExpressionOn: base)))].
	^expression.
]

{ #category : #converting }
VariableJoin >> asGeneralGlorpExpressionWithFields [
	"The normal conversion of a join is to an expression equating fields and parameters. Instead, generate one with field to field comparisons."

	| base expression mappingName anyJoin descriptor |
	anyJoin := self anyJoin.
	base := anyJoin base.
	descriptor := base system findDescriptorForTable: anyJoin allTargetFields first table.
	expression := EmptyExpression new base: base.
	anyJoin mappableFieldsDo: [:source :target |
		mappingName := (descriptor mappingForField: target) attributeName.
		expression := expression AND: ((base get: mappingName) get: #= withArguments: (Array with: (self targetExpressionFor: source)))].
	^expression.
]

{ #category : #converting }
VariableJoin >> asGlorpExpressionOn: aBaseExpression [
	| copy |
	copy := self copy.
	copy joins: (copy joins collect: [:each | each asGlorpExpressionOn: aBaseExpression]).
	^copy.
]

{ #category : #accessing }
VariableJoin >> generalExpressionPart [
	^nil.
]

{ #category : #'initialize-release' }
VariableJoin >> initialize [
	joins := IdentityDictionary new.
]

{ #category : #converting }
VariableJoin >> isConstant: aTarget [
	"The target can be either a constant (which gets turned into a ConstantExpression) or (usually) a DatabaseField, representing a parameter to the query."

	(aTarget class == DatabaseField) ifTrue: [^false].
	^aTarget isGlorpExpression not
		or: [aTarget isConstantExpression]
]

{ #category : #testing }
VariableJoin >> isGlorpExpression [
	^true.
]

{ #category : #testing }
VariableJoin >> isJoin [
	^true.
]

{ #category : #testing }
VariableJoin >> isOuterJoin [
	"The outer join state must be the same for all (or much additional thinking is needed).  This is checked in #validate."

	^self anyJoin isOuterJoin
]

{ #category : #accessing }
VariableJoin >> joins [
	^joins.
]

{ #category : #accessing }
VariableJoin >> joins: aCollection [
	joins := aCollection.
]

{ #category : #api }
VariableJoin >> mapFromSource: sourceObject andTarget: targetObject intoRowsIn: aRowMap [
	"Return the join for the target object, or the variable join if there is none."

	(sourceObject isNil or: [targetObject isNil]) ifTrue: [^self].
	^(joins at: targetObject class)
		mapFromSource: sourceObject
		andTarget: targetObject
		intoRowsIn: aRowMap.
]

{ #category : #accessing }
VariableJoin >> mappableSourceFieldsDo: aBlock [

	self anyJoin mappableSourceFieldsDo: aBlock.
]

{ #category : #preparing }
VariableJoin >> prepareIn: aQuery [
	"There was a significant problem with horizontal inheritance where a VariableJoin was getting converted into a full expression in a query before that query had time to be converted to a full query and then back into sub-queries. When we did this, it lost information, so the sub-queries would get generated with each one talking to the same sub-table. We therefore delay conversion by not having VariableJoin convert itself to a general expression (so this method is now a no-op instead of
	aQuery whereClause: self asGeneralGlorpExpression.
as it used to be) which required implementing a bit more protocol on VariableJoin (these changes were integrated in Glorp (0.4.162) on 23oct2007).
	This also exposed a subtle bug with subselects where we had a join whose base was not a base expression, and so asking it for ultimateBaseExpression gave the wrong answer. This was fixed by also sending ultimateBaseExpression to the result."
]

{ #category : #'primary keys' }
VariableJoin >> primaryKeyFromDictionary: anIdentityDictionary [ 
	^self anyJoin primaryKeyFromDictionary: anIdentityDictionary.
]

{ #category : #printing }
VariableJoin >> printOn: aStream [
	[aStream query] on: Error do: [:ex | ^super printOn: aStream].
	(joins at: aStream query resultClass) printOn: aStream.
]

{ #category : #printing }
VariableJoin >> printSQLOn: aStream withParameters: aDictionary [ 
	[aStream query] on: Error do: [:ex | ^super printOn: aStream].
	(joins at: aStream query resultClass) printSQLOn: aStream withParameters: aDictionary.
]

{ #category : #private }
VariableJoin >> privateGetOuterJoin [
	"The outer join state must be the same for all (or much additional thinking is needed).  This is checked in #validate."

	^self anyJoin privateGetOuterJoin
]

{ #category : #accessing }
VariableJoin >> queryLevelBaseExpression [
	^self ultimateBaseExpression.
]

{ #category : #preparing }
VariableJoin >> rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression [
	^(self joins at: aBaseExpression descriptor describedClass) 
		rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression
]

{ #category : #testing }
VariableJoin >> shortCircuitOnNullComparison: anIdentityDictionary [ 
	joins do: [:each |
		(each shortCircuitOnNullComparison: anIdentityDictionary)
			ifFalse: [^false]].
	^true.
]

{ #category : #preparing }
VariableJoin >> sourceForTarget: aDatabaseField ifNone: aBlock [
	"Our target fields vary but our source fields are the same;  any match will do"

	| eachSourceField |
	joins do:
		[:each |
		eachSourceField := each sourceForTarget: aDatabaseField ifNone: [nil].
		eachSourceField isNil ifFalse: [^eachSourceField]].
	^aBlock value
]

{ #category : #converting }
VariableJoin >> targetExpressionFor: eachTarget [ 
	^(self isConstant: eachTarget)
		ifTrue: [eachTarget]
		ifFalse: [eachTarget isGlorpExpression 
				ifTrue: [eachTarget asGlorpExpressionOn: self anyJoin base] 
				ifFalse: [(self anyJoin base getTable: eachTarget table) getField: eachTarget]].
]

{ #category : #preparing }
VariableJoin >> targetForSource: aField valueOfTargetField: aBlock [
	"Only evaluate the block if each of my joins includes aField as source field.  Since we may assume (see #allSourceFields) that variable joins vary in their targets, not in their sources, treat any nil target as meaning no match.  I rely on the value of the block being the target value of the join's mapping, and on the block's exiting if the target is an uninstantiated proxy and returning the value if it is instantiated."

	| targetsForSource |
	targetsForSource := self joins collect: [:each | each targetForSource: aField].
	^targetsForSource
		detect: [:each | each isNil]
		ifNone: [targetsForSource at: aBlock value class ifAbsent: [nil]]
]

{ #category : #accessing }
VariableJoin >> ultimateBaseExpression [

	^self anyJoin base.
]

{ #category : #testing }
VariableJoin >> validate [
	"The outer join state must be the same for all (or much additional thinking is needed)."

	| outerJoinState |
	outerJoinState := self privateGetOuterJoin.
	joins do:
		[:each |
		each validate.
		each privateGetOuterJoin = outerJoinState ifFalse:
			[self error: 'All the joins of a VariableJoin must have the same outer join value']].
]
