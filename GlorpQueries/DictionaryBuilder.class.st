"
This is a subclass of builders that builds dictionaries. Basically it needs to build both the key and the value and then assemble them into a dictionary.

Instance Variables:
	keyBuilder	<ElementBuilder>	The builder for the key
	valueBuilder	<ElementBuilder>	The builder for the value.


"
Class {
	#name : #DictionaryBuilder,
	#superclass : #ElementBuilder,
	#instVars : [
		'keyBuilder',
		'valueBuilder',
		'relatedBuilder'
	],
	#category : #GlorpQueries
}

{ #category : #'VisualWorks metadata' }
DictionaryBuilder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'building objects' }
DictionaryBuilder >> buildObjectFrom: anArray [
	"We just build an association out of the sub-builders "
	| |
	self row: anArray.
]

{ #category : #copying }
DictionaryBuilder >> cacheBuilderRelationships: aCollection [
	"Clone of ObjectBuilder>>cacheBuilderRelationships:"

	expression canKnit ifFalse: [^self].
	relatedBuilder := aCollection
		detect: [:each | each buildsObjects and: [each expression == expression base]]
		ifNone: [nil].
]

{ #category : #accessing }
DictionaryBuilder >> canCauseDuplicateRows [
	^expression class == MappingExpression and: [expression mapping isToManyRelationship].
]

{ #category : #'selecting fields' }
DictionaryBuilder >> fieldsForSelectStatement [
	^#()
]

{ #category : #'selecting fields' }
DictionaryBuilder >> fieldsFromMyPerspective [
	^#()
]

{ #category : #'building objects' }
DictionaryBuilder >> findInstanceForRow: aRow proxyType: proxyType [

	instance := Association new.
]

{ #category : #accessing }
DictionaryBuilder >> instanceValue [
	^self instance value
]

{ #category : #'building objects' }
DictionaryBuilder >> knitResultIn: aCursoredStream [
	"Populate our built association with its key and value, then repeat the code of ObjectBuilder>>knitResultIn:."

	instance key: keyBuilder instance.
	instance value: valueBuilder instance.

	"Clone of ObjectBuilder>>knitResultIn:"
	expression canKnit ifFalse: [^self].
	relatedBuilder isNil ifTrue: [^self].
	relatedBuilder instance isNil ifTrue: [^self].
	expression mapping knitFromBuilder: relatedBuilder toBuilder: self.
]

{ #category : #copying }
DictionaryBuilder >> postCopy [
]

{ #category : #copying }
DictionaryBuilder >> reconcileWithBuilders: oldCollection andCopy: newCollection [
	"Fix up references to our association sub-builders, then repeat the code of ObjectBuilder>>reconcileWithBuilders:andCopy:."

	| initialValueQuery |
	keyBuilder := newCollection at: (oldCollection indexOf: keyBuilder).
	valueBuilder := newCollection at: (oldCollection indexOf: valueBuilder).

	"Clone of ObjectBuilder>>reconcileWithBuilders:andCopy:"
	relatedBuilder isNil ifTrue: [^self].
	relatedBuilder := newCollection at: (oldCollection indexOf: relatedBuilder).
	"Ensure my relatedBuilder does not redundantly try to get my value."
	initialValueQuery := ShortCircuitQuery new.
	expression mapping attribute isCollectionAttribute ifTrue:
		[initialValueQuery resultTemplate: expression mapping attribute newCollection].
	relatedBuilder cachedQueryFor: expression mapping put: initialValueQuery
]

{ #category : #'initialize-release' }
DictionaryBuilder >> setup [
	"We now have our expression and our query.  Use them to set our key and value builders."

	| base collectionType |
	base := query baseExpression.
	collectionType := expression == base ifTrue: [query collectionType] ifFalse: [expression mapping query collectionType].
	keyBuilder := ElementBuilder for: (collectionType keyExpression asGlorpExpressionOn: expression) in: query.
	valueBuilder := ElementBuilder basicFor: (collectionType valueExpression asGlorpExpressionOn: expression) in: query.
]

{ #category : #accessing }
DictionaryBuilder >> subBuilders [
	^Array with: keyBuilder with: valueBuilder.
]

{ #category : #accessing }
DictionaryBuilder >> withAllSubBuilders [
	^Array with: self with: keyBuilder with: valueBuilder.
]
