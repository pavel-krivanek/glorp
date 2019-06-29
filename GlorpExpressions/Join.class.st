"
This is a specialized variety of expression that is more constrained and is used for defining relationships. It has two main purposes
 - ease of construction: Relationships are normally defined by field to field equality expressions (my foreign key field = his primary key field). These are more tedious to create via block expressions, so this provides a simpler syntax.
 - constrained semantics. These define both read and write for the relationship, so fully general expressions won't work (most notably, relations other than equality are hard to write). Using a primaryKeyExpression ensures that we satisfy these constraints.

I'm not completely sure this class is a good idea. It makes for an annoying assymetry between different kinds of expressions. This is especially notable now that we allow sources to be constants. It's possible that all we need is an expression constructor that generates real expressions, but with more convenient syntax and ensuring that the constraints are met.

Note that although these are typically fk=pk, it's allowed to be the other way around -- i.e. our object-level relationships can be the opposite of the way the fk's ""point"" in the database.

Instance Variables:
	base	<BaseExpression>	The base on which we are built. Mostly used if we want to convert this into a real expression.
	outerJoin	<Boolean | nil>	If this is nil, we are an inner join.  If it is true we are a left outer join.  If it is false we are a right outer join.
	owningMapping	<RelationalMapping | nil>	The mapping whose join we are.
	sources	<SequenceableCollection of: (DatabaseField | ConstantExpression)> The source fields (typically the foreign keys)
	targets	<SequenceableCollection of: DatabaseField> The target fields (typically the targets of the foreign keys)


"
Class {
	#name : #Join,
	#superclass : #Object,
	#instVars : [
		'sources',
		'targets',
		'base',
		'outerJoin',
		'owningMapping'
	],
	#category : #'GlorpExpressions-Glorp'
}

