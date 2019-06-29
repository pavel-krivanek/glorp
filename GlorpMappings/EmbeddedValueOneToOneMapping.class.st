"
This represents a one-to-one mapping in which the referenced object is stored as part of the same table as the containing object.
"
Class {
	#name : #EmbeddedValueOneToOneMapping,
	#superclass : #OneToOneMapping,
	#instVars : [
		'fieldTranslation'
	],
	#category : #'GlorpMappings-Glorp'
}

{ #category : #'VisualWorks metadata' }
EmbeddedValueOneToOneMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #testing }
EmbeddedValueOneToOneMapping >> controlsTables [
	"Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

	^false
]

{ #category : #transformations }
EmbeddedValueOneToOneMapping >> defaultTransformationExpressionFor: aDescriptor [ 
	"If there's no transformation, get all the mapped fields from the other descriptor and construct a transformation of each onto itself. This lets us unify the fields in my row with the fields in its row"

	| fields transform |
	fields := IdentitySet new.
	aDescriptor mappings do: [:each | fields addAll: each mappedFields].
	transform := Join new.
	fields do: [:each | transform addSource: each target: each].
	^transform
]

{ #category : #accessing }
EmbeddedValueOneToOneMapping >> fieldTranslation [
	^fieldTranslation
]

{ #category : #accessing }
EmbeddedValueOneToOneMapping >> fieldTranslation: aPrimaryKeyExpression [
	"Typically, the parameter is a join connecting the real table to the imaginary table of the embedded value mapping."

	fieldTranslation := aPrimaryKeyExpression.
]

{ #category : #internal }
EmbeddedValueOneToOneMapping >> fieldsForSelectStatement [
	"Return a collection of fields that this mapping will read from a row"
	"Return nothing, because our sub-objects will take care of adding their own fields, translated correctly through us."
	^#().
]

{ #category : #accessing }
EmbeddedValueOneToOneMapping >> hasFieldTranslation [

	^fieldTranslation notNil.
]

{ #category : #transformations }
EmbeddedValueOneToOneMapping >> hasTransformation [

	^false.
]

{ #category : #initializing }
EmbeddedValueOneToOneMapping >> initialize [
	super initialize.
	shouldProxy := false.
]

{ #category : #testing }
EmbeddedValueOneToOneMapping >> isStoredInSameTable [
	^true
]

{ #category : #accessing }
EmbeddedValueOneToOneMapping >> join [
	^nil.
]

{ #category : #accessing }
EmbeddedValueOneToOneMapping >> join: anExpression [
	self error: 'Embedded mappings do not use joins'.
]

{ #category : #preparing }
EmbeddedValueOneToOneMapping >> joinExpressionFor: targetExpression [
	"We're looking for the object represented by this mapping, and we know the object represented by its source. Use our mapping criteria to construct a join that traverses that instance of this relationship.
	Embedded values never induce a join."

	^nil.
]

{ #category : #mapping }
EmbeddedValueOneToOneMapping >> knitFromBuilder: sourceBuilder toBuilder: targetBuilder [ 
	sourceBuilder requiresPopulating ifFalse: [^self].
	super knitFromBuilder: sourceBuilder toBuilder: targetBuilder
]

{ #category : #mapping }
EmbeddedValueOneToOneMapping >> mapFromObject: anObject toTarget: target puttingRowsIn: aRowMap [
	"We create our rows - that are rows in (some or all of) my owner's table(s) - and then mark them as not to be written to the database.  Row unification causes any values we have put in fields of my rows to be also put in the same fields of my owner's rows that its direct mappings wrote.  These latter rows will be written - with the owner's values and mine - while my rows contain only those values I provide and so will (almost) certainly be incomplete and not fit for writing and in any case redundant."

	self transformationExpression
		mapFromSource: anObject
		andTarget: target
		intoRowsIn: aRowMap.
	self transformationExpression allTables do:
		[:eachTable |
		aRowMap rowForTable: eachTable withKey: target ifPresent:
			[:each | each shouldBeWritten: false]].
]

{ #category : #mapping }
EmbeddedValueOneToOneMapping >> mapObject: anObject inElementBuilder: anElementBuilder [
	"Check whether the object already has a value in my slot.  If it does, then we got a cache hit, the embedded value was carried along for the ride, and we don't need to assign anything.  If not, we need to look up the trace node that corresponds to this mapping, and get its instance."

	| myTraceNode myBuilder |
	(self getValueFrom: anObject) isNil ifFalse: [^self].
	myTraceNode := anElementBuilder expression get: self attributeName.
	myBuilder := anElementBuilder query elementBuilderFor: myTraceNode.
	^self setValueIn: anObject to: myBuilder instance
]

{ #category : #internal }
EmbeddedValueOneToOneMapping >> mappedFields [
	"Return a collection of fields that this mapping will write into any of the containing object's rows"

	fieldTranslation isNil ifFalse: [^fieldTranslation allSourceFields].
	^self referenceDescriptor mappedFields.
]

{ #category : #mapping }
EmbeddedValueOneToOneMapping >> reverseMapping [
	^self class new
		attributeName: #temporaryReverseMappingForEmbeddedMapping;
		referenceClass: self descriptor describedClass;
		descriptor: self descriptor.
]

{ #category : #accessing }
EmbeddedValueOneToOneMapping >> shouldProxy: aBoolean [
	self halt: 'I''m not sure embedded mappings _can_ proxy;  I''m fairly sure they shouldn''t'.
	shouldProxy := aBoolean.
]

{ #category : #transformations }
EmbeddedValueOneToOneMapping >> transformationExpression [
	^self hasFieldTranslation
		ifTrue: [fieldTranslation]
		ifFalse: [fieldTranslation := self defaultTransformationExpressionFor: self referenceDescriptor]
]

{ #category : #mapping }
EmbeddedValueOneToOneMapping >> translateField: aDatabaseField [
	^fieldTranslation isNil
		ifTrue: [aDatabaseField]
		ifFalse: [fieldTranslation sourceForTarget: aDatabaseField ifNone: [aDatabaseField]]
]

{ #category : #mapping }
EmbeddedValueOneToOneMapping >> translateTable: aTable [
	"If we have a field translation, return the translated (i.e. real) table to use. This ideally allows us to use either the real table in which something is embedded, or the imaginary table."

	fieldTranslation isNil ifTrue: [^aTable].
	1 to: fieldTranslation allTargetFields size do:
		[:i | (fieldTranslation allTargetFields at: i) table == aTable
			ifTrue: [^(fieldTranslation allSourceFields at: i) table]].
	^aTable
]

{ #category : #mapping }
EmbeddedValueOneToOneMapping >> valueOfField: aField fromObject: anObject ifNone: aBlock [
	| targetField target |
	targetField := self transformationExpression targetForSource: aField.
	targetField isNil ifTrue: [^aBlock value].
	target := self getValueFrom: anObject.
	^self referenceDescriptor valueOfField: targetField fromObject: target.
]
