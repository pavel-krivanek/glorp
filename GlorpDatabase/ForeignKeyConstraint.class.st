"
This represents a foreign key constraint in the database. It's used during table creation, but more important it's used when calculating the order in which we need to write rows. Also, if joins aren't specified on a relationship, we will try to infer them from the foreign key constraints.

Instance Variables:
	name	<Object>	The name of the constraint.
	shouldCreateInDatabase	<Boolean>	We may have table definitions that we don't want to create in the database, either because we know they're already there, or because they are for ""imaginary"" tables.
	sourceFields	<(SequenceableCollection of: DatabaseField)>	The fields we constrain from. The order is fairly arbitrary, but at least we use it consistently.
	suffixExpression	<String>	A bit of a hack to allow us to append some extra text to the constraint. In particular, added to support the ability to append ""ON DELETE CASCADE"".
	targetFields	<(SequenceableCollection of: DatabaseField)>	The fields we constraint to.


"
Class {
	#name : #ForeignKeyConstraint,
	#superclass : #DatabaseTableConstraint,
	#instVars : [
		'suffixExpression',
		'sourceFields',
		'targetFields'
	],
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #'instance creation' }
ForeignKeyConstraint class >> sourceField: aDatabaseField targetField: anotherDatabaseField [
	^self
		sourceField: aDatabaseField
		targetField: anotherDatabaseField
		suffixExpression: nil.
]

