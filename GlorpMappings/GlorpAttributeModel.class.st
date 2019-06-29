"
This is the metadata for an individual instance variable. It will be held in a GlorpClassModel, and used for accessing the variable when building or writing out objects.

Instance Variables:
	attributeIndex	<Integer>	If we use instVarAt:{put:} to get/set values, cache the instance variable index in the class
	canRead	<Boolean>	May I read my value from the database and set it on the object?
	canWrite	<Boolean>	May I get my value from the object and write it to the database?
	classModel	<GlorpClassModel>	The class model that contains us.
	collectionType	<Class>	If we are an attribute that holds a collection, what is the class of the collection.
	keyType	<Class>	If we represent a dictionary attribute, what is the type of our key (type will hold the type of our value in that case).
	name	<Symbol>	The name of the attribute/instance variable (also the get selector)
	setSelector	<Symbol>	the selector I use for setting (if useDirectAccess false), lazily initialized to #<name>:
	type	<Class>	The class possessing the instance variable that I model
	useDirectAccess	<Boolean>	Do I use instVarAt:{put:} to access my attribute values (the default) or name{:} ?
"
Class {
	#name : #GlorpAttributeModel,
	#superclass : #Object,
	#instVars : [
		'name',
		'type',
		'collectionType',
		'keyType',
		'classModel',
		'attributeIndex',
		'useDirectAccess',
		'setSelector',
		'canRead',
		'canWrite'
	],
	#category : #GlorpMappings
}

