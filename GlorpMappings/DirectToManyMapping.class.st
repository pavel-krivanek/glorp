"
This is a to-many mapping where the target class is a simple type, not a compound object. This was created as a prototype in early Glorp (it seemed to work, at least for basic operations, but was little tested or used, so could well have had problems).  It was developed further and more widely used in Glorp 8.3.1 and after.

The ordinary way to map a simple type directly to a field that is not in a descriptor's main table is to give the owning descriptor a multipleTableJoin between its main table and the field's table.  A DirectMapping from an instar in the owning object to a field in the target table can then be defined, exactly as if it were to a field in the main table.  The join can be an outer join if not all instances of the describedClass.  However this is necessarily one-to-one;  the owning object is built from one row in each of the tables.  Thus we provide this class to map a collection (whose contents are of simple type) directly to a field, being written in zero, one or more rows of its table.

When given its join, it creates a pseudoDescriptor, keyed by itself (it returns true to #glorpCanHaveDescriptorDirectly), that holds a single direct mapping (whose name #myValue is hardcoded) and a class model (also unique to this mapping) for its target class.  This allows each such mapping to define a different descriptor for its target class, since the target class, being simple, could well also be the target class of another such mapping in the same system, or they key or value of a dictionary mapping.

Instance Variables:
	resultField	<DatabaseField>	The field in the target table to which we map.
"
Class {
	#name : #DirectToManyMapping,
	#superclass : #ToManyMapping,
	#instVars : [
		'resultField'
	],
	#category : #GlorpMappings
}

