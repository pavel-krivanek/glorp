"
My expression is a MappingExpression whose mapping is conditional.  When I have no row, I guess at my descriptor (and so my reference class) by using my mapping's representativeMapping.  When I have a row, I use that to find the actual descriptor for that row.

Instance Variables:
	rowMapping	<Mapping>	the mapping whose case matches the data in the row
"
Class {
	#name : #ConditionalBuilder,
	#superclass : #ObjectBuilder,
	#instVars : [
		'rowMapping'
	],
	#category : #GlorpQueries
}

{ #category : #'VisualWorks metadata' }
ConditionalBuilder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'building objects' }
ConditionalBuilder >> canBuild [
	"So far, this is only tested for the case that our rowMapping is our representativeMapping."

	^(row isNil or: [rowMapping isRelationship])
		ifTrue: [super canBuild]
		ifFalse: [requiresPopulating := false]
]

{ #category : #'building objects' }
ConditionalBuilder >> canCache [
	"So far, this is only tested for the case that our rowMapping is our representativeMapping."

	^(row isNil or:
		[rowMapping isRelationship])
			and: [super canCache]
]

{ #category : #accessing }
ConditionalBuilder >> fieldTranslations: aDictionary [
	"We need the conditionalValueMapping's field(s) to deduce our mapping for each row.  If any field is not in the dictionary then (it probably means the representativeMapping is an EmbeddedOneToOneMapping, and) we must add it.  The code that adds it below is an extract from
	SimpleQuery>>#addFields:returningTranslationForFields:distinct:
and assumes that the field, being missing from an embedded mapping, must be a field in the real table within which that mapping's fields were embedded."

	super fieldTranslations: aDictionary.
	expression mapping conditionalValueMapping mappedFields do: 
		[:each |
		aDictionary at: each ifAbsentPut:
			[query findPositionOfAliasedField: (expression base translateField: each)]].

"An alternative to ensuring that any conditionalField is translated here would be to have new method
	ConditionalBuilder>>fieldsFromMyPerspective
which added the field if missing;  it would then be translated along with the others."
]

{ #category : #copying }
ConditionalBuilder >> postCopy [
	super postCopy.
	rowMapping := nil.
]

{ #category : #accessing }
ConditionalBuilder >> row: anArray [
	super row: anArray.
	rowMapping := expression mapping applicableMappingForRow: row in: self.
]