{ #category : #'instance creation' }
GlorpAttributeModel class >> named: aSymbol [
	^self new name: aSymbol.
]

{ #category : #'instance creation' }
GlorpAttributeModel class >> named: aSymbol collection: aCollectionClass of: aClass [
	^(self new)
		name: aSymbol;
		type: aClass;
		collectionType: aCollectionClass.
]

{ #category : #'instance creation' }
GlorpAttributeModel class >> named: aSymbol collectionOf: aClass [
	^self named: aSymbol collection: OrderedCollection of: aClass.
]

{ #category : #'instance creation' }
GlorpAttributeModel class >> named: aSymbol dictionary: dictionaryClass from: keyClass to: valueClass [
	^(self new)
		name: aSymbol;
		type: valueClass;
		keyType: keyClass;
		collectionType: dictionaryClass.
]

{ #category : #'instance creation' }
GlorpAttributeModel class >> named: aSymbol dictionaryFrom: keyClass to: valueClass [
	^self named: aSymbol dictionary: Dictionary from: keyClass to: valueClass.
]

{ #category : #'instance creation' }
GlorpAttributeModel class >> named: aSymbol type: aClass [
	^self new name: aSymbol; type: aClass.
]

{ #category : #'instance creation' }
GlorpAttributeModel class >> new [
	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
GlorpAttributeModel class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #knitting }
GlorpAttributeModel >> add: anObject to: aCollection in: ourObject [
	"Don't add nil keys.  An empty dictionary can produce nil->nil keys."

	(anObject class == Association and: [anObject key == nil])
		ifFalse: [aCollection add: anObject].
]

{ #category : #converting }
GlorpAttributeModel >> beAttributeClass: anAttributeClass [
	"Create an instance of the new attribute class, copy my properties to it, and replace me with it in my class model.  Either this is done immediately after my definition (i.e. no mapping is using me) or else any mappings that do use me must be re-sent #attributeName: after this method is called."

	self class == anAttributeClass ifTrue: [^self].
	^classModel
		privateAndBasicAtAttribute: self
		put: ((anAttributeClass named: name) copyFrom: self)

"Require the user to call this method during the attribute's definition, before any mapping references me, or then to call #attributeName: on any mappings they know are affected.  Uncommenting the code below ...
	classModel system allDescriptors do:
		[:eachDescriptor |
		eachDescriptor mappings do:
			[each attribute == oldAttribute ifTrue: [each attributeName: name]]].
... would change the order of initialization of class models and descriptors, which might possibly be undesirable."
]

{ #category : #accessing }
GlorpAttributeModel >> beForPseudoVariable [
	"Make me a pseudo-variable:  one which is neither read nor written, and doesn't have a corresponding instance variable, but is usable in a Query's whereClause (or its ordering or grouping, etc.)."

	canRead := false.
	canWrite := false.
]

{ #category : #accessing }
GlorpAttributeModel >> canRead [
	^canRead
]

{ #category : #accessing }
GlorpAttributeModel >> canRead: aBoolean [
	canRead := aBoolean
]

{ #category : #accessing }
GlorpAttributeModel >> canWrite [
	^canWrite
]

{ #category : #accessing }
GlorpAttributeModel >> canWrite: aBoolean [
	canWrite := aBoolean
]

{ #category : #'get/set' }
GlorpAttributeModel >> checkTargetType: anObject [
	"Check that anObject's type corresponds to something we know how to handle for this attribute. We expect this to be a real object, not a collection."
	self checkTargetType: anObject against: self type.
]

{ #category : #'get/set' }
GlorpAttributeModel >> checkTargetType: anObject against: aClass [
	"Check that anObject's type corresponds to aClass, which we expect as our values.  If the attribute is a collection, we expect this to be called inside the iteration on each contained object, not on the collection."

	| targetModel |
	anObject glorpRealObject isNil ifTrue: [^self].
	aClass isNil ifTrue: [self error: 'No type to check against in class model'].
	anObject glorpIsCollection ifTrue:
		[(GlorpInvalidTypeError new object: anObject; expectedType: self collectionType) signal].
	targetModel := self system classModelFor: aClass.
	targetModel notNil ifTrue:
		[(targetModel matches: anObject) ifFalse:
			[(GlorpInvalidTypeError new object: anObject; expectedType: aClass) signal]].
]

{ #category : #'get/set' }
GlorpAttributeModel >> checkTargetTypeForKey: aKey value: anObject [
	"Check that anObject's type corresponds to something we know how to handle for this attribute. We expect this to be a real object, not a collection. This is the version used for checking a dictionary, where we check both key and value, but only if they correspond to mapped classes."
	(self system classModelFor: self keyType) isNil 
		ifFalse: [self checkTargetType: aKey against: self keyType].
	(self system classModelFor: self type) isNil
		ifFalse: [self checkTargetType: anObject against: type].
]

{ #category : #'get/set' }
GlorpAttributeModel >> checkType: anObject [
	(self classModel matches: anObject)
		ifFalse: [self error: 'Wrong type of object'].
]

{ #category : #accessing }
GlorpAttributeModel >> classModel [
	^classModel
]

{ #category : #accessing }
GlorpAttributeModel >> classModel: aGlorpClassModel [
	classModel := aGlorpClassModel
]

{ #category : #accessing }
GlorpAttributeModel >> collectionType [
	^collectionType
]

{ #category : #accessing }
GlorpAttributeModel >> collectionType: aClass [
	collectionType := aClass
]

{ #category : #copying }
GlorpAttributeModel >> copyFrom: anAttributeModel [
	"Copy over the attributes if it defines them and we don't."

	anAttributeModel isNil ifTrue: [^self].
	type isNil ifTrue: [self type: anAttributeModel type].
	collectionType isNil ifTrue:
		[self collectionType: anAttributeModel collectionType].
	useDirectAccess isNil ifTrue:
		[useDirectAccess := anAttributeModel privateUseDirectAccess].
	canRead := anAttributeModel canRead.
	canWrite := anAttributeModel canWrite.
]

{ #category : #private }
GlorpAttributeModel >> directGetValueFrom: anObject [ 
	| index |
	index := self instVarIndexIn: anObject.
	index = 0 ifTrue: [self raiseInvalidAttributeError].
	^anObject instVarAt: index
]

{ #category : #private }
GlorpAttributeModel >> directSetValueIn: anObject to: aValue [ 
	| index |
	index := self instVarIndexIn: anObject.
	index = 0 ifTrue: [self raiseInvalidAttributeError].
	^anObject instVarAt: index put: aValue
]

{ #category : #'get/set' }
GlorpAttributeModel >> getValueFrom: anObject [
	| real |
	real := anObject glorpRealObject.
	self checkType: real.
	self useDirectAccess ifTrue: [^self directGetValueFrom: real].
	^real perform: self name.
]

{ #category : #initialization }
GlorpAttributeModel >> initialize [
	canRead := true.
	canWrite := true.
]

{ #category : #private }
GlorpAttributeModel >> instVarIndex [
	| soughtName |
	attributeIndex == nil ifFalse: [^attributeIndex].
	soughtName := Dialect instVarNameFor: name.
	^attributeIndex := self classModel describedClass allInstVarNames 
				indexOf: soughtName
]

{ #category : #private }
GlorpAttributeModel >> instVarIndexIn: anObject [ 
	^self instVarIndex
]

{ #category : #validation }
GlorpAttributeModel >> isCollectionAttribute [
	^collectionType notNil.
]

{ #category : #mapping }
GlorpAttributeModel >> isDictionaryAttribute [
	^collectionType isBehavior and: [collectionType includesBehavior: Dictionary].
]

{ #category : #testing }
GlorpAttributeModel >> isForPseudoVariable [
	"Return true if this is a pseudo-variable - one which is neither read nor written, and doesn't have a corresponding instance variable, but is only used for queries."
	^(canRead not & canWrite not) or: [self isValid not].
]

{ #category : #validation }
GlorpAttributeModel >> isReadable [
	"An attribute can be:
		- readable from the database, i.e. settable on its object
		- writable to the database, i.e. gettable from its object
		- both (the default)
		- neither, i.e. a pseudoVariable, usable in a Glorp where block but not on its object
We check that reading from the database is authorised, and that a setter is implemented on the object."

	self canRead ifFalse: [^false].
	^self useDirectAccess 
		ifTrue: [self instVarIndex > 0]
		ifFalse: [self classModel describedClass canUnderstand: self setSelector]
]

{ #category : #private }
GlorpAttributeModel >> isValid [
	^name notNil and: [classModel notNil].
]

{ #category : #validation }
GlorpAttributeModel >> isWritable [
	"An attribute can be:
		- readable from the database, i.e. settable on its object
		- writable to the database, i.e. gettable from its object
		- both (the default)
		- neither, i.e. a pseudoVariable, usable in a Glorp block but not on its object
We check that writing to the database is authorised, and that a getter is implemented on the object."

	self canWrite ifFalse: [^false].
	^self useDirectAccess 
		ifTrue: [self instVarIndex > 0]
		ifFalse: [self classModel describedClass canUnderstand: self name]
]

{ #category : #accessing }
GlorpAttributeModel >> keyType [
	^keyType
]

{ #category : #accessing }
GlorpAttributeModel >> keyType: aClass [
	keyType := aClass
]

{ #category : #knitting }
GlorpAttributeModel >> knit: ourObject to: anotherObject [
	"We are a collection attribute that is being asked to add anotherObject to our collection, which is owned by ourObject (if we were not a collection attribute, our caller would simply call #setValueIn:to:).  If we are setting a new collection, or expanding an Array, add the objects to the collection before setting the collection on the owning object, in case we are not using direct access and the setter expects to iterate over them.  Return the collection containing the new object (or containing another object that is equal to it)."

	| collection | collection := self getValueFrom: ourObject.
	"we must ask whether the collection isGlorpProxy before asking if it isNil"
	(collection isGlorpProxy and: [collection isInstantiated not])
		ifFalse:	"see note at end of method for why we check #includes:"
			[(collection includes: anotherObject) ifTrue: [^collection].
			collection class == Array	"can't add to array; must concatenate and re-set value"
				ifTrue: [collection := collection copyWith: anotherObject]
				ifFalse: [self add: anotherObject to: collection in: ourObject.
						^collection]]	"return here to avoid re-setting value"
		ifTrue:
			[collection := self newCollection.
			collection class == Array
				ifTrue:  [collection := Array with: anotherObject]
				ifFalse: [self add: anotherObject to: collection in: ourObject]].
		^self setValueIn: ourObject to: collection.
	

"Why do we check if the collection #includes: our object?
====================================
We knit an #alsoFetch:ed collection by having a row for each object in the collection.  The resulting #alsoFetch:ed rows, obtained by joining various tables, can repeat the data for an object in one collection while providing fresh data for an object in another collection. and can also be nested, with an object in one collection holding objects in another collection.  Thus we could read the same object twice.  If the builder canCache (i.e. the potentially-retreated object has primaryKey fields, then the object will be retrieved from the cache on the second iteration and will be identical.  Otherwise it will be equal, not identical.

For example, the first two rows read by #testKnittingWithAlsoFetchDoubleToMany are
	#(1 'Alan' 1 '001' '001' '123' 1 1 #CDN 1.5 'stuff' #CDN 1)
	#(1 'Alan' 1 '001' '001' '123' 2 1 #USD 1.5 'stuff' #USD 1)
The customer (the object we will return, defined in columns 1 and 2) is the same for both, as is the account (defined in columns 3, 4, 5 and 6), while the transaction varies.  The account is handled by the inlcudes: check above.  The customer - the object returned - is handled in #hasCompleteAnswerFor: (see its comment).

- If the builder can cache, the guard relates to objects retrieved from the cache and should be a == check, or so it seems to me.  In this case, #includes: would be unsafe if an equal non-identical object could already be in the collection;  #hasCompleteAnswerFor: is careful to use identity in this case.

- If the builder cannot cache, we must use #includes: but now have the problem that any SequenceableCollection could naturally have two equal but non-identical objects.  How do we know whether the guard is right or wrong?

TBD."
]

{ #category : #knitting }
GlorpAttributeModel >> knit: ourObject to: anotherObject at: index [
	"We are a collection attribute of a mapping that, via #writeTheOrderField or otherwise, knows (and ensures the reading of) the indices of its elements."

	| collection |
	collection := self knit: ourObject to: anotherObject.
	collection size = (index - 1)
		ifFalse:
			[(collection at: index) == anotherObject
				ifFalse: [collection at: index put: anotherObject]]
		ifTrue:
			[collection class == Array
				ifFalse: [collection add: anotherObject]
				ifTrue: [self
						setValueIn: ourObject
						to: (collection := collection , Array with: anotherObject)]].
	^collection
]

{ #category : #mapping }
GlorpAttributeModel >> loopOver: mightBeACollection doing: aBlock [
	"It is possible that the value for a dictionary attribute is nil. If so, do not map it back"
	| index |
	self isCollectionAttribute ifFalse: [self checkTargetType: mightBeACollection. ^aBlock value: 1 value: mightBeACollection].
	mightBeACollection isNil ifTrue: [^nil].
	self isDictionaryAttribute ifTrue: [^mightBeACollection keysAndValuesDo: [:key :value |
		self checkTargetTypeForKey: key value: value. 
		value ifNotNil: [aBlock value: key value: value]]].
	index := 1.
	mightBeACollection glorpIsCollection ifFalse: [
		(GlorpInvalidTypeError new object: mightBeACollection; expectedType: self collectionType) signal].
	mightBeACollection
		do:
			[:each |
			| object | 
			object := each glorpRealObject. 
			self checkTargetType: object.
			aBlock value: index value: object.
			index := index + 1].
]

{ #category : #accessing }
GlorpAttributeModel >> name [
	^name isNil ifTrue: [''] ifFalse: [name]
]

{ #category : #accessing }
GlorpAttributeModel >> name: aSymbol [
	| symbol |
	symbol := aSymbol isNil ifTrue: [aSymbol] ifFalse: [aSymbol asSymbol].
	name := symbol.
]

{ #category : #private }
GlorpAttributeModel >> newCollection [
	collectionType == GlorpVirtualCollection ifTrue: [^OrderedCollection new].
	^collectionType isBehavior
		ifTrue: [collectionType new]
		ifFalse: [collectionType copyEmpty: collectionType size]
]

{ #category : #printing }
GlorpAttributeModel >> printOn: aStream [
	aStream nextPutAll: self classModel printString, '>>', self name.
]

{ #category : #private }
GlorpAttributeModel >> privateAndbasicSetInstVarIndex: anInteger [
	"Our superclass may use our mapping conditionally but be unable to set the index."

	attributeIndex := anInteger.
]

{ #category : #private }
GlorpAttributeModel >> privateUseDirectAccess [
	^useDirectAccess.
]

{ #category : #private }
GlorpAttributeModel >> raiseInvalidAttributeError [
	self error: 'Invalid attribute: ', classModel printString, '>>', name printString.
]

{ #category : #private }
GlorpAttributeModel >> setSelector [
	setSelector  == nil ifTrue: [setSelector := (name, ':') asSymbol].
	^setSelector.
]

{ #category : #'get/set' }
GlorpAttributeModel >> setValueIn: anObject to: aValue [ 
	| real |
	self isValid ifFalse: [^aValue].
	real := anObject glorpRealObject.
	self checkType: real.
	self useDirectAccess ifTrue: [^self directSetValueIn: real to: aValue].
	^real perform: self setSelector with: aValue
]

{ #category : #accessing }
GlorpAttributeModel >> system [
	classModel isNil ifTrue: [^nil].
	^classModel system.
]

{ #category : #accessing }
GlorpAttributeModel >> type [
	^type
]

{ #category : #accessing }
GlorpAttributeModel >> type: aClass [
	type := aClass
]

{ #category : #testing }
GlorpAttributeModel >> useDirectAccess [
	useDirectAccess isNil ifFalse: [^useDirectAccess].
	self system isNil ifTrue: [^true].  "A global default, although only applicable if we're not in a valid setup"
	^self system useDirectAccessForMapping.
]

{ #category : #accessing }
GlorpAttributeModel >> useDirectAccess: aBoolean [
	useDirectAccess := aBoolean.
]

{ #category : #validation }
GlorpAttributeModel >> validate [
	name isEmpty ifTrue: [self error: 'Invalid attribute name']
]

{ #category : #validation }
GlorpAttributeModel >> validateCanRead [
	self isReadable ifFalse: [self raiseInvalidAttributeError]
]

{ #category : #validation }
GlorpAttributeModel >> validateCanWrite [
	self isWritable ifFalse: [self raiseInvalidAttributeError]
]