{ #category : #'instance creation' }
Join class >> from: aField to: anotherField [

	^self new
		addSource: aField target: anotherField.
]

{ #category : #'instance creation' }
Join class >> from: from1Field to: to1Field
from: from2Field to: to2Field [

	^self new
		addSource: from1Field target: to1Field;
		addSource: from2Field target: to2Field.
]

{ #category : #'instance creation' }
Join class >> from: from1Field to: to1Field
from: from2Field to: to2Field
from: from3Field to: to3Field [

	^self new
		addSource: from1Field target: to1Field;
		addSource: from2Field target: to2Field;
		addSource: from3Field target: to3Field.
]

{ #category : #'instance creation' }
Join class >> from: from1Field to: to1Field
from: from2Field to: to2Field
from: from3Field to: to3Field
from: from4Field to: to4Field [

	^self new
		addSource: from1Field target: to1Field;
		addSource: from2Field target: to2Field;
		addSource: from3Field target: to3Field;		
		addSource: from4Field target: to4Field
]

{ #category : #'instance creation' }
Join class >> from: from1Field to: to1Field
from: from2Field to: to2Field
from: from3Field to: to3Field
from: from4Field to: to4Field
from: from5Field to: to5Field [

	^self new
		addSource: from1Field target: to1Field;
		addSource: from2Field target: to2Field;
		addSource: from3Field target: to3Field;		
		addSource: from4Field target: to4Field;
		addSource: from5Field target: to5Field.
]

{ #category : #'instance creation' }
Join class >> fromAll: sourceFields toAll: targetFields [

	^self new
		sourceFields: sourceFields targetFields: targetFields.
]

{ #category : #'instance creation' }
Join class >> new [

	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
Join class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #converting }
Join >> , aJoin [
	| newJoin |
	aJoin isNil ifTrue: [^self].
	aJoin == self ifTrue: [^self].
	newJoin := (self class fromAll: (sources, aJoin allSourceFields) toAll: (targets, aJoin targetKeys)) removeDuplicates.
	"If either one of the contributors is an outer join, make the result be an outer join"
	newJoin privateBeOuterJoin: outerJoin merge: aJoin privateGetOuterJoin.
	^newJoin
]

{ #category : #comparing }
Join >> = aJoin [
	aJoin class == self class ifFalse: [^false].
	aJoin allSourceFields = sources ifFalse: [^false].
	aJoin allTargetFields = targets ifFalse: [^false].
	^true.
]

{ #category : #preparing }
Join >> addToTargetFields: aCollection [
	"If we can provide target fields, add them to the collection"
	aCollection addAll: targets.
]

{ #category : #preparing }
Join >> additionalExpressions [
	^#()
]

{ #category : #preparing }
Join >> additionalExpressionsIn: aQuery [ 
	^#()
]

{ #category : #accessing }
Join >> allControlledTables [

	^self allTables.
]

{ #category : #accessing }
Join >> allSourceFields [

	^sources
]

{ #category : #accessing }
Join >> allTables [

	^(targets collect: [:each | each table]) asSet.
]

{ #category : #preparing }
Join >> allTablesToPrint [

	^targets inject: Set new into: [:sum :each | 
		sum add: each table. sum].
]

{ #category : #accessing }
Join >> allTargetFields [

	^targets
]

{ #category : #converting }
Join >> asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
	(customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	| sourceFieldExpression targetFieldExpression completeExpression relationExpression |
	completeExpression := EmptyExpression new base: base.
	sources with: targets do:
		[:sourceField :targetField | 
		sourceFieldExpression := source getFieldKnownNotToBeAName: sourceField.
		targetFieldExpression := target getFieldKnownNotToBeAName: targetField.
		relationExpression := sourceFieldExpression equals: targetFieldExpression.
		completeExpression := relationExpression AND: completeExpression].
	completeExpression privateBeOuterJoin: outerJoin.
	^completeExpression
]

{ #category : #converting }
Join >> asGeneralGlorpExpression [
	"Convert this to a 'normal' expression representing the same information (with source and target order reversed)."

	| main clause |
	main := EmptyExpression new base: base.
	sources with: targets do: 
		[:eachSource :eachTarget || srcExp targetExp |
		srcExp := self sourceExpressionFor: eachSource.
		targetExp := self targetExpressionFor: eachTarget.
		"Reverse the order: the source is the parameter and some DBs won't accept 27 = t1.primaryKey"
		clause := targetExp equals: srcExp.
		main := main AND: clause].
	"The far end of a left outer join is no outer join at all.  The far end of a right outer join is a left outer join."
	self isRightOuterJoin ifTrue: [main beOuterJoin].
	^main

"I do not know which databases still reject SQL like 27 = t1.primaryKey (Postgres 9 accepts it).  However current Glorp coding assumes this order reversal.  To make Glorp work without it, you must implement ParameterExpression>>mappedFields (easy) and then work out why that still leaves some things proxied that the tests expect to have been read.  Reversing the direction of any outer join to match the join expression's reversa is easier."
]

{ #category : #converting }
Join >> asGeneralGlorpExpressionWithFields [
	"The normal conversion of a join is to an expression equating fields and parameters. Instead, generate one with field to field comparisons.  Unlike #asGeneralGlorpExpression, this one has no need to invert the order of the source and target expressions, and so no need to invert its outer join if it has one."

	| main clause |
	main := EmptyExpression new base: base.
	sources with: targets do:
		[:eachSource :eachTarget || srcExp targetExp |
		srcExp := self targetExpressionFor: eachSource.
		targetExp := self targetExpressionFor: eachTarget.
		clause := srcExp equals: targetExp.
		main := main AND: clause].
	main privateBeOuterJoin: outerJoin.
	^main
]

{ #category : #api }
Join >> asGlorpExpression [

	^self.
]

{ #category : #api }
Join >> asGlorpExpressionForDescriptor: aDescriptor [

	base descriptor: aDescriptor.
]

{ #category : #api }
Join >> asGlorpExpressionOn: aBaseExpression [
	| copy |
	copy := self copy.
	copy base: aBaseExpression.
	copy privateBeOuterJoin: outerJoin.
	^copy
]

{ #category : #api }
Join >> asOuterJoin [
	"This has always been correctly implemented (see the comment in its polymorph MappingExpression>>asOuterJoin), but appears to have no callers, and no reason why it should not be inlined in any caller.  Unless callers appear, it will be renoved when its polymorph is removed."

	self deprecated: #(#version '8.2' #sunset '9.0' #use #beOuterJoin).
	^self copy beOuterJoin
]

{ #category : #accessing }
Join >> base [
	^base.
]

{ #category : #accessing }
Join >> base: aBaseExpression [
	base := aBaseExpression.
]

{ #category : #api }
Join >> beOuterJoin [
	"If you want the table you're joining to to be optional, this must be set."

	self privateBeOuterJoin: true.
]

{ #category : #api }
Join >> beRightOuterJoin [
	"If you want the table you're joining from to be optional, this must be set.  Only call this implementor when assigning a join to a read-only mapping - writing support is not yet fully developed."

	self privateBeOuterJoin: false.
]

{ #category : #iterating }
Join >> do: aBlock skipping: aSet [
	"Joins act as if they don't have children, and just evaluate for themselves"
	| |
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	aBlock value: self.
]

{ #category : #iterating }
Join >> fieldsDo: aBlock [

	sources with: targets do: aBlock.
]

{ #category : #accessing }
Join >> from: aField to: anotherField [

	^self addSource: aField target: anotherField.
]

{ #category : #converting }
Join >> generalExpressionPart [
	^nil.
]

{ #category : #accessing }
Join >> hasDescriptor [

	^false.
]

{ #category : #initialize }
Join >> initialize [
	sources := OrderedCollection new: 2.
	targets := OrderedCollection new: 2.
	base := BaseExpression new.
]

{ #category : #converting }
Join >> inverseJoin [
	| inverse |
	inverse := self class new
		base: base;
		sourceFields: targets
		targetFields: sources.
	inverse owningMapping: self owningMapping.
	^inverse.
]

{ #category : #converting }
Join >> isConstant: aTarget [
	"The target can be either a constant (which gets turned into a ConstantExpression) or (usually) a DatabaseField, representing a parameter to the query.  However it could be a subselect (which would return false)."

	(aTarget class == DatabaseField) ifTrue: [^false].
	^aTarget isGlorpExpression not
		or: [aTarget isConstantExpression]
]

{ #category : #testing }
Join >> isEmptyExpression [
	^sources isEmpty.
]

{ #category : #testing }
Join >> isGlorpExpression [
	^true.
]

{ #category : #testing }
Join >> isJoin [
	^true.
]

{ #category : #testing }
Join >> isOuterJoin [
	^outerJoin notNil
]

{ #category : #converting }
Join >> isRightOuterJoin [
	^self isOuterJoin and: [outerJoin not]
]

{ #category : #iterating }
Join >> mappableFieldsDo: aBlock [

	sources with: targets do: [:source :target |
		source isMappable ifTrue: [aBlock value: source value: target]].
]

{ #category : #iterating }
Join >> mappableSourceFieldsDo: aBlock [

	sources do: [:source  |
		source isMappable ifTrue: [aBlock value: source]].
]

{ #category : #accessing }
Join >> numberOfParameters [
	^sources size
]

{ #category : #preparing }
Join >> onlyJoinParts [
	"Strip out any generic parts, leaving only the things that are actually joins"
	
	^self.
]

{ #category : #debugging }
Join >> owningMapping [
	"Return the mapping (if there is one) that is responsible for. Not needed for the code, but might be a useful debugging aid if trying to figure out where a @#%#@% join came from"
	^owningMapping.
]

{ #category : #debugging }
Join >> owningMapping: aMapping [
	owningMapping := aMapping.
]

{ #category : #preparing }
Join >> prepareIn: aQuery [
	"The whereClause is a Join.  Convert it to an expression and prepare that expression.  (The assumption is that this implementor is only ever reached by #prepareIn: being sent to a 'whereClause' that contains a join)."

	aQuery whereClause: self asGeneralGlorpExpression.
	aQuery whereClause prepareIn: aQuery.

"Is it always the case that after calling the above,
	aQuery shouldExpressionBeJoin: aQuery whereClause.
will inevitably return true?  If so, should the above instead be
	aQuery addJoin: self asGeneralGlorpExpression.
so that platforms that only support ANSI outer joins will handle it correctly."
]

{ #category : #'primary keys' }
Join >> primaryKeyFromDictionary: aDictionary [
	"Given a set of parameters, return a primary key suitable for retrieving our target. Return either a value for the key, nil for no key found, or an array for compound keys."
	
	sources size = 1 ifTrue: [^aDictionary at: sources first ifAbsent: [nil]].
	^sources collect: [:each | aDictionary at: each ifAbsent: [nil]].
]

{ #category : #printing }
Join >> printOn: aStream [

	sources with: targets do: [:source :target |
		aStream nextPut: $(.
		source printSQLOn: aStream withParameters: #().
		aStream nextPutAll: ' = '.
		target printSQLOn: aStream withParameters: #().
		aStream nextPutAll: ') ']
]

{ #category : #printing }
Join >> printSQLOn: aStream withParameters: aDictionary [ 
	1 to: sources size
		do: 
			[:i | 
			| eachTarget eachSource sourceValue |
			eachTarget := targets at: i.
			eachSource := sources at: i.
			eachTarget printSQLOn: aStream withParameters: aDictionary.
			sourceValue := (self isConstant: eachSource) ifTrue: [eachSource value] ifFalse: [aDictionary at: eachSource].
			sourceValue isNil 
				ifTrue: [aStream nextPutAll: ' IS NULL ']
				ifFalse: 
					[aStream nextPutAll: ' = '.
					sourceValue printOn: aStream].
			i = targets size ifFalse: [aStream nextPutAll: ' AND ']]
]

{ #category : #accessing }
Join >> privateBeOuterJoin: anOuterJoin [
	"NEVER use this method when defining joins in your descriptor systems;  always use paramaterless #beOuterJoin and similar API methods.  Before version 8.3.1, Glorp only supported inner joins and the setting was a boolean.  It then changed to a boolean or nil, and what false meant also changed.  It may evolve further."

	outerJoin := anOuterJoin.
]

{ #category : #accessing }
Join >> privateBeOuterJoin: anOuterJoin merge: anotherOuterJoin [
	"At the moment we only support left and right outer joins.  If both are non-nil, they had better be equal.  (Later, I guess left + right = cross-join.)"

	anotherOuterJoin isNil ifTrue: [^outerJoin := anOuterJoin].
	anOuterJoin isNil ifTrue: [^outerJoin := anotherOuterJoin].
	^anOuterJoin = anotherOuterJoin
		ifTrue: [outerJoin := anOuterJoin]
		ifFalse: [self error: 'Even if a left and right outer join should be merged as a cross-join, we do not support that yet']
]

{ #category : #private }
Join >> privateGetOuterJoin [
	^outerJoin
]

{ #category : #accessing }
Join >> queryLevelBaseExpression [
	^self ultimateBaseExpression.
]

{ #category : #converting }
Join >> rebuildOn: aGlorpMappingExpression [ 
	^self asGlorpExpressionOn: aGlorpMappingExpression.
]

{ #category : #preparing }
Join >> rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression [
	^self asGlorpExpressionOn: aBaseExpression.
]

{ #category : #converting }
Join >> removeDuplicates [
	| existing newSources newTargets |
	existing := Set new.
	newSources := OrderedCollection new: sources size.
	newTargets := OrderedCollection new: targets size.
	sources
		with: targets
		do:
			[:eachSource :eachTarget | 
			| association |
			association := eachSource -> eachTarget.
			(existing includes: association)
				ifFalse:
					[existing add: association.
					newSources add: eachSource.
					newTargets add: eachTarget]].
	sources := newSources.
	targets := newTargets.
]

{ #category : #preparing }
Join >> removeNonJoinParts [
	"Remove anything that's not an actual join. Only useful if we have something that has mixed joins and general expressions, where we assume we don't want to use the general ones, because they're not field level."
	^self.
]

{ #category : #preparing }
Join >> replaceJoinsWithInverse [
	"Replace any actual Join objects we have with their inverse. Only useful if we have something that has mixed joins and general expressions, where we assume we don't want to mess with the general ones, because they're not field-level. As actual joins, we ignore this, because it will be done at the parent level"
	^self.
]

{ #category : #converting }
Join >> replacing: aTable withEquivalenceFrom: aJoin [
	"Create a new join by sliding my sources along the source-to-target lines of aJoin.  Each of my sources that uses fields in aTable is replaced with that source's target in aJoin (any others get discarded).  The code assumes that aTable references are in the sources of aJoin (the caller can send #inverseJoin to the parameter if polarity is reversed)."

	| newSources newTargets newSource |
	newSources := OrderedCollection new.
	newTargets := OrderedCollection new.
	self fieldsDo:	"do not guard eachSource isGlorpExpression but instead assume expression understands #table"
		[:eachSource :eachTarget |
		eachSource table = aTable ifTrue:
			[newSource := aJoin targetForSource: eachSource.
			newSource isNil ifFalse:
				[newSources add: newSource.
				newTargets add: eachTarget]]].
	^self class fromAll: newSources toAll: newTargets

"If not one valid source is found, this will uncomplainingly return an empty join (almost certainly indicating a mistaken call that will cause errors later)."
]

{ #category : #testing }
Join >> shortCircuitOnNullComparison: parameters [
	"Return true if we represent an expression that compares null to a non-nullable value (in any of our clauses), so we don't ever need to really evaluate it"

	self fieldsDo: [:source :target |
		(target isNullable not and: [(parameters at: source) isNil]) ifTrue: [^true]].
	^false.
]

{ #category : #converting }
Join >> sourceExpressionFor: source [
	"The source might be a subselect, hence the isMappable check."

	^((self isConstant: source) or: [source isMappable not])
		ifTrue: [source asGlorpExpressionOn: base]
		ifFalse: [base getParameter: source]
]

{ #category : #initialize }
Join >> sourceFields: sourceFields targetFields: targetFields [
	sources := sourceFields.
	targets := targetFields.
]

{ #category : #preparing }
Join >> sourceForTarget: aField ifNone: aBlock [
	| index |
	index := targets indexOf: aField.
	index = 0 ifTrue: [^aBlock value].
	^sources at: index
]

{ #category : #converting }
Join >> targetExpressionFor: eachTarget [
	^(self isConstant: eachTarget)
		ifTrue: [eachTarget]
		ifFalse: [eachTarget isGlorpExpression
				ifTrue: [eachTarget asGlorpExpressionOn: base]
				ifFalse: [(base getTable: eachTarget table) getField: eachTarget]].
]

{ #category : #preparing }
Join >> targetForSource: aField [

	| index |
	index := sources indexOf: aField.
	index = 0 ifTrue: [^nil].
	^targets at: index.
]

{ #category : #preparing }
Join >> targetForSource: aField valueOfTargetField: aBlock [
	"Only evaluate the block if this join includes aField as source field.  My polymorph in VariableJoin relies on the value of the block being the target value of the join's mapping."

	| index |
	index := sources indexOf: aField.
	index = 0 ifTrue: [^nil].
	aBlock value.
	^targets at: index
]

{ #category : #accessing }
Join >> targetKeys [

	^targets.
]

{ #category : #accessing }
Join >> ultimateBaseExpression [

	^base ultimateBaseExpression.
]

{ #category : #validation }
Join >> validate [
	sources asSet size = sources size ifFalse:
		[self error: 'The same field occurs twice in the join. This might be legal, but is probably a cut and paste error.'].
	targets asSet size = targets size ifFalse:
		[self error: 'The same field occurs twice in the join. This might be legal, but is probably a cut and paste error.'].
]
