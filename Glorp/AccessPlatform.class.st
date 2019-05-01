"
This is a platform for the Microsoft Access database. It subclasses from SQL Server, because the two have a number of characteristics in common.
"
Class {
	#name : #AccessPlatform,
	#superclass : #SQLServerPlatform,
	#category : #'Glorp-Database'
}

{ #category : #accessing }
AccessPlatform class >> kind [
	^'Access'
]

{ #category : #constants }
AccessPlatform >> areSequencesExplicitlyCreated [

	^false.
]

{ #category : #types }
AccessPlatform >> blob [

	^self typeNamed: #blob ifAbsentPut: [GlorpBlobType new typeString: 'longbinary'].
]

{ #category : #'conversion-boolean' }
AccessPlatform >> booleanToBooleanConverter [
	^DelegatingDatabaseConverter
		named: #booleanToBoolean
		hostedBy: self
		fromStToDb: #convertBooleanToDBBoolean:for:
		fromDbToSt: #convertDBBooleanToBoolean:for:.
]

{ #category : #testing }
AccessPlatform >> canBind: aValue to: aType [

	(Dialect isVisualWorks
		and: [aValue class == Dialect fixedPointClass]) ifTrue: [^false].
	(Dialect isVisualWorks and: 
			[#(#LargePositiveInteger #LargeNegativeInteger)
				includes: aValue class name asSymbol])
		ifTrue: [aType = self int8 ifTrue: [^false]].
	^super canBind: aValue to: aType
]

{ #category : #testing }
AccessPlatform >> canUseInWhereClause: aValue type: aType [
	"This is mostly for test support purposes. If we know we can't use a particular kind of value in the where clause on some database, don't try."

	(super canUseInWhereClause: aValue type: aType) ifFalse: [^false].
	"With MS Access (Jet db engine) we don't seem to be able to compare constants against blobs."
	aType = self blob ifTrue: [^false].
	^true.
]

{ #category : #types }
AccessPlatform >> clob [

	^self typeNamed: #clob ifAbsentPut: [GlorpClobType new typeString: 'memo'].
]

{ #category : #'services tables' }
AccessPlatform >> endColumnQuote [
	^']'.
]

{ #category : #functions }
AccessPlatform >> initializeFunctions [
	"See AccessCast class comments for more info on cast limitations."

	| baseExists dbSpecificExists selectList baseNotExists dbSpecificNotExists |
	"Ignore SQLServer functions by starting with the defaults."
	functions := FunctionExpression createBasicFunctionsFor: self.
	functions
		at: #, put: (InfixFunction named: '+');
		at: #copyFrom:to: put: (SubstringFunction named: 'MID');
		at: #cast: put: ((AccessCast named: 'template') separator: ' ').

	"Like Oracle, MS Access doesn't allow functions like EXISTS in a field list,
	but will allow a select there as an argument to a function, such as IIF.
	So print it that way if we're in the select list."
	baseExists := functions at: #exists:.
	dbSpecificExists := DualRoleFunction new.
	dbSpecificExists function: '#exists:'.
	dbSpecificExists whereClauseVersion: baseExists.
	selectList := IIF new argumentTypes: (Array with: (self varchar: 1) with: self integer with: self integer).
	selectList argumentModifierBlock: [:function :args | 
		function base: args first.
		Array with: 'x' asGlorpExpression with: 1 asGlorpExpression with: 0 asGlorpExpression].
	dbSpecificExists selectListVersion: selectList.
	dbSpecificExists type: self integer.
	functions at: #exists: put: dbSpecificExists.

	"And similarly NOT EXISTS"
	baseNotExists := functions at: #notExists:.
	dbSpecificNotExists := DualRoleFunction new.
	dbSpecificNotExists function: '#notExists:'.
	dbSpecificNotExists whereClauseVersion: baseNotExists.
	selectList := IIF new argumentTypes: (Array with: (self varchar: 1) with: self integer with: self integer).
	selectList argumentModifierBlock: [:function :args | 
		function base: args first.
		Array with: 'x' asGlorpExpression with: 0 asGlorpExpression with: 1 asGlorpExpression].
	dbSpecificNotExists selectListVersion: selectList.
	dbSpecificNotExists type: self integer.
	functions at: #notExists: put: dbSpecificNotExists.
]

{ #category : #constants }
AccessPlatform >> initializeReservedWords [

	super initializeReservedWords.
	reservedWords
		add: 'timestamp';
		add: 'key'
]

{ #category : #commands }
AccessPlatform >> insertCommandForRows: aCollectionOfDatabaseRows binding: aBoolean session: aSession [
	^InsertCommand
		forRows: aCollectionOfDatabaseRows
		useBinding: aBoolean
		session: aSession
]

{ #category : #testing }
AccessPlatform >> isAccessPlatform [

	^true
]

{ #category : #testing }
AccessPlatform >> isSQLServerPlatform [

	^false
]

{ #category : #types }
AccessPlatform >> longText [

	^self typeNamed: #longText ifAbsentPut: [GlorpClobType new typeString: 'memo'].
]

{ #category : #constants }
AccessPlatform >> maximumLengthOfColumnName [
	"^<Integer> I return the maximum length of a column name.  (I am not sent at present;  I am here so that if I and #maximumLengthOfTableName (which is sent) should ever differ on some database platform, I can be used in revised truncation logic.)"

	^64
]

{ #category : #constants }
AccessPlatform >> maximumLengthOfTableName [
	"^<Integer> I return the max. length of a table name"

	^64
]

{ #category : #types }
AccessPlatform >> memo [

	^self typeNamed: #memo ifAbsentPut: [GlorpClobType new typeString: 'memo'].
]

{ #category : #types }
AccessPlatform >> nclob [
	"Access uses the same type for strings and unicode strings."

	^self typeNamed: #nclob ifAbsentPut: [GlorpClobType new typeString: 'memo']
]

{ #category : #types }
AccessPlatform >> ntext [
	"Access uses the same type for strings and unicode strings."

	^self typeNamed: #ntext ifAbsentPut: [GlorpClobType new typeString: 'longtext']
]

{ #category : #constants }
AccessPlatform >> parenthesizeAllButFirstCommandInCompoundQuery [
	^true
]

{ #category : #login }
AccessPlatform >> postLoginInitializeFromAccessor: aDatabaseAccessor [
	"No need to set supportsGroupWritingValues to false as my getter returns false anyway."
]

{ #category : #'conversion-boolean' }
AccessPlatform >> printBoolean: aBoolean for: aType [
	"If the platform is MS SQL Server, a boolean object in a SELECT needs to be converted to  BIT type, since T, Y, or true make SQLServer complain. "
	
	| string |
	aBoolean isNil ifTrue: [^'NULL'].
	"We may be getting passed something that's already 1 or 0, or something else instead of a boolean. That probably shouldn't be happening, but let's handle it gracefully. We define gracefully to mean 1 is true, and everything else is false"
	string := (aBoolean == 1 or: [aBoolean = true]) 
		ifTrue: ['1'] 
		ifFalse: ['0'].
	^'CBOOL( ' , string , ' )'.
]

{ #category : #testing }
AccessPlatform >> requiresCastsForNullsInUnions [
	"If we have explicit nulls in a query which is unioned, do we need to cast them to the appropriate type in order to keep the database happy."
	^false.
]

{ #category : #types }
AccessPlatform >> serial [

	^self typeNamed: #serial ifAbsentPut: [GlorpSerialType new typeString: 'autoincrement'].
]

{ #category : #constants }
AccessPlatform >> sqlTextCurrentServerUTCTimestamp [
	"This isn't UTC, but ACCESS is a local server anyway, and doesn't appear to support UTC."

	^'SELECT NOW()'
]

{ #category : #constants }
AccessPlatform >> sqlTextForDEFAULT: defaultValue [
	"We don't support DEFAULT statements"

	^''
]

{ #category : #'services tables' }
AccessPlatform >> startColumnQuote [
	^'['.
]

{ #category : #constants }
AccessPlatform >> supportsAuthentication [
	^false
]

{ #category : #testing }
AccessPlatform >> supportsCorrelatedSubqueriesInOrderBy [
	"Access supports only a field list in the ORDER BY clause--no subqueries whatsoever."

	^false
]

{ #category : #testing }
AccessPlatform >> supportsDecimalsOnAllNumerics [
	"Return true if a general 'numeric' type will allow numbers after the decimal place"
	^true.
]

{ #category : #testing }
AccessPlatform >> supportsGroupWritingFor: aCommand [
	^false
]

{ #category : #testing }
AccessPlatform >> supportsGroupWritingValues [
	"Untested, so assume false until shown otherwise."

	^false
]

{ #category : #testing }
AccessPlatform >> supportsInformationSchema [
	^false.
]

{ #category : #constants }
AccessPlatform >> supportsMillisecondsInTimes [
	^false.
]

{ #category : #testing }
AccessPlatform >> supportsSchemas [
	^false
]

{ #category : #testing }
AccessPlatform >> supportsSingleQueryHorizontalInheritance [
	"Can this database support a single query for horizontal inheritance."
	^false.
]

{ #category : #testing }
AccessPlatform >> supportsStringQueryOnBlobs [
	"Return true if we can do string queries on parts of blobs."
	^false.
]

{ #category : #testing }
AccessPlatform >> supportsTableOwners [
	"Return true if this platform supports table owners, i.e. expects table names of the form Bern.TW_* rather than just TW_* in its SQL."
"Access, Firebird and PostGreSQL do not, Oracle does, others I know not."

	^false
]

{ #category : #SQL }
AccessPlatform >> supportsVariableSizedNumerics [
	"Return true if this platform can support numbers with a varying size and number of decimal places. Access, notably, doesn't seem to be able to"
	^false.
]

{ #category : #types }
AccessPlatform >> text [

	^self typeNamed: #text ifAbsentPut: [GlorpClobType new typeString: 'longtext'].
]

{ #category : #'type helpers' }
AccessPlatform >> typesWithValues [
	self nclob.
	self ntext.
	super typesWithValues.
	types removeKey: #nvarchar ifAbsent: [].
	types removeKey: #nchar ifAbsent: [].
	^types
]

{ #category : #testing }
AccessPlatform >> useMicrosoftOuterJoins [
	"Return true if we use the Microsoft x *= y syntax for outer joins. Oddly enough, false for access 2k"
	^false.
]

{ #category : #testing }
AccessPlatform >> usesLengthNotEndPosInSubstring [
	^false
]

{ #category : #constants }
AccessPlatform >> usesNullForFalse [
	"Return true if this database is likely to use nil as an empty string value"
	^true.
]
