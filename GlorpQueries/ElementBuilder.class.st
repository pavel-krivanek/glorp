"
This is the abstract superclass of builders. These assemble information, either primitive data or objects, from a database result set.

Subclasses must implement the following messages:
	building objects
		buildObjectFrom:
		findInstanceForRow:useProxy:
	selecting fields
		fieldsFromMyPerspective
and should review whether API methods
	buildsObjects
	knitResultIn:
will need overriding.  (The remaining externally-called API is #cursor: and #onCompoundCursor:, #expression, #instance, #hasSetPrimaryKey and #sendPostFetchValidateIn:onFailureDo:, all rarely changed in subclasses.)

Instance Variables:
	expression	<MappingExpression>	The expression we're mapping. e.g. if the query is reading people, this might be the expression corresponding to ""each address"", meaning that we build the address object related to the main Person instance by the given relationship. 
	fieldTranslations	<Array of: Integer>	 The translation of the field positions from where they are in the descriptor to where they are in the row we're reading. This is done so we can read the rows efficiently, by index, rather than doing lots of dictionary lookups by name. If we're doing a simple read, the translations will probably be a no-op, but if we read multiple objects, some of the fields will be in different positions than they are in our table definition.
	instance	<Object>	The thing we're constructing.
	isExpired	<Boolean>	If our instance is in cache, we use that instead. However, if the instance has expired, then we do something different (most likely force a refresh) than if it's still alive.
	key	<Object>	The key for this row. This is lazily computed, and ""self"" is used a special marker to indicate that it hasn't been computed yet.
	query	<AbstractReadQuery>	the query that we're building results for.
	requiresPopulating	<Boolean>	Do we need to populate the object. Will be false if the object was found in cache and hasn't expired.
	row	<Array>	The database results. May actually be a result set row of some sort rather than an array, depending on the dialect, but should always respond to indexing protocol.


"
Class {
	#name : #ElementBuilder,
	#superclass : #Object,
	#instVars : [
		'instance',
		'requiresPopulating',
		'key',
		'expression',
		'cursor',
		'fieldTranslations',
		'isExpired',
		'row',
		'query'
	],
	#category : #'GlorpQueries-Glorp'
}

