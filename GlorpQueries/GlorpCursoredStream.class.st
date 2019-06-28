"
This is a Glorp wrapper for a database cursor. It has stream-like behaviour, which is implemented by getting rows from the underlying cursor and constructing the objects as required. All queries go through one of these streams, although in the default case they will get all the results out of it (at which point the cursor will be closed) and then return them in another kind of collection. But it's possible to use one of these as the return type, in which case you can make use of the open cursor to incrementally get results.

Instance Variables:
	builders	<(Collection of: ObjectBuilder)>	The ObjectBuilders used to construct the objects we return out of the rows.
	buildersThatReturnResults	<(SequenceableCollection of: ElementBuilder)>	
	command	<DatabaseCommand>	The command that was executed to give us this cursor.
	cursor	<>	The underlying database cursor. Class varies by dialect. We deal with the lack of polymorphism by indirecting all cursor operations through the accessor.
	databaseAccessor	<DatabaseAccessor>	The accessor that the command was executed against.
	mightHaveDuplicateRows	<Boolean>	May this stream have duplicate rows? This can happen, for example, if we do a join that causes some sub-section of the row to be duplicated. If so, we need to check for this and remove duplicates from the object stream as we go. This forces us to peek ahead.
	peekBuffer	<Object>	The peek buffer (holding an object) that we use when peeking ahead.
	rawPeekBuffer	<>	The peek buffer (holding a row) that we use when peeking ahead. We need to buffer at both levels.
	statement	<GlorpPreparedStatement>	The actual prepared statement that the command ran in order to get our results.


"
Class {
	#name : #GlorpCursoredStream,
	#superclass : #Stream,
	#instVars : [
		'command',
		'cursor',
		'mightHaveDuplicateRows',
		'builders',
		'buildersThatReturnResults',
		'databaseAccessor',
		'peekBuffer',
		'rawPeekBuffer',
		'statement'
	],
	#category : #GlorpQueries
}

