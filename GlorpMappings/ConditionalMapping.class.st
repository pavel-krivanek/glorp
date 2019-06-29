"
I choose which one of a list of mappings is actually applied to each instance (writing) or row (reading) of my descriptor's class or table(s) depending on a testable condition.  The reading and writing tests act on the same value, but get this value in different ways.

Instance Variables:
	cases	<SequenceableCollection of: (Association)>	Each key is either a one-argument block to be evaluated or a one-argument selector to be performed by the descriptorSystem, returning a boolean.  Each value is the mapping to use if the key returns true.  The testable value is submitted to the cases in order and the first matching mapping is used.
	conditionaValueMapping	<Mapping>	This mapping provides the value submitted to the case keys to find the chosen case value.
	otherwiseCase	<Mapping | nil>	If none of the case keys evaluate to true, this mapping is used.

Deprecated Instance Variables:
	conditionalField	<DatabaseField | nil>	Old protocol can set this field which is then used during internal definition of the conditionalValueMapping.

The conditionaValueMapping can be implicitly defined by providing a field and a zero-argument selector or one-argument block.  When writing, the selector will be sent to the object being written, or the block will be evaluated with that object as the argument, to get the value.  When reading, the mapping reads the field's value.  Alternatively, the user can define the mapping explicitly.  Setters are provided for both cases.

If the conditionaValueMapping is made writable: it will write the conditional value to the database.  If it is made readable, it will set the value on the object.  (N.B. if a readable conditionalFieldMapping uses a setter method, not direct access, that setter must return the set value, not ^self  - or else the conditionalMethod must return the whole object and the case keys must be able to accept an instance populated only up to the point where the mappings' iteration reaches this mapping.)  The overall mappings readability or writabaility will constrain the readability or writability of the individual mappings, who can still be unwritable or unreadable even if the overall mapping is writable or readable, but the state is independent for the conditionalValueMapping.

For some mapping settings, e.g. shouldProxy, the selected mapping controls behaviour, so some of my mappings can return proxies while others do not.  In others, e.g. debugWrite/Read, my value determines behaviour and the value for the selected submapping is ignored.
"
Class {
	#name : #ConditionalMapping,
	#superclass : #Mapping,
	#instVars : [
		'conditionalField',
		'cases',
		'otherwiseCase',
		'conditionalValueMapping'
	],
	#category : #'GlorpMappings-Glorp'
}

