"
This represents a field in a database table. See also DatabaseTable. Glorp relies heavily on identity of fields for comparison purposes, so be careful when copying these.

Instance Variables:
	imDefaultValue	<Object>	If the column in the database does not have a default value but we wish one, or it
						does but we wish to use a different default value, set this in the image before writing.
	dbDefaultValue	<Object>	If the column in the database has a default value, put it here to use in (re)creation
						statements (by the user setting it or by reading it in a metadata descriptor system).
	isLockKey	<Boolean>	Is this field part of an optimistic lock key. If so, then on update we will generate an
						update statement that checks that this value hasn't changed since the object was read.
	isNullable	<Boolean>	Is this field allowed to be null?
	isPrimaryKey	<Boolean>	Is this field part of the primary key?
	isUnique	<Boolean>	Does this field have a unique constraint in the database?
	name	<String>	The name of the field.
	position	<Object | ProtoObject>	description of position
	table	<DatabaseTable>	The table that contains this field.
	type	<GlorpDatabaseType>	The type of  data that this field contains.


"
Class {
	#name : #DatabaseField,
	#superclass : #Object,
	#instVars : [
		'table',
		'name',
		'isPrimaryKey',
		'position',
		'type',
		'isNullable',
		'isUnique',
		'isLockKey',
		'imDefaultValue',
		'dbDefaultValue'
	],
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #'instance creation' }
DatabaseField class >> named: aString [

	^self error: 'type needed'
]

