"
AdHocMapping is a configurable sort of mapping, done via two blocks. It's not easy to use, but gives you very direct access to the underlying mechanisms, so it should be possible to write mappings that are otherwise very complicated or impossible.

Instance Variables:
	fromDbMappingBlock	<BlockClosure>	The block we invoke when reading from the database. It's given arguments of the ""row"" we got from the database (note that this doesn't necessarily correspond to a single row, but is all the fields we selected in the query) , the elementBuilder associated with our containing object, and the ""context"", the expression from the query for what we're reading from the database. Typical usage is to use the context to translate a field into the appropriate aliased field from the query, and use the element builder to get the value of that field. e.g. elementBuilder valueOfField: (context translateField: someField) in: row
	mappedFields	<SequenceableCollection of: DatabaseField>	The list of fields we work with. We need to specify this so that Glorp knows that it needs to e.g. includes these fields in the list of those selected.  The list also limits which descriptor tables this mapping will find or add rows to, to provide to the toDbMappingBlock.
	shouldProxy	<Boolean>	Should we create a proxy for our target objects when we read an object containing this mapping.
	toDbMappingBlock	<BlockClosure>	The block we invoke when writing to the database. It takes as arguments
			- any source object rows that include our mapped fields
			- the target object we are writing
			- any target object rows that include our mapped fields
 		(of course, there will be no target rows if our target is a simple object and so has no descriptor).  The block is expected to update the rowmap with the new information.


"
Class {
	#name : #AdHocMapping,
	#superclass : #Mapping,
	#instVars : [
		'fromDbMappingBlock',
		'toDbMappingBlock',
		'mappedFields',
		'shouldProxy'
	],
	#category : #'GlorpMappings-Glorp'
}

