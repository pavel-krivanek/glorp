"
This experimental class was developed in Glorp 8.3.1 from DirectToManyMapping.  It is an alternative to a multipleTableJoin.  It is a one-to-one mapping where the target class is a simple type, not a compound object.

When to use this mapping instead of a multipleTableJoin and a DirectMapping depends on whether the join is owning-object-specific or mapping-specific.

- If the same join suffices for all mappings to the target table, i.e. the join is owning-object-specific and the individual mappings to fields in the multiply-joined table add no join information of their own, then there is probably no need to use this class.  To map a simple type directly to a field that is not in a descriptor's main table, give the owning descriptor a multipleTableJoin between its main table and the field's table.  A DirectMapping from an instar in the owning object to a field in the target table can then be defined, exactly as if it were to a field in the main table.  (The join can be an outer join if not all instances of the describedClass and/or its subclasses have data in the table.)  The owning object is then built from just one row in each of the tables (or sometimes none if the join is an outer join).

- This subclass of OneToOneMapping is an alternative mechanism for use when each mapping needs its own join.  If an object has two mappings to another table, each to _different_ rows of that table, this would be the class to use.  (Example:  a legacy system maps ascii text to varchars on a platform that sizes text in bytes, not chars.  A TwoByteString could exceed the available size by up to 100%.  To solve this, let each mapped instvarwrite what it can to the existing varchar field and the overflow, if any, to a row in a table with fields for the owner's primaryKey, the overflowed instvar name and the overflowed text.  If the owning object has two such overflowing instvars, it must join to two distinct rows in the overflow table, each keyed by the same owning-object primaryKey but a different instvar name.  Two DirectToOneMappings manage this situation less confusingly than two multipleTableJoins to the same table.

Instance Variables:
	resultField	<DatabaseField>	The field in the target table to which we map.
"
Class {
	#name : #DirectToOneMapping,
	#superclass : #OneToOneMapping,
	#instVars : [
		'resultField'
	],
	#category : #GlorpMappings
}

{ #category : #'VisualWorks metadata' }
DirectToOneMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
DirectToOneMapping >> attributeName: anAttributeName [
	^self attributeName: anAttributeName referenceClass: nil.
]

{ #category : #accessing }
DirectToOneMapping >> attributeName: anAttributeName referenceClass: aClass [
	"In addition to setting the attribute, use that information to further configure our faked-up descriptor. We can pass in a reference class here, although this is only really useful if we don't already have an explicit classModel."
	| model |
	super attributeName: anAttributeName.
	aClass isNil ifFalse: [attribute type: aClass].
	model := GlorpClassModel for: super referenceClass.
	"We add a mapping for our value. We don't normally use this, because we expect people to refer directly to the attribute, but it means, for example, that the field shows up in our mapped fields without us having to fake it up. And you could write a query referring to anAttribute myValue if you wanted"
	model newAttributeNamed: #myValue type: self attribute type.
	self referenceDescriptor classModel: model.
]

{ #category : #'printing SQL' }
DirectToOneMapping >> convertedDbValueOf: stValue [ 
	^self myValueMapping convertedDbValueOf: stValue.
]

{ #category : #accessing }
DirectToOneMapping >> converter: aConverter [
	self myValueMapping converter: aConverter.
]

{ #category : #accessing }
DirectToOneMapping >> descriptor: aDescriptor [
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

{ #category : #printing }
DirectToOneMapping >> field [
	^resultField.
]

{ #category : #glorp }
DirectToOneMapping >> glorpCanHaveDescriptorDirectly [
	"We allow instances of ourselves to have a descriptor, which normally only classes can do. This is so that we can have multiple different descriptors in use for e.g. String, depending on the particular usage."
	^true.
]

{ #category : #accessing }
DirectToOneMapping >> join: aJoin [
	"In addition to setting up the join, use that information to add a mapping for our value. We don't normally use this when writing, because we expect people to refer directly to the attribute, but it means, for example, that the field shows up in our mapped fields without us having to contrive it (and you could write a query referring to [ ... | ... anAttribute myValue ...] if you wanted).  When reading, this mapping is the one used by the builder to get the value - see BaseExpression>>valueInBuilder: (thus its converter is applied)."

	| tables |
	super join: aJoin.
	tables := self targetTables asArray.
	tables size > 1 ifTrue:
		[self error: 'Cannot have multiple tables for a ', self class name].
	self referenceDescriptor table: tables first.
	(self referenceDescriptor newMapping: DirectMapping) 
		from: #myValue to: resultField.
]

{ #category : #testing }
DirectToOneMapping >> mapsSimpleObject [
	^true
]

{ #category : #accessing }
DirectToOneMapping >> myValueMapping [
	^self referenceDescriptor mappingForAttributeNamed: #myValue
]

{ #category : #accessing }
DirectToOneMapping >> name [
	"I answer true to #glorpCanHaveDescriptorDirectly (i.e. as if I were a class), so must be able to respond to this method which can appear in e.g. #printOn:, returning e.g. 'DirectToManyMapping of String'."

	^self class name, ' of ', self attribute type name
]

{ #category : #accessing }
DirectToOneMapping >> pseudoDescriptor [
	"Return a pretend descriptor for our reference class. Since that class is a primitive, it won't have a real descriptor, and it may vary by usage anyway"
	| pseudoDescriptor |
	pseudoDescriptor := Descriptor new.
	pseudoDescriptor system: descriptor system.
	^pseudoDescriptor.
]

{ #category : #accessing }
DirectToOneMapping >> referenceClass [
	"Return ourselves as the reference class, as a sort of a proxy for what we really want, which is a primitive, and varies according to the relationship anyway. Note that we have stuffed in a descriptor in the system, with ourselves (this instance) as the class."
	^self.
]

{ #category : #accessing }
DirectToOneMapping >> resultField [

	^resultField
]

{ #category : #accessing }
DirectToOneMapping >> resultField: aField [
	resultField := aField.
]

{ #category : #mapping }
DirectToOneMapping >> writeExtraInformationInto: aRowMap atKey: rowMapKey forSourceObject: sourceObject targetObject: targetObject atIndex: index [
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
