"
This allows us to map a dictionary into tables. It should, I hope, support arbitrarily either mapping to single fields, or to objects, for either the key or the value. At the moment, it at least passes the tests for the value->object and value->value cases.

Instance Variables:
	keyMapping	<DatabaseMapping>	The mapping to use to read/write the key. It should be for an attribute named #key.
	valueMapping	<DatabaseMapping>	The mapping to use to read/write the value. It should be for an attribute named #value. Note that this is optional, and isn't a full blown mapping, because if we have a relationship, we will normally just use this mapping to describe it directly. If we have a direct mapping for the value, then we have this odd situation where we use the Join from this mapping, but the direct mapping to control the read/write of the variable.
	associationDescriptor	<Descriptor>	We manipulate the key/value pairs as associations in some places, and have a mock descriptor for association, specific to this mapping, which is used to get the key/value.



"
Class {
	#name : #DictionaryMapping,
	#superclass : #ToManyMapping,
	#instVars : [
		'keyMapping',
		'valueMapping',
		'associationDescriptor'
	],
	#category : #GlorpMappings
}

{ #category : #'VisualWorks metadata' }
DictionaryMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #mapping }
DictionaryMapping >> associationClassModel [
	| model |
	model := GlorpClassModel for: Association.
	model newAttributeNamed: #key.
	model newAttributeNamed: #value.
	^model.
]

{ #category : #mapping }
DictionaryMapping >> associationDescriptor [
	associationDescriptor isNil ifTrue: [
		associationDescriptor := Descriptor new.
		associationDescriptor system: self system.
		associationDescriptor classModel: self associationClassModel.
		associationDescriptor classModel system: self system].
	^associationDescriptor.
]

{ #category : #accessing }
DictionaryMapping >> basicReferenceDescriptor [
	^self system descriptorFor: self basicReferenceClass.
]

{ #category : #mapping }
DictionaryMapping >> buildQuery [
	| keyExpression valueExpression refDescKeyMapping notAddedByKeyMapping |
	query := super buildQuery.
	keyExpression := self keyExpression.
	valueExpression := self valueExpression.
	query retrieveDictionaryWithKey: keyExpression value: valueExpression.
	"Do we have enough information from the value mapping to get rows from which extracting the key merely requires adding to the list of fields selected from the existing tables (if that)? ..."
	self keyMapping controlsTables ifFalse: [^query].	"a direct mapping will not control tables"
	(self descriptor tables includes: self keyMapping mappedFields first table)
		ifTrue: [^query].
	(self usesLinkTable and: [self join allTables includes: self keyMapping mappedFields first table])
		 ifTrue: [^query].
	"... If we get here, the answer is no:  the user has defined a keyMapping that controls tables, i.e. they don't think the overall descriptor already controls all necessary tables (or they forgot to change the value from true - its default - to for-this-case false).  Our key mapping is acting like a second link table:  it must have a join from the key (which is otherwise outside the zone of this descriptor) to the value.  As the keyMapping's join is from the key to the value, we do not need to reverse it (i.e. as is done in expressionFromLinkToReferenceTableWithBase which otherwise guided the code below).  Trivially, we initialize to non-nil (empty) all existing experessions' tableAliases, so we can see which ones are still nil after we extend the where clause, and so are the ones added by the key mapping.  We share aliases from the key mapping to all such added expressions, so ensuring the key part of the expression will sync with the main query's value part of the expression."
	notAddedByKeyMapping := query baseExpression mappingExpressions values.	"values makes a copy - we must copy"
	"An alternative to the ANDs below could be to AND
		(self referenceDescriptor mappingForAttributeNamed: #key) buildQuery whereClause
	along with replacing the parameter element in the above whereClause with the main query's join element(s) for the value's primaryKey."
	refDescKeyMapping := self referenceDescriptor mappingForAttributeNamed: #key.
	query AND:
		(refDescKeyMapping join asGlorpExpressionOn: query baseExpression) asGeneralGlorpExpressionWithFields.
	refDescKeyMapping usesLinkTable ifTrue:
		[query AND:
			(refDescKeyMapping expressionFromLinkToReferenceTableWithBase: query baseExpression)].
	"Initialize the the keyExpression table alias dictionary, then initialize the expressions it added to use the same instance."
	keyExpression tableAliases isNil ifTrue:
		[keyExpression privateTableAliases: (IdentityDictionary new: 3)].
	query baseExpression mappingExpressions do:
		[:each |
		(notAddedByKeyMapping includes: each) ifFalse:
			[each privateTableAliases: keyExpression tableAliases]].
	^query
]

{ #category : #mapping }
DictionaryMapping >> buildRowMapKeyForSource: source target: target index: index [
	^self mapsSimpleObject 
		ifTrue: [
			MultipleRowMapKey
				with: target yourSelf
				with: source yourSelf
				with: index]
		ifFalse: [super buildRowMapKeyForSource: source target: target index: index].
]

{ #category : #mapping }
DictionaryMapping >> chooseBaseForMapping: aMapping from: base and: phantomExpression [
	aMapping isNil ifTrue: [^base].
	^(aMapping mappedFields
		allSatisfy: [:each | base tables includes: each table])
		ifTrue: [base]
		ifFalse: [phantomExpression].
]

{ #category : #initializing }
DictionaryMapping >> defaultCollectionType [
	^Dictionary.
]

{ #category : #accessing }
DictionaryMapping >> field [
	^self valueField.
]

{ #category : #testing }
DictionaryMapping >> glorpCanHaveDescriptorDirectly [
	"We allow instances of ourselves to have a descriptor, which normally only classes can do. This is so that we can have multiple different descriptors in use for e.g. String, depending on the particular usage."
"	^self mapsSimpleObject."
	^true.
]

{ #category : #initializing }
DictionaryMapping >> initialize [
	super initialize.
	usesLinkTable := true.
]

{ #category : #initializing }
DictionaryMapping >> initializeKeyMappingJoin [
	self keyMapping mapsSimpleObject
		ifTrue: [self referenceDescriptor directMapping
				from: #key to: self keyField]
		ifFalse: [self referenceDescriptor oneToOneMapping
				attributeName: #key;	
				linkFields: self keyMapping linkFields;
				usesLinkTable: self keyMapping usesLinkTable;
				join: self keyMapping join;
				controlsTables: self keyMapping controlsTables].
]

{ #category : #validation }
DictionaryMapping >> initializeRuntimeMappings [
	super initializeRuntimeMappings.
	self initializeValueMapping.
]

{ #category : #initializing }
DictionaryMapping >> initializeValueMapping [
	| referenceDescriptor |
	self descriptor system privateAndBasicAddDescriptorFor: self as: self associationDescriptor.
	(self associationDescriptor classModel attributeNamed: #key) type: self attribute keyType.
	(self associationDescriptor classModel attributeNamed: #value) type: self attribute type.
	referenceDescriptor := self referenceDescriptor.
	(referenceDescriptor isNil or: [referenceDescriptor tables isEmpty]) ifTrue:
		[self initializeValueMappingJoin.
		self initializeKeyMappingJoin].
]

{ #category : #initializing }
DictionaryMapping >> initializeValueMappingJoin [
	| tables |
	"We don't know which of these will come first in the descriptor, so call the other initialization if it looks like we have enough information, and it hasn't been done"
	self referenceDescriptor isNil ifTrue: [self initializeValueMapping].
	"Have we already done this?"
	self referenceDescriptor tables isEmpty ifFalse: [^self].
	tables := self targetTables asArray.
	tables do: [:each | self referenceDescriptor addTable: each].
	self mapsSimpleObject
		ifTrue: [self referenceDescriptor directMapping
				from: #value to: self valueField]
		ifFalse: [self referenceDescriptor oneToOneMapping
				attributeName: #value;
				linkFields: self linkFields;
				usesLinkTable: self usesLinkTable;
				join: self join;
				controlsTables: false].
]

{ #category : #mapping }
DictionaryMapping >> keyExpression [
	"Return the expression to use for our key. In a prior version, the key could be built only using data from either the target object, or from the link table, so we built a fresh expression on one or the other, as appropriate, ignoring the fact that the base expression (for the association descriptor) already had a key mapping.  In this version, we get it from the base expression, since the mapping may be to a third table that joins to the value table.  For hierarchy/type resolver situations (the outer ifTrue: branch), we continue to use the old code."
	
	^(query isNil
		ifFalse: [query baseExpression]		"base(associationDescriptor) already has the mapping"
		ifTrue:						"see call of #setGeneralQueryRetrievalIn:basedOn:phantom:"
			[| base | base := BaseExpression new.
			(self descriptor tables includes: self keyMapping mappedFields first table)
				ifTrue: [base] 
				ifFalse: [base getTable: keyMapping mappedFields first table]])
		getMapping: self keyMapping named: #key
]

{ #category : #accessing }
DictionaryMapping >> keyField [
	^keyMapping field.
]

{ #category : #accessing }
DictionaryMapping >> keyField: aDatabaseField [
	keyMapping := self newMapping: DirectMapping.
	keyMapping attributeName: #key.
	keyMapping from: #key to: aDatabaseField.
]

{ #category : #accessing }
DictionaryMapping >> keyMapping [
	^keyMapping
]

{ #category : #accessing }
DictionaryMapping >> keyMapping: aMapping [
	keyMapping := aMapping
]

{ #category : #accessing }
DictionaryMapping >> mappedFields [
	"Return a collection of fields that this mapping will write into any of the containing object's rows"

	| fields |
	fields := super mappedFields copy.
	fields addAll: keyMapping mappedFields.
	valueMapping isNil ifFalse: [
		fields addAll: valueMapping mappedFields].
	^fields.
]

{ #category : #testing }
DictionaryMapping >> mapsSimpleObject [
	^valueMapping notNil and: [valueMapping mapsSimpleObject].
]

{ #category : #accessing }
DictionaryMapping >> name [
	"This can get called when we're masquerading as a class, for purposes of indexing descriptors, so just print something useful."

	^self printString
]

{ #category : #testing }
DictionaryMapping >> needsSpecialRowMapKey [
	^super needsSpecialRowMapKey or: [
		self mapsSimpleObject].
]

{ #category : #mapping }
DictionaryMapping >> newMapping: aMappingClass [
	"Implement this so that we can create our sub-mappings without having them added to the parent descriptor as independent mappings"
	| mapping |
	mapping := aMappingClass new.
	mapping descriptor: self associationDescriptor.
	descriptor resetMappedFields.
	^mapping.
]

{ #category : #mapping }
DictionaryMapping >> pseudoDescriptor [
	"Return a pretend descriptor for our reference class. Since that class is a primitive, it won't have a real descriptor, and it may vary by usage anyway"
	| pseudoDescriptor |
	pseudoDescriptor := Descriptor new.
	pseudoDescriptor system: descriptor system.
	^pseudoDescriptor.
]

{ #category : #accessing }
DictionaryMapping >> referenceClass [
	"Return ourselves as the reference class, as a sort of a proxy for what we really want, which is a primitive, and varies according to the relationship anyway. Note that we have stuffed in a descriptor in the system, with ourselves (this instance) as the class."
"	^self mapsSimpleObject ifTrue: [self] ifFalse: [super referenceClass]."
	^self.
]

{ #category : #accessing }
DictionaryMapping >> referenceDescriptor [
	| ref |
	ref := super referenceDescriptor.
	^ref isNil 
		ifTrue: [
			"This means we haven't yet added our fake descriptor, and are in initialization, so just return the descriptor for the 'real' reference class"
			self system descriptorFor: self basicReferenceClass]
		ifFalse: [ref].
]

{ #category : #mapping }
DictionaryMapping >> setGeneralQueryRetrievalIn: newQuery basedOn: base phantom: phantomExpression [
	| keyExpression valueExpression collType keyExpressionBase valueExpressionBase |
	self descriptor primaryKeyMappings
		do:
			[:eachMapping | newQuery retrieve: (phantomExpression get: eachMapping attributeName)].
	keyExpressionBase := self
		chooseBaseForMapping: keyMapping
		from: base
		and: phantomExpression.
	keyExpression := self keyExpression asGlorpExpressionOn: keyExpressionBase.
	valueExpressionBase := self
		chooseBaseForMapping: valueMapping
		from: base
		and: phantomExpression.
	valueExpression := self valueExpression
		asGlorpExpressionOn: valueExpressionBase.
	collType := (GlorpDictionaryDescription new)
		keyExpression: keyExpression;
		valueExpression: valueExpression.
	newQuery collectionType: collType.
	newQuery retrieve: base.
]

{ #category : #validation }
DictionaryMapping >> validate [
	self initializeValueMapping.
	super validate.
	self attribute isDictionaryAttribute
		ifFalse: [self error: 'Dictionary Mapping that does not have a dictionary type in the attribute'].

	"The reason you can't do this, is that we end up throwing away the primary key of the target table when we read in the objects, and we have no way to properly do deletes/updates without that information"
	(self usesLinkTable and: [self mapsSimpleObject]) ifTrue: [self error: 'Dictionary mappings to simple objects cannot use a link table'].
]

{ #category : #mapping }
DictionaryMapping >> valueExpression [
	 | base intermediate |
	valueMapping isNil ifTrue: [ ^[:each | each value] ].
	base := BaseExpression new.
	intermediate := (self descriptor tables includes: valueMapping mappedFields first table)
		ifTrue: [base] 
		ifFalse: [base getTable: valueMapping mappedFields first table].
	^intermediate getMapping: valueMapping named: #value.
]

{ #category : #accessing }
DictionaryMapping >> valueField [
	^valueMapping field.
]

{ #category : #accessing }
DictionaryMapping >> valueField: aDatabaseField [
	| mapping |
	mapping := self newMapping: DirectMapping.
	mapping attributeName: #value.
	mapping from: #value to: aDatabaseField.
	self valueMapping: mapping.
]

{ #category : #accessing }
DictionaryMapping >> valueMapping [
	^valueMapping.
]

{ #category : #accessing }
DictionaryMapping >> valueMapping: aMapping [
	valueMapping := aMapping.
]

{ #category : #mapping }
DictionaryMapping >> writeExtraInformationInto: aRowMap atKey: rowMapKey forSourceObject: sourceObject targetObject: targetObject atIndex: eachKey [
	"A dictionary association has an owner (the sourceObject) plus a key (the eachKey parameter, sometimes called the index) one-one-related to a value (the targetObject).  The owner and value have already been mapped to rows by the time we get here.  For the key, write out any additional information that goes in the value's link table or else the target table, or in other key-specific table(s) and linkTable(s), if necessary. If we have a specific value mapping, rather than just using the normal attributes of this mapping, then write any necessary information for it as well (usually, we only have a value mapping when our value is simple).
	* If the key mapping is in the scope of the value mapping (i.e. we're just putting into a dictionary some data we already have from the owner, link and value tables) then the key mapping writes to the link table or to the (value's) target table(s).
		- If it writes to the link table, then myTarget within this method is the row map key (as usual - rowMapKeys are used to target rows for linkTables).  If it does not, but the value is simple, we still use the rowMapKey.
		- If the value is mapped to table(s) then the key is either mapped to one or more of them, in which case the value is myTarget within this method, or it isn't (rowMapConstructorBlock being used?).
	* If the key mapping is outside the scope of owner, link and value, then it may write to entirely separate table(s) joined from the value.  In that case, the value is mySource and the key is myTarget."

	| myTarget mySource |
	keyMapping controlsTables
		ifFalse:	"key is in scope of existing owner -> dict -> value tables and link table"
			[mySource := eachKey -> nil.
			myTarget := (keyMapping mappedTables includes: self linkTable)	"the key is mapped to the link table"
				ifTrue: [rowMapKey]
				ifFalse: [self mapsSimpleObject		"the key is mapped to the value"
						ifTrue: [rowMapKey]			" - which is simple, no table(s)"
						ifFalse:					" - which has table(s) ..."
							[(keyMapping mappedTables anySatisfy: [:each | self targetTables includes: each])
								ifTrue: [targetObject]	"... to which the key is mapped"
								ifFalse: [eachKey]]]]		"... but the key is not mapped to them (key is computed in rowMapKeyConstructorBlock?)"
		ifTrue:	"the key is mapped to table(s) beyond the scope of the non-key part of this mapping"
			[mySource := targetObject.	"the value is the source of the key mapping"
			myTarget := eachKey].		"the key is the target of the mapping"
	keyMapping
		mapFromObject: mySource
		toTarget: myTarget
		puttingRowsIn: aRowMap.

	valueMapping isNil ifTrue: [^self].
	"I'm not sure this will ever be relevant.  If the value mapping goes to the link table, then does that mean the key is really the value?  And if so, why not just consider the other one to be the link?  If we do get here, be aware myTarget is now my value mapping's target whereas above it was my key mapping's target."
	myTarget := (valueMapping mappedTables includes: self linkTable)
		ifTrue: [rowMapKey]
		ifFalse: [self mapsSimpleObject ifTrue: [rowMapKey] ifFalse: [targetObject]].
	valueMapping
		mapFromObject: nil -> targetObject
		toTarget: myTarget
		puttingRowsIn: aRowMap.
]
