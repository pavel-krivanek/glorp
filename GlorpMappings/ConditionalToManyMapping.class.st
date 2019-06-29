"
This is a conditional mapping, but one where the condition is applied to a relationship with a collection, and applies to individual elements of the collection. So, rather than making a single choice overall of which mapping to apply, we loop over the collection and make the choice separately for each element.

This is experimental, and probably suffers from lots of limitations.
"
Class {
	#name : #ConditionalToManyMapping,
	#superclass : #ToManyMapping,
	#instVars : [
		'conditional'
	],
	#category : #'GlorpMappings-My Classes'
}

{ #category : #'VisualWorks metadata' }
ConditionalToManyMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #mapping }
ConditionalToManyMapping >> applicableMappingForObject: anObject [
	"We can actually be called here with our parent object, but in the contexts in which that happens we basically just want to do nothing, so return a dummy mapping that replies false to isRelationship.  Give its value text about its origins in case anyone finds themselves examining it in some unexpected context."

	[self attribute checkTargetType: anObject]
		on: GlorpInvalidTypeError
		do: [:ex | ^ConstantMapping new constantValue: 'ConditionalToManyMapping>>applicableMappingForObject: called on parent, so did nothing and handled ', ex getMessageText].
	^self conditional applicableMappingForObject: anObject
]

{ #category : #mapping }
ConditionalToManyMapping >> applicableMappingForRow: anArray in: anElementBuilder [
	^self conditional applicableMappingForRow: anArray in: anElementBuilder.
]

{ #category : #mapping }
ConditionalToManyMapping >> buildQuery [
	| builtQuery |
	builtQuery := CompositeQuery new.
	self conditional casesDo:
		[:each | builtQuery addQuery: each query].
	^builtQuery
]

{ #category : #accessing }
ConditionalToManyMapping >> conditional [
	conditional isNil ifTrue: [conditional := self newMapping: ConditionalMapping].
	^conditional.
]

{ #category : #accessing }
ConditionalToManyMapping >> conditional: anObject [
	conditional := anObject
]

{ #category : #'backward-compatibility' }
ConditionalToManyMapping >> conditionalField: aField [
	self conditional conditionalField: aField.
]

{ #category : #'backward-compatibility' }
ConditionalToManyMapping >> conditionalMethod: aSymbol [
	self conditional conditionalMethod: aSymbol.
]

{ #category : #conditions }
ConditionalToManyMapping >> forField: aField attribute: aSymbolOrOneArgBlock if: testBlock useMapping: aMapping [
	self conditional
		forField: aField
		attribute: aSymbolOrOneArgBlock.
	self if: testBlock then: aMapping.
]

{ #category : #conditions }
ConditionalToManyMapping >> if: conditionSelector then: aMapping [
	self conditional if: conditionSelector then: aMapping.
]

{ #category : #mapping }
ConditionalToManyMapping >> mapOneFromObject: sourceObject toTarget: targetObject intermediate: aRowMapKey atPosition: index puttingRowsIn: aRowMap [
	"For the applicable mapping, map a single object from the target (which is a collection) to the RowMap."

	(self applicableMappingForObject: targetObject)
		mapOneFromObject: sourceObject
		toTarget: targetObject
		intermediate: aRowMapKey
		atPosition: index
		puttingRowsIn: aRowMap.
]

{ #category : #accessing }
ConditionalToManyMapping >> mappedFields [
	^self conditional mappedFields
]

{ #category : #accessing }
ConditionalToManyMapping >> newMapping: aMappingClass [
	"Implement this so that we can create our sub-mappings without having them added to the parent descriptor as independent mappings"
	| mapping |
	mapping := aMappingClass new.
	mapping descriptor: self descriptor.
	descriptor resetMappedFields.
	^mapping.
]

{ #category : #conditions }
ConditionalToManyMapping >> otherwise: aMapping [
	self conditional otherwise: aMapping.
]

{ #category : #mapping }
ConditionalToManyMapping >> parametersIn: anElementBuilder [
	"The conditional's conditionalFieldMapping (if there is one) may well not have a join - it may be a direct mapping to the base table - and so it is omitted from the list below, i.e. we call casesDo:, not mappingsDo:."

	| parameters |
	self shouldUseFilteredRead ifTrue: [^anElementBuilder command parameters].
	parameters := IdentityDictionary new.
	self conditional casesDo:
		[:each |
		each join mappableSourceFieldsDo:
			[:eachSource | parameters at: eachSource put: (anElementBuilder valueOfField: eachSource)]].
	^parameters
]

{ #category : #mapping }
ConditionalToManyMapping >> rowMapKeyForSource: source target: target index: index [
	^(self applicableMappingForObject: target) rowMapKeyForSource: source target: target index: index.
]