{ #category : #'VisualWorks metadata' }
DirectToManyMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
DirectToManyMapping >> attributeName: anAttributeName [
	^self attributeName: anAttributeName referenceClass: nil.
]

{ #category : #accessing }
DirectToManyMapping >> attributeName: anAttributeName referenceClass: aClass [
	"In addition to setting the attribute, use that information to further configure our faked-up descriptor. We can pass in a reference class here, although this is only really useful if we don't already have an explicit classModel."
	| model |
	super attributeName: anAttributeName.
	aClass isNil ifFalse: [attribute type: aClass].
	model := GlorpClassModel for: super referenceClass.
	"We add a mapping for our value. We don't normally use this, because we expect people to refer directly to the attribute, but it means, for example, that the field shows up in our mapped fields without us having to fake it up. And you could write a query referring to anAttribute myValue if you wanted"
	model newAttributeNamed: #myValue type: self attribute type.
	self referenceDescriptor classModel: model.
]

{ #category : #accessing }
DirectToManyMapping >> buildQuery [
	| builtQuery |
	builtQuery := super buildQuery.
	builtQuery retrieve: [:x | x getField: resultField].
	^builtQuery
]

{ #category : #mapping }
DirectToManyMapping >> buildRowMapKeyForSource: source target: target index: index [
	"When comparing row maps, we want to distinguish the entries in e.g. #(1 2 3 3 4 3 5), so include the index in the key. They aren't distinguishable in the DB unless we write the order field, so we must write the order field or believe we have no duplicate entries."

	^MultipleRowMapKey with: target with: source with: index

"TO DO:  if we map to a Set, there are never duplicate entries and we need not write the order field, but needlessly including the index in the row map key could cause failure to match were a set and its memento to traverse the same elements in different orders, which is obviously possible.  Make the above omit the index if the collectionType is an unordered collection, or have a subclass, e.g. DirectToUnsequenceableManyMapping, substituted on setting the collection type to such a collection."
]

{ #category : #'printing SQL' }
DirectToManyMapping >> convertedDbValueOf: stValue [ 
	^self myValueMapping convertedDbValueOf: stValue.
]

{ #category : #accessing }
DirectToManyMapping >> converter: aConverter [
	self myValueMapping converter: aConverter.
]

{ #category : #accessing }
DirectToManyMapping >> descriptor: aDescriptor [
	"If #myValue mapping has been set on an existing pseudoDescriptor, avoid losing it again.  This can happen if you create a DirectToManyMapping in a ConditionalMapping and set it up first (sending it #join:, which creates the #myValue submapping) and then use it (#if: [...] useMapping: myDirToManyMapping, which sends descriptor: to the mapping again."

	| existingPseudoDescriptor |
	super descriptor: aDescriptor.
	existingPseudoDescriptor := aDescriptor system
		privateAndBasicDescriptorFor: self
		ifAbsent: [^aDescriptor system privateAndBasicAddDescriptorFor: self as: self pseudoDescriptor].
	^existingPseudoDescriptor system == aDescriptor system
		ifFalse: [self error: self printString, ' had descriptor for another system']
		ifTrue: [(existingPseudoDescriptor classModel notNil and:
				[existingPseudoDescriptor classModel hasAttributeNamed: #myValue])
					ifFalse: [aDescriptor system privateAndBasicAddDescriptorFor: self as: self pseudoDescriptor]
					ifTrue: [existingPseudoDescriptor]].	"do nothing here - just assume everything is and/or will be fine - or should we warn?		
							self error: self printString,' already has a valid-seeming pseudo-descriptor; if in a conditional, send it #join: after #if:useMapping:ing it)'"
]

{ #category : #accessing }
DirectToManyMapping >> field [
	^resultField.
]

{ #category : #testing }
DirectToManyMapping >> glorpCanHaveDescriptorDirectly [
	"We allow instances of ourselves to have a descriptor, which normally only classes can do. This is so that we can have multiple different descriptors in use for e.g. String, depending on the particular usage."
	^true.
]

{ #category : #accessing }
DirectToManyMapping >> join: aJoin [
	"In addition to setting up the join, use that information to configure our faked up descriptor"
	| tables |
	super join: aJoin.
	tables := self targetTables asArray.
	tables size > 1
		ifTrue: [self error: 'Cannot have multiple tables for a direct toMany'].
	self referenceDescriptor table: tables first.
	"We add a mapping for our value. We don't normally use this, because we expect people to refer directly to the attribute, but it means, for example, that the field shows up in our mapped fields without us having to fake it up. And you could write a query referring to anAttribute myValue if you wanted"
	(self referenceDescriptor newMapping: DirectMapping) 
		from: #myValue to: resultField.
]

{ #category : #mapping }
DirectToManyMapping >> knitFromBuilder: sourceBuilder toBuilder: targetBuilder [
	"We always have an orderField and always read it when alsoFetching (the only time we will reach this method).  Use it to guard against a false equality match in attribute knitting by ensuring the object at our index in the updated collection is what it should be.  If our collection is smaller than the index, it is just 1 smaller, because we mistakenly failed to add in the super call due to another object equalling us.  (We want to DNU and see the problem if that assumption is wrong.)"

	self canRead ifFalse: [^self].
	^self attribute
		knit: sourceBuilder instance
		to: targetBuilder instance
		at: targetBuilder indexOfValue.
]

{ #category : #testing }
DirectToManyMapping >> mapsSimpleObject [
	^true.
]

{ #category : #accessing }
DirectToManyMapping >> myValueMapping [
	^self referenceDescriptor mappingForAttributeNamed: #myValue
]

{ #category : #accessing }
DirectToManyMapping >> name [
	"I answer true to #glorpCanHaveDescriptorDirectly (i.e. as if I were a class), so must be able to respond to this method which can appear in e.g. #printOn:, returning e.g. 'DirectToManyMapping of String'."

	^self class name, ' of ', self attribute type name
]

{ #category : #testing }
DirectToManyMapping >> needsSpecialRowMapKey [
	"Return true if we have to use a special key object for the row map, rather than just our target. We always do, because our target may not have identity."

	^true.
]

{ #category : #accessing }
DirectToManyMapping >> overflowAfter: anInteger intoMany: anotherInteger [
	"Tell my attribute model to treat the SequenceableCollection that I map (probably a String or ByteArray) as an initial subsequence (of size anInteger or less) mapped inline by some other mapping, followed (if it is long enough) by one or more subsequences (of length anotherInteger or, in the case of the last one, less) mapped by me."

	descriptor isNil ifTrue: [self error: 'We have no descriptor so cannot see our true classModel to reset its attribute'].
	attribute := attribute beAttributeClass: GlorpSubsequenceModel.
	attribute subsequencesStartAfter: anInteger stepping: anotherInteger.
]

{ #category : #accessing }
DirectToManyMapping >> pseudoCollectionType: aClass [
	"Tell my attribute model to treat the SequenceableCollection that I map (probably a String or ByteArray) as an initial subsequence (of size anInteger or less) mapped inline by some other mapping, followed (if it is long enough) by one or more subsequences (of length anotherInteger or, in the case of the last one, less) mapped by me.  Instances of the parameter class must understand #add: and #do: and (if sequenceable) must manage iteration state when they are called to preserve sequence order."

	descriptor isNil ifTrue: [self error: 'We have no descriptor so cannot see our true classModel to reset its attribute'].
	attribute := attribute beAttributeClass: GlorpPseudoCollectionModel.
	attribute pseudoCollectionType: aClass.
]

{ #category : #mapping }
DirectToManyMapping >> pseudoDescriptor [
	"Return a pretend descriptor for our reference class. Since that class is a primitive, it won't have a real descriptor, and it may vary by usage anyway"
	| pseudoDescriptor |
	pseudoDescriptor := Descriptor new.
	pseudoDescriptor system: descriptor system.
	^pseudoDescriptor.
]

{ #category : #accessing }
DirectToManyMapping >> referenceClass [
	"Return ourselves as the reference class, as a sort of a proxy for what we really want, which is a primitive, and varies according to the relationship anyway. Note that we have stuffed in a descriptor in the system, with ourselves (this instance) as the class."
	^self.
]

{ #category : #accessing }
DirectToManyMapping >> resultField [
	^resultField.
]

{ #category : #accessing }
DirectToManyMapping >> resultField: aField [
	resultField := aField.
]

{ #category : #validation }
DirectToManyMapping >> validate [
	"If we are for a pseudo-variable, we're neither reading nor writing, so we don't need the order.  Otherwise, we have to write the order field;  without the order, we would get confused e.g. on deletion, because we would not have a way of telling the rows in the rowmap apart when the indexes have changed.  Therefore, we validate that we write the order if we write, and have an orderBy if we write and/or read."

	super validate.
	self isForPseudoVariable ifTrue: [^self].
	(self canWrite and: [shouldWriteTheOrderField not]) ifTrue:
		[self error: 'To-many mappings to simple types must write an order field so that we have some way to tell the rows apart'].
	orderBy isNil ifTrue:
		[self error: 'To-many mappings to simple types must specify an order field so that we have some way to tell the rows apart'].
]

{ #category : #accessing }
DirectToManyMapping >> writeExtraInformationInto: aRowMap atKey: rowMapKey forSourceObject: sourceObject targetObject: targetObject atIndex: index [
	super
		writeExtraInformationInto: aRowMap
		atKey: rowMapKey
		forSourceObject: sourceObject
		targetObject: targetObject
		atIndex: index.
	aRowMap
		at: self resultField
		key: rowMapKey
		put: (self convertedDbValueOf: targetObject).
]