{ #category : #private }
ElementBuilder class >> basicClassFor: anExpression in: aQuery [
	"If anExpression hasDescriptor then it is a BaseExpression with a descriptor or a MappingExpression whose mapping is a relationship."

	anExpression hasDescriptor ifFalse: [^DataElementBuilder].
	"To get here, anExpression is either a BaseExpression with descriptor or ..."
	anExpression canKnit ifFalse:
		[^anExpression mapsSimpleObject ifTrue: [DataElementBuilder] ifFalse: [ObjectBuilder]].
	"... (to get here) it is a MappingExpression whose mapping is a relationship and cannot be a DictionaryMapping (caller intercepts)."
	anExpression mapsSimpleObject ifTrue: [^RelatedDataElementBuilder].
	anExpression mapping class == ConditionalMapping ifTrue: [^ConditionalBuilder].
	^ObjectBuilder
]

{ #category : #'instance creation' }
ElementBuilder class >> basicFor: anExpression in: aQuery [

	^(self basicClassFor: anExpression in: aQuery) new
		expression: anExpression;
		query: aQuery;
		setup.
]

{ #category : #private }
ElementBuilder class >> classFor: anExpression in: aQuery [
	
	((aQuery returnsDictionary and: [anExpression == aQuery baseExpression])
		or: [anExpression returnsDictionary])
			ifTrue: [^DictionaryBuilder].
	^self basicClassFor: anExpression in: aQuery.
]

{ #category : #'instance creation' }
ElementBuilder class >> for: anExpression in: aQuery [

	^(self classFor: anExpression in: aQuery) new
		expression: anExpression;
		query: aQuery;
		setup.
]

{ #category : #'instance creation' }
ElementBuilder class >> new [

	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
ElementBuilder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #'building objects' }
ElementBuilder >> buildObjectFrom: anArray [ 
	self subclassResponsibility.
]

{ #category : #testing }
ElementBuilder >> buildsObjects [
	^false.
]

{ #category : #copying }
ElementBuilder >> cacheBuilderRelationships: aCollection [
	"By the time this is called, SimpleQuery has all our builders, so subclasses can cache the one to which they will knit, if any."
]

{ #category : #accessing }
ElementBuilder >> canCauseDuplicateRows [
	^false.
]

{ #category : #copying }
ElementBuilder >> copy [
	^self shallowCopy postCopy.
]

{ #category : #accessing }
ElementBuilder >> cursor [
	^cursor
]

{ #category : #accessing }
ElementBuilder >> cursor: aGlorpCursoredStream [
	"I am expected to return self by #onCompoundCursor:."

	cursor := aGlorpCursoredStream.
]

{ #category : #'building objects' }
ElementBuilder >> didValidationFail: validateResult [
	^validateResult == false.
]

{ #category : #accessing }
ElementBuilder >> expression [
	^expression
]

{ #category : #accessing }
ElementBuilder >> expression: anExpression [
	expression := anExpression.
]

{ #category : #accessing }
ElementBuilder >> fieldTranslations [
	^fieldTranslations
]

{ #category : #accessing }
ElementBuilder >> fieldTranslations: aDictionary [ 
	fieldTranslations := aDictionary.
]

{ #category : #'selecting fields' }
ElementBuilder >> fieldsForSelectStatement [

	^self subclassResponsibility.
]

{ #category : #'selecting fields' }
ElementBuilder >> fieldsFromMyPerspective [
	self subclassResponsibility.
]

{ #category : #'building objects' }
ElementBuilder >> findInstanceForRow: aRow proxyType: proxyType [
	self subclassResponsibility.
]

{ #category : #executing }
ElementBuilder >> hasFieldTranslations [
	^self fieldTranslations notNil
]

{ #category : #testing }
ElementBuilder >> hasSetPrimaryKey [
	"I set key to self when I get a row (which we assume has happened before this is called).  Has it been reset to the row's primaryKey?"

	^key ~~ self
]

{ #category : #initializing }
ElementBuilder >> initialize [
]

{ #category : #accessing }
ElementBuilder >> instance [
	^instance
]

{ #category : #accessing }
ElementBuilder >> instanceValue [
	^instance
]

{ #category : #'building objects' }
ElementBuilder >> knitResultIn: aSimpleQuery [
	"Connect up our built object with any other builders that use the same thing"

	^self.
]

{ #category : #copying }
ElementBuilder >> onCompoundCursor: aGlorpCursoredStream [
	"This implementor returns self;  subimplementors may not."

	^self cursor: aGlorpCursoredStream
]

{ #category : #copying }
ElementBuilder >> postCopy [
	instance := nil.
	row := nil.
	requiresPopulating := false.
	isExpired := false.
]

{ #category : #accessing }
ElementBuilder >> query [
	^query
]

{ #category : #accessing }
ElementBuilder >> query: aQuery [ 
	query := aQuery
]

{ #category : #copying }
ElementBuilder >> reconcileWithBuilders: oldCollection andCopy: newCollection [
	"Subclasses with already-computed references to other builders must now reset them to be references to the copy."
]

{ #category : #'building objects' }
ElementBuilder >> registerObjectInUnitOfWork [
	"If there is a current unit of work, then we must register in it, after population because that way the state is already in place. The nil checks are mostly for safety during unit tests, as those conditions should never occur in real use"
	query isNil ifTrue: [^self].
	query session isNil ifTrue: [^self].
	query session register: instance.
]

{ #category : #accessing }
ElementBuilder >> requiresDistinct [

	^expression requiresDistinct.
]

{ #category : #accessing }
ElementBuilder >> requiresPopulating [
	^true
]

{ #category : #accessing }
ElementBuilder >> returnValueIn: aCursoredStream [
	^self instance
]

{ #category : #accessing }
ElementBuilder >> row [
	^row
]

{ #category : #accessing }
ElementBuilder >> row: anArray [
	"Since nil is a possible key value, use self as a special marker to indicate we haven't found the key yet.  Logically we could check equality, not identity, of row and anArray - that would equally well guarantee that the primaryKey value(s), if present, were the same.  However a row could be huge and equality comparison very slow.  It is arguably both safer and quicker to re-extract the primaryKey value(s) from anArray if it is not identical to the prior row."

	row == anArray ifFalse: [key := self].
	row := anArray.
]

{ #category : #'building objects' }
ElementBuilder >> sendPostFetchValidateIn: aSession onFailureDo: aBlock [
	| validateResult |
	validateResult := aSession sendPostFetchValidateEventTo: self instance.
	(self didValidationFail: validateResult) ifTrue: aBlock.
]

{ #category : #accessing }
ElementBuilder >> session [
	^expression descriptor session.
]

{ #category : #initializing }
ElementBuilder >> setup [
	"Do any initialization required once we've got our parameters"
	^self.
]

{ #category : #accessing }
ElementBuilder >> subBuilders [
	^#().
]

{ #category : #accessing }
ElementBuilder >> system [
	^self session system.
]

{ #category : #'translating fields' }
ElementBuilder >> translateFieldPosition: aDatabaseField [ 
	fieldTranslations isNil ifTrue: [^aDatabaseField position].
	^fieldTranslations at: aDatabaseField.
]

{ #category : #accessing }
ElementBuilder >> withAllSubBuilders [
	^Array with: self.
]