{ #category : #'instance creation' }
ForeignKeyConstraint class >> sourceField: aDatabaseField targetField: anotherDatabaseField suffixExpression: suffixExpression [
	^(self new)
		sourceField: aDatabaseField targetField: anotherDatabaseField suffixExpression: suffixExpression;
		yourself.
]

{ #category : #'instance creation' }
ForeignKeyConstraint class >> sourceFields: sourceFields targetFields: targetFields [
	^self
		sourceFields: sourceFields
		targetFields: targetFields
		suffixExpression: nil.
]

{ #category : #'instance creation' }
ForeignKeyConstraint class >> sourceFields: sourceFields targetFields: targetFields suffixExpression: suffixExpression [
	^(self new)
		sourceFields: sourceFields targetFields: targetFields suffixExpression: suffixExpression;
		yourself.
]

{ #category : #'VisualWorks metadata' }
ForeignKeyConstraint class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
ForeignKeyConstraint >> addSourceField: aField [
	(self sourceFields allSatisfy: [:each | aField table = each table]) ifFalse: [self error: 'Fields in foreign key constraints must all have the same source table'].
	self sourceFields add: aField.
]

{ #category : #accessing }
ForeignKeyConstraint >> addTargetField: aField [
	(self targetFields allSatisfy: [:each | aField table = each table]) ifFalse: [self error: 'Fields in foreign key constraints must all have the same target table'].
	self targetFields add: aField.
]

{ #category : #converting }
ForeignKeyConstraint >> asJoin [
	^Join fromAll: self sourceFields toAll: self targetFields.
]

{ #category : #converting }
ForeignKeyConstraint >> asReverseJoin [
	^Join fromAll: self targetFields toAll: self sourceFields.
]

{ #category : #printing }
ForeignKeyConstraint >> creationStringFor: aPlatform [

	^aPlatform createForeignKeyConstraintAddStatement: self
]

{ #category : #printing }
ForeignKeyConstraint >> generateName [
	| stream maxLength tableLength roomToBeVerbose shortTableLength longTableLength |
	self sourceFields isEmpty ifTrue: [^'INVALID CONSTRAINT'].
	"Figure out if we have room for verbose separators or if we should maximize the space for the table/field names"
	maxLength := self sourceFields first table platform maximumLengthOfTableName.
	shortTableLength := ((maxLength - 8) // 2) min: 10.
	longTableLength := (maxLength // 2) - 1.
	roomToBeVerbose := shortTableLength >= 10.
	tableLength := roomToBeVerbose ifTrue: [shortTableLength] ifFalse: [longTableLength].

	stream := WriteStream on: (String new: 100).
	self printForConstraintName: self sourceFields first on: stream maxLength: tableLength.
	roomToBeVerbose ifTrue: [stream nextPutAll: '_TO_'].
	self printForConstraintName: self targetFields first on: stream maxLength: tableLength.
	stream nextPutAll: (roomToBeVerbose ifTrue: ['_REF'] ifFalse: ['R']).
	^stream contents.
]

{ #category : #initializing }
ForeignKeyConstraint >> initialize [

	self sourceFields: (OrderedCollection new: 2).
	targetFields := OrderedCollection new: 2.
]

{ #category : #testing }
ForeignKeyConstraint >> isForeignKeyConstraint [

	^true
]

{ #category : #testing }
ForeignKeyConstraint >> isImaginary [
	^self targetTable isImaginary or: [self sourceTable isImaginary].
]

{ #category : #comparing }
ForeignKeyConstraint >> isSimilarForeignKeyConstraint: aConstraint [
	"We need to sort source and target fields in unison because the ordering of source and targets is fixed. Example,
		FK1 source(X, Y) => target(A, B)
		FK2 source(Y, X) => target(A, B)
Sorting the fields individually would hide the fact that X=>A in FK1, whereas X=>B in FK2.  But, not sorting,
		FK1 source(X, Y) => target(A, B)
		FK2 source(Y, X) => target(B, A)
would miss the fact that these two fkeys are the same."

	| fieldSize sortedSelfIndexes sortedConsIndexes |
	"No need to check target fields as sizes always equal, so source good means both good"
	(fieldSize := self sourceFields size) = aConstraint sourceFields size ifFalse: [^false].
	"An = result in the last line of the sort should never happen since two identical constraints makes no sense"
	sortedSelfIndexes := (1 to: fieldSize) sorted:
		[:a :b |
		(self sourceFields at: a) < (self sourceFields at: b) or:
			[(self sourceFields at: a) = (self sourceFields at: b) and:
				[(self targetFields at: a) < (self targetFields at: b)]]].
	sortedConsIndexes := (1 to: fieldSize) sorted:
		[:a :b |
		(aConstraint sourceFields at: a) < (aConstraint sourceFields at: b) or:
			[(aConstraint sourceFields at: a) = (aConstraint sourceFields at: b) and:
				[(aConstraint targetFields at: a) < (aConstraint targetFields at: b)]]].
	sortedSelfIndexes with: sortedConsIndexes do:
		[:selfIndex :conIndex |
		(((self sourceFields at: selfIndex) matchesField: (aConstraint sourceFields at: conIndex)) and:
			[(self targetFields at: selfIndex) matchesField: (aConstraint targetFields at: conIndex)])
				ifFalse: [^false]].
	^true
]

{ #category : #comparing }
ForeignKeyConstraint >> isTheSameAs: aForeignKeyConstraint [
	"Validate that two constraints are exactly the same. Most useful for testing purposes, rather than normal usage, which is why we don't just use the #= method.
	All the code after the #shouldCreateInDatabase check is identical to the #isSimilarForeignKeyConstraint: method, except that it uses #matchesField: where we use #isTheSameAs:.  Ideally, we would merge the two methods and eliminate the nearly-cloned code."

	| fieldSize sortedSelfIndexes sortedConsIndexes |
	self name asUppercase = aForeignKeyConstraint name asUppercase ifFalse: [^false].
	self suffixExpression = aForeignKeyConstraint suffixExpression ifFalse: [^false].
	self shouldCreateInDatabase = aForeignKeyConstraint shouldCreateInDatabase ifFalse: [^false].
	"No need to check target fields as sizes always equal, so source good means both good"
	(fieldSize := self sourceFields size) = aForeignKeyConstraint sourceFields size ifFalse: [^false].
	"An = result in the last line of the sort should never happen since two identical constraints makes no sense"
	sortedSelfIndexes := (1 to: fieldSize) sorted:
		[:a :b |
		(self sourceFields at: a) < (self sourceFields at: b) or:
			[(self sourceFields at: a) = (self sourceFields at: b) and:
				[(self targetFields at: a) < (self targetFields at: b)]]].
	sortedConsIndexes := (1 to: fieldSize) sorted:
		[:a :b |
		(aForeignKeyConstraint sourceFields at: a) < (aForeignKeyConstraint sourceFields at: b) or:
			[(aForeignKeyConstraint sourceFields at: a) = (aForeignKeyConstraint sourceFields at: b) and:
				[(aForeignKeyConstraint targetFields at: a) < (aForeignKeyConstraint targetFields at: b)]]].
	sortedSelfIndexes with: sortedConsIndexes do:
		[:selfIndex :conIndex |
		(((self sourceFields at: selfIndex) isTheSameAs: (aForeignKeyConstraint sourceFields at: conIndex)) and:
			[(self targetFields at: selfIndex) isTheSameAs: (aForeignKeyConstraint targetFields at: conIndex)])
				ifFalse: [^false]].
	^true.
]

{ #category : #comparing }
ForeignKeyConstraint >> matchesForeignKeyConstraint: aConstraint [
	"This expects the constraints to have their fields in the same order.  To compare constraints that may be the same up to having been defined in different orders, use #isTheSameAs: or #isSimilarForeignKeyConstraint:."

	name asUppercase = aConstraint name asUppercase ifFalse: [^false].
	self sourceFields size = aConstraint sourceFields size ifFalse: [^false].
	self sourceFields with: aConstraint sourceFields do:
		[:field1 :field2 | (field1 matchesField: field2) ifFalse: [^false]].
	self targetFields size = aConstraint targetFields size ifFalse: [^false].
	self targetFields with: aConstraint targetFields do:
		[:field1 :field2 | (field1 matchesField: field2) ifFalse: [^false]].
	^true
]

{ #category : #printing }
ForeignKeyConstraint >> printForConstraintName: aField on: aStream maxLength: maxLength [ 
	| constraintName |
	constraintName := aField table name , '_' , aField name.
	constraintName size > maxLength 
		ifTrue: [constraintName := constraintName copyFrom: 1 to: maxLength].
	aStream nextPutAll: constraintName
]

{ #category : #testing }
ForeignKeyConstraint >> refersToTable: aTable [
	^self targetTable yourself == aTable.
]

{ #category : #relationships }
ForeignKeyConstraint >> rowsRelatedTo: aRow [
	| myWrapper relatedRows sourceField targetField allWrappers |
	"Note that we don't care which field, as presumably all of them must point the same place for a composite key, so grab the first pair"
	sourceField := self sourceFields first.
	targetField := self targetFields first.
	myWrapper := aRow wrapperAt: sourceField ifAbsent: [nil].
	myWrapper isNil ifTrue: [^#()].
	relatedRows := Set new: 5.
	allWrappers := OrderedCollection with: myWrapper.
	allWrappers addAll: myWrapper allInnerWrappers.
	allWrappers
		do: [:eachWrapper |
			(eachWrapper containedBy glorpAtIdentity: targetField ifAbsent: [#()])
				do: [:eachRow | eachRow == aRow ifFalse: [relatedRows add: eachRow]]].
	^relatedRows.
]

{ #category : #accessing }
ForeignKeyConstraint >> someSourceField [
	"Return any one of our source fields"

	^self sourceFields first
]

{ #category : #accessing }
ForeignKeyConstraint >> sourceField: aField [
	self sourceFields isEmpty ifFalse: [self error: 'Adding a field to a non-empty constraint'].
	self sourceFields add: aField.
]

{ #category : #initializing }
ForeignKeyConstraint >> sourceField: aDatabaseField targetField: anotherDatabaseField [
	self
		sourceField: aDatabaseField
		targetField: anotherDatabaseField
		suffixExpression: nil.
]

{ #category : #initializing }
ForeignKeyConstraint >> sourceField: aDatabaseField targetField: anotherDatabaseField suffixExpression: suffixExpressionString [
	self
		sourceField: aDatabaseField;
		targetField: anotherDatabaseField;
		suffixExpression: suffixExpressionString.
]

{ #category : #accessing }
ForeignKeyConstraint >> sourceFields [
	^sourceFields
]

{ #category : #accessing }
ForeignKeyConstraint >> sourceFields: aCollection [
	
	sourceFields := aCollection.
]

{ #category : #initializing }
ForeignKeyConstraint >> sourceFields: sourceFieldCollection targetFields: targetFieldCollection suffixExpression: suffixExpressionString [
	self
		sourceFields: sourceFieldCollection;
		targetFields: targetFieldCollection;
		suffixExpression: suffixExpressionString.
]

{ #category : #accessing }
ForeignKeyConstraint >> sourceTable [
	"All the source fields have to come from the same table, so just pick one"

	^self someSourceField table
]

{ #category : #accessing }
ForeignKeyConstraint >> suffixExpression [
	^suffixExpression
]

{ #category : #accessing }
ForeignKeyConstraint >> suffixExpression: anObject [
	suffixExpression := anObject.
]

{ #category : #accessing }
ForeignKeyConstraint >> table [
	^self sourceTable.
]

{ #category : #accessing }
ForeignKeyConstraint >> targetField: aField [

	self targetFields isEmpty ifFalse: [self error: 'Adding a field to a non-empty constraint'].
	self targetFields add: aField.
]

{ #category : #accessing }
ForeignKeyConstraint >> targetFields [
	^targetFields
]

{ #category : #accessing }
ForeignKeyConstraint >> targetFields: aCollection [
	targetFields := aCollection.
]

{ #category : #accessing }
ForeignKeyConstraint >> targetTable [
	"All the target fields have to come from the same table, so just pick one"
	^self targetFields isEmpty ifTrue: [nil] ifFalse: [self targetFields first table].
]
