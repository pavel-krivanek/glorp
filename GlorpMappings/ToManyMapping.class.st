"
This is a superclass for mappings which represent a relationship between one object and a collection of others. It isn't an abstract superclass, you can use this class directly, and you will get the same behaviour as if you were using OneToManyMapping. Or if you set useLinkTable to true, you'll get the same behaviour as a ManyToManyMapping.

Instance Variables:
	orderBy	<(SequenceableCollection of: (GlorpExpression | BlockClosure))>	By what criteria should we order the collection of items when we are reading.
	shouldWriteTheOrderField	<Boolean>	On write, when we write an item in the collection, should we also write the index at which it occurs in the collection into the database. This lets us preserve ordering if we just used a SequenceableCollection in memory. If this is true, we assume that the first item in orderBy will give us the field to write the index into.


"
Class {
	#name : #ToManyMapping,
	#superclass : #RelationshipMapping,
	#instVars : [
		'orderBy',
		'shouldWriteTheOrderField'
	],
	#category : #'GlorpMappings-Glorp'
}

{ #category : #'VisualWorks metadata' }
ToManyMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #mapping }
ToManyMapping >> buildGeneralQueryIn: anObjectBuilder [
	| newQuery |
	newQuery := super buildGeneralQueryIn: anObjectBuilder.
	orderBy isNil ifFalse: [orderBy do: [:each | newQuery orderBy: each]].
	^newQuery.
]

{ #category : #mapping }
ToManyMapping >> buildQuery [
	| builtQuery |
	builtQuery := super buildQuery.
	orderBy isNil ifFalse: [orderBy do: [:each | builtQuery orderBy: each]].
	^builtQuery
]

{ #category : #api }
ToManyMapping >> collectionType [
	^self attribute collectionType.
]

{ #category : #api }
ToManyMapping >> collectionType: aClass [
	self attribute collectionType: aClass.
]

{ #category : #mapping }
ToManyMapping >> customRowMapKeyForSource: anObject target: anotherObject index: anInteger [
	"Until 8.3.1, Glorp did not pass the 3rd parameter, so all rowMapKeyConstructorBlocks before then had twp parameters, not three.  Because rowMapKeyConstructorBlocks have been very rarely used till now, this change to using all three parameters for to-many mappings is not expected to cause backward-compatibility problems.  If it does, change this method to
	^rowMapKeyConstructorBlock cull: realSource cull: realTarget cull: index
to allow blocks with two parameters."

	^rowMapKeyConstructorBlock value: anObject value: anotherObject value: anInteger
]

{ #category : #'initialize/release' }
ToManyMapping >> defaultCollectionType [
	^OrderedCollection.
]

{ #category : #testing }
ToManyMapping >> hasValueThatCanProvideField: aField from: anObject [
	"Return true if we have enough information in ourselves to populate our fields. The only time this won't be true is if we're either holding an uninstantiated proxy or have a to-many relationship mapping with an empty collection. Inline the superclass implementation to avoid fetching the value twice."
	| value |
	(super hasValueThatCanProvideField: aField from: anObject) ifFalse: [^false].
	value := self getValueFrom: anObject.
	^value isEmpty not.
]

{ #category : #'initialize/release' }
ToManyMapping >> initialize [
	super initialize.
	shouldWriteTheOrderField := false.
]

{ #category : #'initialize/release' }
ToManyMapping >> initializeAttribute [
	"This is where we can initialize aspects of the attribute, if required. The motivating example is initializing the collection type of the attribute if it wasn't set. We need it to have some type, but we don't want to initialize it while we're doing basic initialization and aren't yet properly attached to a descriptor or class model"
	super initializeAttribute.
	self attribute collectionType isNil
		ifTrue: [self attribute collectionType: self defaultCollectionType].
]

{ #category : #mapping }
ToManyMapping >> keyForOrderingFrom: anObject to: target [
	self usesLinkTable ifFalse: [^target].
	^self orderField table == self linkTable ifTrue: [target] ifFalse: [anObject].
]

{ #category : #mapping }
ToManyMapping >> knitFromBuilder: sourceBuilder toBuilder: targetBuilder [
	self canRead ifFalse: [^self].
	^self attribute knit: sourceBuilder instance to: targetBuilder instance
]

{ #category : #'private/expressions' }
ToManyMapping >> linkTable [
	| referenceKeys |
	self usesLinkTable ifFalse: [^nil].
	referenceKeys := self join targetKeys asOrderedCollection.
	^referenceKeys first table
]

{ #category : #api }
ToManyMapping >> orderBy [
	^orderBy.
]

{ #category : #api }
ToManyMapping >> orderBy: aBlockOrSelector [
	orderBy isNil ifTrue: [orderBy := OrderedCollection new].
	orderBy add: aBlockOrSelector.
]

{ #category : #'private/expressions' }
ToManyMapping >> orderField [
	| exp |
	exp := Query new expressionBlockFor: orderBy first.
	^(exp asGlorpExpressionOn: (BaseExpression new descriptor: self referenceDescriptor)) field.
]

{ #category : #api }
ToManyMapping >> shouldWriteTheOrderField [
	^shouldWriteTheOrderField
]

{ #category : #api }
ToManyMapping >> shouldWriteTheOrderField: aBoolean [
	shouldWriteTheOrderField := aBoolean.
]

{ #category : #validation }
ToManyMapping >> validate [

	| targetClassModel |
	super validate.
	(self collectionType = GlorpCursoredStream and: [self shouldUseFilteredRead]) ifTrue: [self error: 'Filtered mappings can cause duplicates and so cannot return cursors'].

	(shouldWriteTheOrderField and: [orderBy isNil]) ifTrue: [self error: 'Mapping tries to write the collection order to a field, but has no order by field specified'].
	(shouldWriteTheOrderField & usesLinkTable)
		ifTrue: [ | targetTable |
			targetTable := (self linkTableJoin allTargetFields collect: [:each | each table]) first.
			targetTable primaryKeyFields isEmpty ifTrue: [self error: 'A mapping with a link table and which writes the order field must define primary key fields and must not include the order field as a primary key']].
	
	orderBy isNil ifTrue: [^self].
	targetClassModel := self system classModelFor: attribute type.

	"Note that this will only validate when the orderBy is a symbol - not a block, expression, or field"
	orderBy do: [:attributeName |
		attributeName isSymbol ifTrue: [
			(targetClassModel hasAttributeNamed: attributeName) ifFalse: [
				self error: attribute printString, ' is attempting to order by #', attributeName, ' which is not a mapped attribute of ', targetClassModel describedClass name]]].
]

{ #category : #mapping }
ToManyMapping >> writeExtraInformationInto: aRowMap atKey: rowMapKey forSourceObject: sourceObject targetObject: targetObject atIndex: index [
	"If the collection I map to is sequenceable, we can write that order to the database so as to re-read elements in that same order."

	shouldWriteTheOrderField ifTrue:
		[aRowMap
			at: self orderField
			key: (self keyForOrderingFrom: sourceObject to: rowMapKey)
			put: index].

"Note that, even if the collection I map is _not_ sequenceable, Glorp does in fact increment the index in parallel with the #do: iteration, so the actual sequence of iteration through a set as we write rows for it is captured and would be written here if an orderField were specified."
]

{ #category : #api }
ToManyMapping >> writeTheOrderField [
	shouldWriteTheOrderField := true.
]