{ #category : #'VisualWorks metadata' }
ConditionalMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #mapping }
ConditionalMapping >> applicableMappingForConditionalValue: mappedValue [
	"Note that it is the descriptor system, not the object, that performs the key if the key is a symbol."

	cases do:
		[:each |
		((Dialect isBlock: each key)
			ifTrue: [each key value: mappedValue]
			ifFalse: [self descriptor system
					perform: each key
					with: mappedValue])
			ifTrue: [^each value]].
	^otherwiseCase
]

{ #category : #mapping }
ConditionalMapping >> applicableMappingForObject: anObject [
	| conditionalValue |
	conditionalValue := conditionalValueMapping getValueFrom: anObject.
	^self applicableMappingForConditionalValue: conditionalValue
]

{ #category : #mapping }
ConditionalMapping >> applicableMappingForRow: anArray in: anElementBuilder [
	"My conditionalValueMapping gets the test value, so if it is readable that value will be set in the instance even if I am not readable.  Even if the conditionalValueMapping is just a DirectMapping to the conditionalField, that mapping might have a converter and/or use indirect access to achieve some effect.  If the conditionalFieldMapping uses a setter, not a block or direct access, then either that setter must return the set value or else the #conditionalMethod: case must return the whole object and each #if:then: case must work on an instance populated only up to the point where the mappings' iteration reaches this mapping."

	| conditionalValue |
	conditionalValue := conditionalValueMapping
		mapObject: anElementBuilder instance
		inElementBuilder: anElementBuilder.
	^self applicableMappingForConditionalValue: conditionalValue
]

{ #category : #accessing }
ConditionalMapping >> attributeName [
	^self representativeMapping attributeName.
]

{ #category : #accessing }
ConditionalMapping >> cases [
	^cases.
]

{ #category : #accessing }
ConditionalMapping >> casesDo: aBlock [
	"Iterate over any mapping that could read or write my value."

	cases do: [:each | aBlock value: each value].
	otherwiseCase isNil ifFalse: [aBlock value: otherwiseCase].
]

{ #category : #'backward-compatibility' }
ConditionalMapping >> conditionalField: aField [
	(conditionalField notNil and: [conditionalField ~~ aField]) ifTrue:
		[self error: 'To use more than one field in a conditional mapping''s test, you must set the conditionalValueMapping explicitly'].
	conditionalField := aField.
]

{ #category : #'backward-compatibility' }
ConditionalMapping >> conditionalMethod: aSymbolOrOneArgBlock [
	"As the use of conditionalField is deprecated, we nil it after use in this also-deprecated method."

	self forField: conditionalField attribute: aSymbolOrOneArgBlock.
	conditionalField := nil.
]

{ #category : #accessing }
ConditionalMapping >> conditionalValueMapping [
	"Only use this lazy accessor for b/w compatibility with calls of conditionalField: and conditionalMethod: setters."

	conditionalValueMapping isNil ifTrue: [conditionalValueMapping := (self newMapping: DirectMapping) beForPseudoVariable].
	^conditionalValueMapping
]

{ #category : #accessing }
ConditionalMapping >> conditionalValueMapping: aMapping [
	"This lets the user set the mapping for the conditional field value.  If the supplied mapping is writable, it will write the conditional value to the database.  If it is readable, it will set the value on the object.  If it is for a pseudoVariable (a common case) then it will do neither (and the system must ensure that the data used to get the value is written to the database and read to the object in other ways;  often, it wil naturally be part of the data read and written by the object)."

	conditionalValueMapping := aMapping.
	descriptor isNil ifFalse: [aMapping descriptor: descriptor].
	(descriptor mappings includes: aMapping) ifTrue:
		[self error: aMapping printString, ' is part of a conditional mapping and part of the main descriptor. Send newMapping: to the conditional, not the descriptor'].
]

{ #category : #testing }
ConditionalMapping >> controlsTables [
	self mappingsDo: [:each | each controlsTables ifTrue: [^true]].
	^false
]

{ #category : #accessing }
ConditionalMapping >> descriptor: aDescriptor [
	super descriptor: aDescriptor.
	cases do: [:each | each value descriptor: aDescriptor].
	otherwiseCase isNil ifFalse: [otherwiseCase descriptor: aDescriptor].
	conditionalValueMapping isNil ifFalse: [conditionalValueMapping descriptor: aDescriptor].
]

{ #category : #accessing }
ConditionalMapping >> field [
	^self mappedFields asArray first.
]

{ #category : #conditions }
ConditionalMapping >> forField: aField attribute: aSymbolOrOneArgBlock [
	"Define the conditionalValueMapping is a direct mapping between my two parameters.  Performing the symbol on the object or evaluating the block with the object returns the value that is tested against the cases when writing.  When reading, the fields value is tested.  As the same cases are tested by both reading and writing, this method must return either the value that gets mapped to the field, or something sufficiently compatible with it to give the same result when tested (e.g. if the tests are #valueIsNil:/#valueNotNil: then we would merely require the result to be nil/notNil when the value written to the field will be nil/notNil).
	If you set the conditionalValueMapping is set to write and/or read then its value will be written to the database and/or read into the object by that mapping, over and above whatever is written and read by the matching case and the rest of the system.  This is an way to recording the discriminating value in an additional field to help keep writing and reading in synch."

	conditionalValueMapping := (self newMapping: DirectMapping) beForPseudoVariable.
	(Dialect isBlock: aSymbolOrOneArgBlock)
		ifFalse: [conditionalValueMapping from: aSymbolOrOneArgBlock to: aField]
		ifTrue: [conditionalValueMapping
				from: self generateConditionalValueMappingName to: aField;
				getValueBlock: aSymbolOrOneArgBlock].
]

{ #category : #conditions }
ConditionalMapping >> forField: aField attribute: attributeBlock if: testBlock useMapping: aMapping [
	self forField: aField attribute: attributeBlock.
	self if: testBlock then: aMapping.
]

{ #category : #conditions }
ConditionalMapping >> generateConditionalValueMappingName [
	"If my descriptor has two conditional mappings, both with generated conditional value mapping names, we must use different names, but if I am resetting the conditionalValueMapping values for an existing conditional mapping (pretty unlikely but maybe odd programmatic manipulations or heavy debugging could see this!) then I should use the same name."

	self descriptor isNil ifTrue: [self halt: 'Tell Niall if you see this'. ^'generated-conditionalValueMapping1' asSymbol].
	1 to: self descriptor classModel attributes size + 1 do:
		[:i || candidateName potentialRival |
		candidateName := ('generated-conditionalValueMapping', i printString) asSymbol.
		potentialRival := self descriptor classModel attributes
			detect: [:each | each name == candidateName]
			ifNone: [^candidateName].
		potentialRival := self descriptor mappings
			detect: [:each | each attribute == potentialRival]
			ifNone: [nil].	"Carry on to get another name; this name is not even owned by my descriptor"
		potentialRival == self ifTrue: [^candidateName]].
	"The final error is impossible unless the user has been hand-assigning generated-style names."
	self error: 'We failed to generate a conditionalValueMapping name; provide an explicit named mapping.'
]

{ #category : #testing }
ConditionalMapping >> hasField [
	"We used to ignore the otherwise case in mappedFields, now do not, so maybe this should just check the cases fields or otherwise continue returning the same results - TBD."

	^self mappedFields size = 1
]

{ #category : #testing }
ConditionalMapping >> hasValueThatCanProvideField: aField from: anObject [
	^(self applicableMappingForObject: anObject)
		hasValueThatCanProvideField: aField from: anObject
]

{ #category : #conditions }
ConditionalMapping >> if: conditionSelector then: aMapping [

	cases add: (Association key: conditionSelector value: aMapping).
	descriptor isNil ifFalse: [aMapping descriptor: descriptor].
	(descriptor mappings includes: aMapping) ifTrue: [self error: 'Mapping is part of a conditional and part of the main descriptor. Be sure to send newMapping: to the conditional, not to the descriptor'].
]

{ #category : #'initialize-release' }
ConditionalMapping >> initialize [
	
	super initialize.
	cases := OrderedCollection new.
]

{ #category : #testing }
ConditionalMapping >> isRelationship [
	"Returning true means that an ObjectBuilder, not an ElementBuilder, will be provided to handle the applicableMapping.  We can nevertheless include DirectMappings in our cases provided the representativeMapping maps primary keys.  This allows ObjectBuilder>>canBuild to recognise that it cannot treat the DirectMapping - which will have nil key - as a relationship mapping.  The representativeMapping must therefore say it maps primary keys for the direct mapping to build (which may indicate something to fix, but that is the state for now)."

	^self representativeMapping isRelationship
]

{ #category : #accessing }
ConditionalMapping >> join [
	"The representativeMapping join is inadequate if an outer join:  #condensePrimaryKeyComparisons, inside #adjustWhereClause, rewrites to cut out the other cases, ignoring that it is an outer join and so should be part of an OR.  Returning a nonce GlorpExpression that aborts that check does not work either.  We may need to return the OR of all the cases joins.  TDB."

	^self representativeMapping join
]

{ #category : #preparing }
ConditionalMapping >> joinExpressionFor: anExpression [

	^self representativeMapping joinExpressionFor: anExpression.
]

{ #category : #mapping }
ConditionalMapping >> knitFromBuilder: anotherElementBuilder toBuilder: anElementBuilder [
	self canRead ifFalse: [^self].
	(self applicableMappingForRow: anotherElementBuilder row in: anotherElementBuilder)
		knitFromBuilder: anotherElementBuilder toBuilder: anElementBuilder.
]

{ #category : #mapping }
ConditionalMapping >> mapFromObject: anObject intoRowsIn: aRowMap [
	"If any of my case-chosen mappings are writable, then I must be writable - and, conversely, my not being writable will suppress any of them being written.  My conditionalValueMappingis read or written independently."

	conditionalValueMapping
		mapFromObject: anObject
		intoRowsIn: aRowMap.
	self canWrite ifFalse: [^self].
	(self applicableMappingForObject: anObject)
		mapFromObject: anObject
		intoRowsIn: aRowMap.
]

{ #category : #mapping }
ConditionalMapping >> mapObject: anObject inElementBuilder: anElementBuilder [
	^(self applicableMappingForRow: anElementBuilder row in: anElementBuilder)
		mapObject: anObject
		inElementBuilder: anElementBuilder
]

{ #category : #accessing }
ConditionalMapping >> mappedFields [
	"This method returns a set.  Its polymorphs return an array or ordered collection.  For now, leave it so, but review."

	| all |
	all := Set new.
	self mappingsDo: [:each | all addAll: each mappedFields].
	^all	"asArray"
]

{ #category : #accessing }
ConditionalMapping >> mappingsDo: aBlock [
	"Iterate over all my submappings."

	aBlock value: conditionalValueMapping.
	self casesDo: [:each | aBlock value: each].
]

{ #category : #mapping }
ConditionalMapping >> newMapping: aMappingClass [
	"Implement this so that we can create our sub-mappings without having them added to the parent descriptor as independent mappings"
	| mapping |
	mapping := aMappingClass new.
	mapping descriptor: self descriptor.
	descriptor resetMappedFields.
	^mapping.
]

{ #category : #accessing }
ConditionalMapping >> otherwise [
	^otherwiseCase.
]

{ #category : #conditions }
ConditionalMapping >> otherwise: aMapping [

	otherwiseCase := aMapping.
	descriptor isNil ifFalse: [otherwiseCase descriptor: descriptor].
	(descriptor mappings includes: aMapping) ifTrue: [self error: 'Mapping is part of a conditional and part of the main descriptor. Be sure to send newMapping: to the conditional, not to the descriptor'].
]

{ #category : #accessing }
ConditionalMapping >> referenceClass [
	^self representativeMapping referenceClass.
]

{ #category : #mapping }
ConditionalMapping >> referencedIndependentObjectsFrom: anObject [
	^(self applicableMappingForObject: anObject)
		referencedIndependentObjectsFrom: anObject
]

{ #category : #accessing }
ConditionalMapping >> representativeMapping [
	"At some points we may need to have this mapping behave some way without knowing yet which of its cases is satisfied. We assume that there is some basic level of similarity so that we can use one mapping as a representative to discover, e.g. what the reference class is. This works all right for cases where we have a mapping or a constant. It wouldn't work very well if we have a one to one mapping to one class in case (a) but a many-many to an entirely different class in the other"
	^cases first value.
]

{ #category : #mapping }
ConditionalMapping >> trace: aTracing context: anExpression [
	self mappingsDo: [:each | each trace: aTracing context: anExpression].
]

{ #category : #mapping }
ConditionalMapping >> translateField: aDatabaseField [
	^self representativeMapping translateField: aDatabaseField
]

{ #category : #validation }
ConditionalMapping >> validateAttribute [
	self mappingsDo: [:each | each validateAttribute].
]

{ #category : #mapping }
ConditionalMapping >> valueIn: anElementBuilder as: aMappingExpression [
	^(self applicableMappingForRow: anElementBuilder row in: anElementBuilder)
		valueIn: anElementBuilder as: aMappingExpression
]

{ #category : #testing }
ConditionalMapping >> valueOfField: aField fromObject: anObject ifNone: aBlock [
	^(self applicableMappingForObject: anObject)
		valueOfField: aField fromObject: anObject ifNone: aBlock
]
