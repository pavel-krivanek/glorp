"
I am the element builder of a DirectTo*Mapping.  I get my value from the #myValue mapping of my relationship like a DaaElementBuilder but can knit it into my owning object like a ObjectBuilder.
"
Class {
	#name : #RelatedDataElementBuilder,
	#superclass : #ObjectBuilder,
	#category : #GlorpQueries
}

{ #category : #'VisualWorks metadata' }
RelatedDataElementBuilder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'building objects' }
RelatedDataElementBuilder >> buildObjectFrom: anArray [
	self row: anArray.
	instance := self valueOf: expression.
]

{ #category : #'selecting fields' }
RelatedDataElementBuilder >> fieldsFromMyPerspective [
	"We are the builder of a DirectTo*Mapping.  If the relationship is toMany, our mapping is sure to have an order field.  We must include its value in each row, not just order the collection of rows by its value, so we can distingush between genuinely duplicated elements (in an alsoFetch to Many) and distinct elements that just happen to be equal to each other (which is why we must have an order field)."

	^expression mapping isToManyRelationship
		ifFalse: [super fieldsFromMyPerspective]
		ifTrue: [super fieldsFromMyPerspective, (Array with: expression mapping orderField)]
]

{ #category : #'translating fields' }
RelatedDataElementBuilder >> indexOfValue [
	"This assumes a DirectToManyMapping will always writeTheOrderField, i.e. the orderField is integer and its values are one-one with their order in its collection."

	^self row atIndex: (self translateFieldPosition: expression mapping orderField)
]

{ #category : #'translating fields' }
RelatedDataElementBuilder >> valueOf: anExpression [
	| mapping |
	mapping := anExpression descriptor mappingForAttributeNamed: #myValue.
	^mapping valueInBuilder: self as: mapping field
]