{ #category : #'instance creation' }
GlorpCursoredStream class >> on: aStream [
	^self basicNew cursor: aStream.
]

{ #category : #'instance creation' }
GlorpCursoredStream class >> on: aStream accessor: aDatabaseAccessor [
	^(self on: aStream)
		databaseAccessor: aDatabaseAccessor.
]

{ #category : #'instance creation' }
GlorpCursoredStream class >> on: aStream for: aCommand [
	^(self on: aStream)
		command: aCommand.
]

{ #category : #'instance creation' }
GlorpCursoredStream class >> on: aStream for: aCommand accessor: aDatabaseAccessor [
	^(self on: aStream)
		command: aCommand;
		databaseAccessor: aDatabaseAccessor.
]

{ #category : #'VisualWorks metadata' }
GlorpCursoredStream class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #testing }
GlorpCursoredStream >> accessor [
	^databaseAccessor.
]

{ #category : #'building objects' }
GlorpCursoredStream >> buildObjectsForRow: aRow [
	self query isNil ifTrue: [^aRow].
	builders
		do:
			[:each | each findInstanceForRow: aRow proxyType: self query proxyType].
	builders do: [:each | each buildObjectFrom: aRow].
	builders
		do:
			[:each | 
			each
				sendPostFetchValidateIn: self session 
				onFailureDo: [each instance: nil]].
	builders
		do: [:each | each instance == nil ifFalse: [each knitResultIn: self]].
	builders do: [:each | self session sendPostFetchEventTo: each instance].
	^self buildersThatReturnResults size = 1
		ifTrue: [self buildersThatReturnResults first returnValueIn: self]
		ifFalse:
			[self buildersThatReturnResults collect: [:each | each returnValueIn: self]].
]

{ #category : #'building objects' }
GlorpCursoredStream >> buildersThatReturnResults [
	"In late 2004, Alan Knight wrote here, 'For some bizarre reason, #includes: fails on ObjectStudio for this', to explain why he used #detect:ifNone: instead of #include. to find a builder's expression in the query's retrievalExpressions.  This is no longer the case:  tests on ObjectStudio 8.9 indicate #includes: is safe to use.  However, although the collection iterated over is a Set, not an IdentitySet, Alan uses ==, not = in both the #detect:ifNone: and the #anySatisfy:.  Currently, that makes no difference for GlorpExpression and subclasses, in which = is never overridden.  Nevetheless it would be inconsistent to check = in one statement and == in the next statement.  I have therefore kept the use of #detect:ifNone: for now.  If GlorpExpression>>= is ever overridden, this comment can guide changes."

	buildersThatReturnResults isNil ifTrue:
		[buildersThatReturnResults := OrderedCollection new.
		builders do:
			[:each || expression shouldNotBeRetrieved |
			expression := each expression.
			shouldNotBeRetrieved := (self query tracing retrievalExpressions
				detect: [:foo | foo == expression] ifNone: [nil]) isNil.
			(shouldNotBeRetrieved or:
				[buildersThatReturnResults anySatisfy:
					[:eachBuilder | eachBuilder expression == expression]])
				ifFalse: [buildersThatReturnResults add: each]].
		buildersThatReturnResults := buildersThatReturnResults asArray].
	^buildersThatReturnResults
]

{ #category : #iterating }
GlorpCursoredStream >> collect: aBlock [ 
	| newStream |
	newStream := WriteStream on: (Array new: 100).
	[self atEnd] whileFalse: [newStream nextPut: (aBlock value: self next)].
	^newStream contents
]

{ #category : #'building objects' }
GlorpCursoredStream >> collectionTypeFor: aCollectionType [
	"Make sure that we can reasonably return aCollectionType. If not, default to something we can"

	aCollectionType class == GlorpDictionaryDescription ifFalse: [^aCollectionType].
	self buildersThatReturnResults size = 1 ifTrue: [^aCollectionType].
	^Array.
]

{ #category : #accessing }
GlorpCursoredStream >> command [
	^command
]

{ #category : #accessing }
GlorpCursoredStream >> command: aDatabaseCommand [
	command := aDatabaseCommand.
	aDatabaseCommand isNil ifTrue: [^self].
	aDatabaseCommand query isNil ifTrue: [^self].
	databaseAccessor := aDatabaseCommand query session accessor.
	builders := self query copyOfBuildersFor: self.
]

{ #category : #accessing }
GlorpCursoredStream >> contents [
	self shouldNotImplement.
]

{ #category : #accessing }
GlorpCursoredStream >> cursor [
	^cursor
]

{ #category : #accessing }
GlorpCursoredStream >> cursor: aStream [
	cursor := aStream
]

{ #category : #accessing }
GlorpCursoredStream >> databaseAccessor: aDatabaseAccessor [
	databaseAccessor := aDatabaseAccessor
]

{ #category : #iterating }
GlorpCursoredStream >> detect: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument.
	Answer the first element for which aBlock evaluates to true."

	^self detect: aBlock ifNone: [self error: 'not found']
]

{ #category : #iterating }
GlorpCursoredStream >> detect: aBlock ifNone: exceptionBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument.
	Answer the first element for which aBlock evaluates to true."

	self do: [:each | (aBlock value: each) ifTrue: [^each]].
	^exceptionBlock value
]

{ #category : #iterating }
GlorpCursoredStream >> do: aBlock [ 
	"Evaluate aBlock for each of the elements of the receiver."

	[self atEnd]
		whileFalse: [aBlock value: self next]
]

{ #category : #'building objects' }
GlorpCursoredStream >> elementBuilderFor: anExpression [ 
	^builders detect: [:each | each expression == anExpression] ifNone: [nil].
]

{ #category : #accessing }
GlorpCursoredStream >> flush [
	^self.
]

{ #category : #'building objects' }
GlorpCursoredStream >> hasCompleteAnswerFor: objects [
	"If we are alsoFetching a toMany relationship, multiple rows can have the same data for the source of that relationship, differing only in their data for its targets.  If the source has primaryKey(s), these second and subsequent rows will obtain the identically same instance from the cache and an identity comparison suffices, because if a builder that returns a result has a primaryKey with which to fetch an instance out of the cache and its next answer is in fact the same object as its last answer, built from a row of the same data (with, presumably, differing alsoFetch data further along), it will have the same primaryKey(s) and so obtain the identically-same object.  In the absence of primaryKeys, it will merely be an equal but non-identical object, so we are obliged to require that such objects do compare equal (i.e. they'll need to define = and hash) and that genuinely different objects do _not_ compare equal.  Fortunately, it is rare that the base of an #alsoFetch:ing query does not have primaryKey(s)."

	| nextAnswer |
	self atEnd ifTrue: [^true].
	self mightHaveDuplicateRows ifFalse: [^true].
	nextAnswer := self peek.
	"Access instvar directly to avoid its lazy initialization accessor (obviously, for the first line)."
	buildersThatReturnResults isNil ifTrue: [^objects ~= nextAnswer].
	buildersThatReturnResults size = 1 ifTrue:
		[^buildersThatReturnResults first hasSetPrimaryKey
			ifTrue: [objects ~~ nextAnswer]
			ifFalse: [objects ~= nextAnswer]].
	1 to: buildersThatReturnResults size do:
		[:index |
		(buildersThatReturnResults at: index) hasSetPrimaryKey
			ifTrue: [(objects at: index) ~~ (nextAnswer at: index) ifTrue: [^true]]
			ifFalse: [(objects at: index) ~= (nextAnswer at: index) ifTrue: [^true]]].
	^buildersThatReturnResults isEmpty	"probably needless in actual production to use this instead of false;  makes development safer"
]

{ #category : #initializing }
GlorpCursoredStream >> initialize [
]

{ #category : #testing }
GlorpCursoredStream >> isReadable [
	^true.
]

{ #category : #testing }
GlorpCursoredStream >> isWritable [
	^false.
]

{ #category : #accessing }
GlorpCursoredStream >> mightHaveDuplicateRows [
	mightHaveDuplicateRows isNil ifTrue: [mightHaveDuplicateRows := self query isNil ifTrue: [false] ifFalse: [self query mightHaveDuplicateRows]].
	^mightHaveDuplicateRows.
]

{ #category : #'building objects' }
GlorpCursoredStream >> newCollectionOfSize: aSize for: aCollectionType [
	"Make sure that we can reasonably return aCollectionType. If not, default to something we can"
	| theType |
	theType := self collectionTypeFor: aCollectionType.
	^theType isBehavior ifTrue: [theType new: aSize] ifFalse: [theType copyEmpty: aSize].
]

{ #category : #accessing }
GlorpCursoredStream >> next [
	| answer session |
	self atEnd ifTrue: [^nil].
	session := self session.

	[self atEnd ifTrue: [^nil].
	answer := self nextAnswer.
	answer == nil] 
		whileTrue.

	[self hasCompleteAnswerFor: answer] whileFalse: [self nextAnswer].
	session == nil ifFalse: [session privateRegisterAsOld: answer].
	^answer.
]

{ #category : #accessing }
GlorpCursoredStream >> next: anInteger [
	| result |
	Dialect isObjectStudio ifFalse: [^super next: anInteger].
	result := OrderedCollection new: anInteger.
	anInteger timesRepeat: [result add: self next].
	^result.
]

{ #category : #'building objects' }
GlorpCursoredStream >> nextAnswer [
	| result |
	peekBuffer isNil ifFalse: [
		result := peekBuffer.
		peekBuffer := nil.
		^result].
	^self nextAnswerFromUnderlyingCursor.
]

{ #category : #'building objects' }
GlorpCursoredStream >> nextAnswerFromUnderlyingCursor [
	| objects |
	rawPeekBuffer isNil ifTrue: [rawPeekBuffer := cursor next].
	rawPeekBuffer isNil ifTrue: [^nil].
	objects := self buildObjectsForRow: rawPeekBuffer.
	rawPeekBuffer := nil.
	^objects.
]

{ #category : #accessing }
GlorpCursoredStream >> nextPut: anObject [
	self shouldNotImplement.
]

{ #category : #'building objects' }
GlorpCursoredStream >> objectBuilderFor: anExpression [
	"No longer called - see #cacheBuilderRelationships: - but might be retained in case complicated coding requires changing the expression of a builder during querying, in which case this could be used to reset the related builder.  As that might be better handled by general recaching, I am depreacting this method.
	Return the builder for this expression, but only those that directly build compound objects.  In 2003 Alan wrote, 'Most importantly, exclude dictionary builders' but in 2006 changes in DictionaryBuilder>>knitResultIn: ended the need for this (or so I conjecture) and I see no evidence that DictionaryBuilder is excluded."

	self deprecated: #(#version '8.3.1' #use 'Look at #cacheBuilderRelationships: and its callers.').
	^builders
		detect: [:each | each buildsObjects and: [each expression == anExpression]]
		ifNone: [nil]
]

{ #category : #accessing }
GlorpCursoredStream >> peek [
	peekBuffer = nil ifFalse: [^peekBuffer].
	peekBuffer := self nextAnswer.
	^peekBuffer.
]

{ #category : #accessing }
GlorpCursoredStream >> privateGetBuilders [
	^builders.
]

{ #category : #accessing }
GlorpCursoredStream >> query [
	command isNil ifTrue: [^nil].
	^command query.
]

{ #category : #accessing }
GlorpCursoredStream >> query: x [
]

{ #category : #'building objects' }
GlorpCursoredStream >> registerInstances [
	self session isNil ifTrue: [^self].
	builders do: [:each | self session register: each instance].
]

{ #category : #initializing }
GlorpCursoredStream >> release [
	super release.
	self releaseCursor.
	cursor := nil.
	rawPeekBuffer := nil.
	peekBuffer := nil.
	statement isNil
		ifFalse:
			[databaseAccessor reusePreparedStatements
				ifTrue: [statement busy: false]
				ifFalse: [statement release].
			statement := nil].
	databaseAccessor := nil.
]

{ #category : #initializing }
GlorpCursoredStream >> releaseCursor [
	
	self accessor isNil
		ifFalse:
			[self accessor releaseCursor: cursor in: statement.
			self accessor completedCommand: command].
]

{ #category : #debugging }
GlorpCursoredStream >> rows [
	"This will extract all the rows and replace the internal stream with a regular stream on the rows. This is useful for debugging, but in real use rather destroys the purpose of the cursored stream"
	| rows |
	rows := cursor upToEnd.
	self releaseCursor.
	cursor := rows readStream.
	^rows.
]

{ #category : #accessing }
GlorpCursoredStream >> session [
	^self query isNil ifTrue: [nil] ifFalse: [self query session].
]

{ #category : #accessing }
GlorpCursoredStream >> statement [
	^statement.
]

{ #category : #accessing }
GlorpCursoredStream >> statement: aGlorpPreparedStatement [
	statement := aGlorpPreparedStatement.
]

{ #category : #accessing }
GlorpCursoredStream >> upToEnd [
	| result |
	result := WriteStream on: (Array new: 100).
	[self atEnd] whileFalse: [
			| nextValue |
			"Stupid VA's cursors don't deal with atEnd or isEmpty nicely, so check for nil"
			nextValue := self next.
			nextValue == nil ifFalse: [	result nextPut: nextValue]].
	^result contents
]

{ #category : #accessing }
GlorpCursoredStream >> upToEndOfResultSet [
	"If our statement has multiple result sets, we must use this call, not #upToEnd, to avoid the aggressive releasing of the cursor in #atEnd which would lose any remaining result sets.  This reads the current result set and advances the underlying cursor to the next result set.  (N.B. 'the next result set' does not necessarily mean the return of the next statement;  in a sequence of statements, some may return result sets while others return #noAnswerStream and these will be skipped.)  The cursor is released as part of reading the last result set."

	^self accessor upToEndOfResultSet: self
]

{ #category : #accessing }
GlorpCursoredStream >> upToEndOfReturningResultSet [
	"If our statement has multiple result sets, we must use this call, not #upToEnd, to avoid the aggressive releasing of the cursor in #atEnd which would lose any remaining result sets.  This reads the current result set and advances the underlying cursor to the next result set.  (N.B. 'the next result set' does not necessarily mean the return of the next statement;  in a sequence of statements, some may return result sets while others return #noAnswerStream and these will be skipped.)  The cursor is released as part of reading the last result set."

	^self accessor upToEndOfReturningResultSet: self
]