{ #category : #'instance creation' }
AdHocMapping class >> forAttribute: aSymbol fromDb: fromBlock toDb: toBlock mappingFields: aFieldCollection [ 
	^super new 
		setAttribute: aSymbol
		fromDb: fromBlock
		toDb: toBlock
		mappingFields: aFieldCollection
]

{ #category : #'VisualWorks metadata' }
AdHocMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'printing SQL' }
AdHocMapping >> allRelationsFor: rootExpression [
	"Create a dummy row for each table and construct the relationship expression(s) that would exist if this were a regular mapping.  The returned result is necessarily a RelationExpression or subclass."

	| tables rows result rightChild rightHandSide |
	tables := self mappedTables.
	rows := Dictionary new.
	tables do: [:each | rows at: each put: (DatabaseRow newForTable: each)].
	rightChild := rootExpression rightChild.
	rightHandSide := rightChild isConstantExpression ifTrue: [rightChild value] ifFalse: [rightChild].
	toDbMappingBlock value: rows value: rightHandSide value: Dictionary new. 
	result := nil.
	rows do:
		[:eachRow || table |
		table := rootExpression leftChild base getTable: eachRow table.
		eachRow fieldsAndValidValuesDo:
			[:eachField :eachValue || newExp |
			newExp := (table getField: eachField) get: rootExpression relation withArguments: (Array with: eachValue).
			result := newExp AND: result]].
	^result
]

{ #category : #testing }
AdHocMapping >> controlsTables [
	^false
]

{ #category : #'printing SQL' }
AdHocMapping >> convertedDbValueOf: anObject [
	| tables rows |
	tables := self mappedTables.
	rows := Dictionary new.
	tables do: [:each | rows at: each put: (DatabaseRow newForTable: each)].
	toDbMappingBlock value: rows value: anObject.
	rows keysAndValuesDo: [:eachTable :eachRow |
		^eachRow at: mappedFields first].
]

{ #category : #mapping }
AdHocMapping >> field [
	| fields |
	fields := self mappedFields.
	fields size = 1 ifFalse: [self error: 'This mapping does not correspond to exactly one field'].
	^fields first.
]

{ #category : #'initialize-release' }
AdHocMapping >> forAttribute: aSymbol fromDb: fromBlock toDb: toBlock mappingFields: aFieldCollection [
	self
		setAttribute: aSymbol
		fromDb: fromBlock
		toDb: toBlock
		mappingFields: aFieldCollection.
]

{ #category : #testing }
AdHocMapping >> hasImpliedClauses [
	"We may imply more than one clause, or a clause which is different from the one directly implied by the relationship"
	^true
]

{ #category : #'initialize-release' }
AdHocMapping >> initialize [
	"Proxying requires the user to think about any possible state changes in the element builder or context between the creation and the evaluation of the AdHocProxy block."

	super initialize.
	shouldProxy := false.
]

{ #category : #testing }
AdHocMapping >> isRelationship [
	"True when the mapping associates different persistent classes."

	^false
]

{ #category : #testing }
AdHocMapping >> isStoredInSameTable [
	^true.
]

{ #category : #public }
AdHocMapping >> mapFromObject: anObject intoRowsIn: aRowMap [
	"To avoid creating needless rows for tables that are uninvolved in this mapping and that may not be written for anObject (e.g. if related to via outer joins or ConditionalMappings), assume that we will have at least one mapped field in each table whose rows we write to (or even merely read-from in the toDbMappingBlock, e.g. to compute what to write in other fields or to unify from it)."

	| target sourceRows targetRows valueDescriptor myMappedTables |
	self canWrite ifFalse: [^self].
	target := self getValueFrom: anObject.
	target := self session realObjectFor: target.
	target := aRowMap mementoFor: target.
	sourceRows := Dictionary new: 3.
	targetRows := Dictionary new: 3.
	myMappedTables := self mappedTables.
	(myMappedTables select: [:each | descriptor tables includes: each]) do:
		[:each | sourceRows at: each put: (aRowMap findOrAddRowForTable: each withKey: anObject)].
	valueDescriptor := self system descriptorFor: target.
	valueDescriptor isNil ifFalse:
		[(myMappedTables select: [:each | valueDescriptor tables includes: each]) do:
			[:each | targetRows at: each put: (aRowMap findOrAddRowForTable: each withKey: target)]].
	toDbMappingBlock value: sourceRows value: target value: targetRows.
]

{ #category : #public }
AdHocMapping >> mapObject: anObject inElementBuilder: anElementBuilder [
	"Because anElementBuilder could be assigned another row between the setting of my proxy's block and the evaluation of that block, we extract the row here and pass it into the block separately, even though anElementBuilder (which we also pass in) knows the row at the moment.  Code in the fromDbMappingBlock may find it prudent to call protocol that uses the supplied row instead of obtaining it from anElementBuilder - see #descriptorForGlorpTransformedTime: and #testReadAdHocProxied for an example.  (Of course, if we are not proxying, it makes no difference.)"

	| row |
	row := anElementBuilder row.
	^self setValueIn: anObject to:
		(self shouldProxy
			ifFalse: [fromDbMappingBlock value: row value: anElementBuilder value: BaseExpression new]
			ifTrue: [AdHocProxy readBlock: [fromDbMappingBlock value: row value: anElementBuilder value: BaseExpression new]])
]

{ #category : #mapping }
AdHocMapping >> mappedFields [

	^mappedFields.
]

{ #category : #mapping }
AdHocMapping >> referencedIndependentObjectsFrom: anObject [
	"Assumes that the only object this might affect is our primary attribute. That's probably valid. I think."
	| object otherDescriptor |
	object := self getValueFrom: anObject.
	(object isGlorpProxy and: [object isInstantiated not]) ifTrue: [^#()].
	otherDescriptor := self system descriptorFor: object.
	^otherDescriptor isNil ifTrue: [#()] ifFalse: [Array with: object].
]

{ #category : #'initialize-release' }
AdHocMapping >> setAttribute: aSymbol fromDb: fromBlock toDb: toBlock mappingFields: aFieldCollection [
 
	self attributeName: aSymbol.
	fromDbMappingBlock := fromBlock.
	toDbMappingBlock := toBlock.
	mappedFields := aFieldCollection.
]

{ #category : #accessing }
AdHocMapping >> shouldProxy [

	^shouldProxy.
]

{ #category : #accessing }
AdHocMapping >> shouldProxy: aBoolean [

	shouldProxy := aBoolean.
]

{ #category : #mapping }
AdHocMapping >> trace: aTracing context: anExpression [
	^self.
]

{ #category : #mapping }
AdHocMapping >> valueIn: anElementBuilder as: anExpression [
	^fromDbMappingBlock
		value: anElementBuilder row
		value: anElementBuilder
		value: anExpression.
]