{ #category : #'instance creation' }
DatabaseField class >> named: aString type: dbType [

	^super new initialize
		name: aString;
		type: dbType
]

{ #category : #'instance creation' }
DatabaseField class >> new [

	^self error: 'dbType needed'
]

{ #category : #'VisualWorks metadata' }
DatabaseField class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #comparing }
DatabaseField >> < aField [
	"This assists my being part of sorting multiple fields."

	^self name < aField name
]

{ #category : #comparing }
DatabaseField >> <= aField [
	^self name <= aField name
]

{ #category : #obsolete }
DatabaseField >> asConstraintReferenceString [

	^table name, ' (', self name, ')'.
]

{ #category : #converting }
DatabaseField >> asDistinctFieldOn: anExpression [

	^(anExpression getField: self) asDistinctFieldOn: anExpression.
]

{ #category : #converting }
DatabaseField >> asField [
	^self.
]

{ #category : #converting }
DatabaseField >> asGlorpExpression [

	^ParameterExpression forField: self basedOn: nil.
]

{ #category : #converting }
DatabaseField >> asGlorpExpressionOn: anExpression [

	^ParameterExpression forField: self basedOn: anExpression.
]

{ #category : #comparing }
DatabaseField >> basicMatchesField: aField [
	"Return true if I match aField, ignoring our table names."
	self name asUppercase = aField name asUppercase ifFalse: [^false].
	self isPrimaryKey = aField isPrimaryKey ifFalse: [^false].
	self isNullable = aField isNullable ifFalse: [^false].
	self isUnique = aField isUnique ifFalse: [^false].
	^true
]

{ #category : #configuring }
DatabaseField >> beIndexed [
	self table addIndex: (self table indexClass forField: self).
]

{ #category : #configuring }
DatabaseField >> beLockKey [
	"Make lock fields non-nullable wherever possible:  when writing bound updates (especially when group-writing), the need to consider whether a lock field's prior value could be NULL complicates handling.   (Lock fields are typically of type VersionType with generatesOverExistingValues set, so Glorp will never naturally offer a nil value to a lock field;  usually, it is only legacy issues or non-Glorp access that could make it necessary to let a lock field be null)."

	isLockKey := true.
	isNullable := false.	"but caller may reset this;  see comment above"
	self table isNil ifFalse: [self table addAsLockKeyField: self].
]

{ #category : #configuring }
DatabaseField >> beNullable: aBoolean [

	self isPrimaryKey ifFalse: [ isNullable := aBoolean ]
]

{ #category : #configuring }
DatabaseField >> bePrimaryKey [
	isPrimaryKey := true.
	isNullable := false.
	self table isNil ifFalse: [self table addAsPrimaryKeyField: self]
]

{ #category : #configuring }
DatabaseField >> beRelative [
	"Since NULL + VALUE is NULL in SQL, relatively updates could be lost if it were possible to NULL the field without our knowing it.  Therefore use this method to make a not-null relative field, with a default value set in the database if a row with no entry for the field is written."

	isNullable := false.
	type := type beRelative.
	dbDefaultValue isNil ifTrue:
		[dbDefaultValue := type nilOldValueEquivalent].

"If a nullable field is wanted, send #beRelative directly to the type, not to the field, e.g.
	(aTable createFieldNamed: 'QTY' type: platform int4 beRelative)
		dbDefaultValue: whatever - a db default value is optional
The field can then be NULLed by setting NULL as the relative update value, since field = field + NULL;  obviously, the user who does this must be aware it will lose later relative updates.  Likewise, inserted rows must be given values for the field, or a dbDefaultValue must be set for it."
]

{ #category : #converting }
DatabaseField >> converterForStType: aClass [

	^self type converterForStType: (aClass isBehavior ifTrue: [aClass] ifFalse: [aClass class]).
]

{ #category : #accessing }
DatabaseField >> dbDefaultValue [
	"'If this is not nil, the database has a default value for this column.  Note the difference between that and Glorp having an image-set default value, which is handled by imDefaultValue."

	^dbDefaultValue
]

{ #category : #configuring }
DatabaseField >> dbDefaultValue: anObject [
	"'Set a default value for this column in the database;  used in table (re)creation and when reading metadata.  Note the difference between this and Glorp having an image-set default value, which is handled by imDefaultValue."

	dbDefaultValue := anObject.
]

{ #category : #configuring }
DatabaseField >> defaultValue: anObject [
	"For backward compatibility and/or (excessive?) safety.  Before 8.2, my single 'defaultValue' instvar both set the value in the image before writing a no-value-for-me row and created a column with the same default value in the database.  Now we have two instvars to handle these two cases.  This setter preserves the pre-8.2 behaviour by setting both instvars to the same value.  Users are invited to decide which means of setting a default that they wish to use for any given call, and so replace calls of this method in their code with calls of the appropriate instvar's setter."

	imDefaultValue := anObject.
	dbDefaultValue := anObject.
]

{ #category : #accessing }
DatabaseField >> foreignKeyConstraints [
	^self table foreignKeyConstraints select: [:each | each sourceFields includes: self].
]

{ #category : #accessing }
DatabaseField >> imDefaultValue [
	"Glorp will insert this value into any row without a value for this field before writing to the database.  Note this is an alternative to or override of a default value on the database column."

	^imDefaultValue
]

{ #category : #configuring }
DatabaseField >> imDefaultValue: anObject [
	"Glorp will insert this value into any row without a value for this field before writing to the database.  Note this is an alternative to or override of a default value on the database column;  use when the database does not have a default value or else has a different default value."

	imDefaultValue := anObject.
]

{ #category : #accessing }
DatabaseField >> impliedSmalltalkType [
	"Return the default Smalltalk type corresponding to our database type"

	^self type impliedSmalltalkType.
]

{ #category : #'initialize-release' }
DatabaseField >> initialize [
	isPrimaryKey := false.
	isNullable := true.
	isUnique := false.
	isLockKey := false.
]

{ #category : #testing }
DatabaseField >> isDistinct [
	^false.
]

{ #category : #testing }
DatabaseField >> isGenerated [
	^type isGenerated or: [imDefaultValue notNil]
]

{ #category : #testing }
DatabaseField >> isIndexed [
	^self table hasIndexForField: self.
]

{ #category : #testing }
DatabaseField >> isLockKey [
	^isLockKey
]

{ #category : #testing }
DatabaseField >> isMappable [
	"Return true if we're something that can be returned in a select statement. Always true for fields"
	^true.
]

{ #category : #testing }
DatabaseField >> isNullable [
	
	^isNullable.
]

{ #category : #testing }
DatabaseField >> isPrimaryKey [
	"Private - Answer the value of the receiver's ''isPrimaryKey'' instance variable."

	^isPrimaryKey yourSelf.
]

{ #category : #comparing }
DatabaseField >> isSameAliasedFieldAs: aField [
	"Return true if we are the same as another aliased field. For non-aliased fields, identity is assured, so this is redundant. Note that we == the string. This will work because we know these must both be shallow copies of the same thing"
	self class == aField class ifFalse: [^false].
	^self table == aField table and: [self name == aField name].
]

{ #category : #comparing }
DatabaseField >> isSimilarField: aField [
	"Return true if I match aField, ignoring our tables' names."

	self name asUppercase = aField name asUppercase ifFalse: [^false].
	self isPrimaryKey = aField isPrimaryKey ifFalse: [^false].
	self isNullable = aField isNullable ifFalse: [^false].
	self isUnique = aField isUnique ifFalse: [^false].
	^true
]

{ #category : #comparing }
DatabaseField >> isTheSameAs: aDatabaseField [
	"Validate that two fields are exactly the same. Most useful for testing purposes, rather than normal usage, which is why we don't just use the #= method. If the field is part of the primary key, ignore the default value since duplicates are illegal. Beyond that, the platform vendor may impose its own default, ignoring ours. For example, MySQL automatically assigns varchar pkeys to have an empty string default value."

	(self isSimilarField: aDatabaseField) ifFalse: [^false].
	(self isTheSameTypeAs: aDatabaseField) ifFalse: [^false].
	self isLockKey = aDatabaseField isLockKey ifFalse: [^false].
	self isPrimaryKey ifFalse:
		[self imDefaultValue = aDatabaseField imDefaultValue ifFalse: [^false].
		self dbDefaultValue = aDatabaseField dbDefaultValue ifFalse: [^false]].
	^true
]

{ #category : #comparing }
DatabaseField >> isTheSameTypeAs: aDatabaseField [
	| myType aType |
	self isPrimaryKey
		ifTrue:
		   [myType := self type.
		   aType := aDatabaseField type.
		   ^(myType = aType 
				or: [(myType isSerial or: [aType isSerial ]) 
					and: [myType impliedSmalltalkType = aType impliedSmalltalkType ]]) ].
		
	^self type = aDatabaseField type
]

{ #category : #testing }
DatabaseField >> isUnique [
	isUnique isNil ifTrue: [isUnique := false].
	^isUnique.
]

{ #category : #configuring }
DatabaseField >> isUnique: aBoolean [
	isUnique := aBoolean.
]

{ #category : #comparing }
DatabaseField >> matchesField: aField [
	^self table name = aField table name
		and: [self isSimilarField: aField]
]

{ #category : #accessing }
DatabaseField >> name [
	"Private - Answer the value of the receiver's ''name'' instance variable."

	^name
]

{ #category : #accessing }
DatabaseField >> name: aString [
	"Private - Set the value of the receiver's ''name'' instance variable to the argument, anObject."

	name := aString asString.
]

{ #category : #converting }
DatabaseField >> parentTableField [
	| parentTable |
	parentTable := self table parent.
	^parentTable isNil
		ifTrue: [self]
		ifFalse: [parentTable fieldNamed: self name]
]

{ #category : #accessing }
DatabaseField >> platform [
	^self type platform.
]

{ #category : #accessing }
DatabaseField >> position [
	^position
]

{ #category : #accessing }
DatabaseField >> position: anObject [
	position := anObject
]

{ #category : #'initialize-release' }
DatabaseField >> postInitializeIn: aDescriptorSystem [
	"Any initialization that has to be delayed until we're in the table"
	type initializeForField: self in: aDescriptorSystem.
]

{ #category : #obsolete }
DatabaseField >> printForConstraintNameOn: aStream maxLength: maxLength [ 
	| constraintName |
	constraintName := table name , '_' , name.
	constraintName size > maxLength 
		ifTrue: [constraintName := constraintName copyFrom: 1 to: maxLength].
	aStream nextPutAll: constraintName
]

{ #category : #obsolete }
DatabaseField >> printNameOn: aStream withParameters: anArray [ 
	aStream nextPutAll: self name
]

{ #category : #printing }
DatabaseField >> printOn: aStream [
	
	aStream nextPutAll: 'Field'.
	aStream 
		nextPutAll: '(';
		nextPutAll: (table isNil ifTrue: [''] ifFalse: [table name]);
		nextPutAll: '.';
		nextPutAll: name;
		nextPutAll: ')'.
]

{ #category : #obsolete }
DatabaseField >> printQualifiedSQLOn: aStream withParameters: aDictionary [ 
	aStream nextPutAll: self qualifiedName
]

{ #category : #printing }
DatabaseField >> printSQLOn: aStream withParameters: anArray [ 
	aStream nextPutAll: self quotedQualifiedName.
]

{ #category : #printing }
DatabaseField >> printSelectSQLOn: aStream withParameters: anArray [ 
	self printSQLOn: aStream withParameters: anArray.
]

{ #category : #printing }
DatabaseField >> printUnqualifiedSQLOn: aStream withParameters: anArray [ 
	aStream nextPutAll: self name.
]

{ #category : #querying }
DatabaseField >> qualifiedName [

	^table isNil 
		ifTrue: [self name]
		ifFalse: [self table qualifiedName, '.', self name].
]

{ #category : #querying }
DatabaseField >> quotedQualifiedName [

	| basicName |
	basicName := self platform nameForColumn: self name.
	^table isNil 
		ifTrue: [basicName]
		ifFalse: [self table qualifiedName, '.', basicName].
]

{ #category : #accessing }
DatabaseField >> table [
	^table
]

{ #category : #accessing }
DatabaseField >> table: anObject [

	table := anObject
]

{ #category : #accessing }
DatabaseField >> tablesToPrint [
	^Array with: table
]

{ #category : #accessing }
DatabaseField >> type [

	^type
]

{ #category : #configuring }
DatabaseField >> type: aDatabaseType [
	"There is very little chance of someone needing a serial column that is not part of the primary key, so we ensure its being a primaryKey here as the default."

	type := aDatabaseType.
	(type notNil and: [type isSerial]) ifTrue: [self bePrimaryKey].

"If a user wanted to a serial type not to be a primaryKey, e.g. during a migration, then we would need a method to revert that state here in the field and to nil the primaryKeyFields instvar in its table.  Alternatively, we could defer the above assignment of primaryKey status to serial-type fields until table>>postInitializeIn: (for example), whereupon, if there were no other primaryKey columns, any serial column would be made the primaryKey (see AR 56006)."
]

{ #category : #database }
DatabaseField >> typeString [

	^type typeString
]

{ #category : #copying }
DatabaseField >> withTable: aTable [
	"Return a copy of ourselves, with the table set to aTable. Presumably aTable is an aliased version of our table"
	^self copy table: aTable.
]
