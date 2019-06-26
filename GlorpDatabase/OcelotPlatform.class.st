"
This is a platform for the open-source Ocelot database.
"
Class {
	#name : #OcelotPlatform,
	#superclass : #DatabasePlatform,
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #accessing }
OcelotPlatform class >> kind [
	^'Ocelot'
]

{ #category : #'VisualWorks metadata' }
OcelotPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #constants }
OcelotPlatform >> areSequencesExplicitlyCreated [

^false
]

{ #category : #types }
OcelotPlatform >> boolean [
	^self typeNamed: #boolean ifAbsentPut: [GlorpBooleanType new typeString: 'boolean'].
]

{ #category : #types }
OcelotPlatform >> clob [

	^self typeNamed: #clob ifAbsentPut: [GlorpClobType new typeString: 'clob'].
]

{ #category : #sequences }
OcelotPlatform >> databaseSequenceClass [
	^InMemorySequence.
]

{ #category : #types }
OcelotPlatform >> date [
	^self typeNamed: #date ifAbsentPut: [GlorpDateType new].
]

{ #category : #types }
OcelotPlatform >> double [
	^self float8
]

{ #category : #types }
OcelotPlatform >> float [
	^self float4.
]

{ #category : #types }
OcelotPlatform >> float4 [
	^self typeNamed: #float4 ifAbsentPut: [GlorpFloatType new typeString: 'float'].
]

{ #category : #types }
OcelotPlatform >> float8 [
	^self typeNamed: #float8 ifAbsentPut: [GlorpDoubleType new typeString: 'double precision'].
]

{ #category : #types }
OcelotPlatform >> int2 [
	^self smallint.
]

{ #category : #types }
OcelotPlatform >> int4 [

	^self integer.
]

{ #category : #types }
OcelotPlatform >> int8 [

	^self integer
]

{ #category : #testing }
OcelotPlatform >> isODBCPlatform [

	^true
]

{ #category : #testing }
OcelotPlatform >> isOcelotPlatform [

	^true
]

{ #category : #types }
OcelotPlatform >> numeric [
	^self typeNamed: #numeric ifAbsentPut: [GlorpNumericType new].
]

{ #category : #'conversion-strings' }
OcelotPlatform >> paddingCharacter [
	^32 asCharacter.
]

{ #category : #constants }
OcelotPlatform >> primaryKeysAreAutomaticallyUnique [

	^true.
]

{ #category : #'conversion times' }
OcelotPlatform >> printDate: aDate for: aType [
	| stream |
	aDate isNil ifTrue: [^nil].
	stream := WriteStream on: String new.
	stream nextPutAll: 'date '''.
	self
		printDate: aDate
		isoFormatOn: stream.
	stream nextPutAll: ''''.
	^stream contents.
]

{ #category : #'conversion times' }
OcelotPlatform >> printTime: aTime for: aType [
	| stream |
	aTime isNil ifTrue: [^nil].
	stream := WriteStream on: String new.
	stream nextPutAll: 'time '''.
	self
		printTime: aTime
		isoFormatOn: stream.
	stream nextPutAll: ''''.
	^stream contents.
]

{ #category : #'conversion times' }
OcelotPlatform >> printTimestamp: aTimestamp on: stream for: aType [

	aTimestamp isNil ifTrue: [stream nextPutAll: 'NULL'. ^self].
	stream nextPutAll: 'timestamp '''.
	self
		printDate: aTimestamp
		isoFormatOn: stream.
	stream nextPut: $ .
	self
		printTime: aTimestamp
		isoFormatOn: stream.
	"	milliseconds: true."
	stream nextPutAll: ''''.
]

{ #category : #types }
OcelotPlatform >> sequence [

	^self inMemorySequence
]

{ #category : #types }
OcelotPlatform >> serial [

	^self sequence
]

{ #category : #constants }
OcelotPlatform >> sqlTextForNULLAttributeConstraint [
	"^<String>"

	^''
]

{ #category : #testing }
OcelotPlatform >> supportsANSIJoins [
	"Do we support the JOIN <tableName> USING <criteria> syntax. Currently hard-coded, but may also vary by database version"

	^true
]

{ #category : #constants }
OcelotPlatform >> supportsMillisecondsInTimes [
	"I'm guessing here"
	^true.
]

{ #category : #types }
OcelotPlatform >> text [
	^self clob.
]

{ #category : #types }
OcelotPlatform >> time [
	^self typeNamed: #time ifAbsentPut: [GlorpTimeType new typeString: 'time'].
]

{ #category : #types }
OcelotPlatform >> timestamp [
	^self typeNamed: #timestamp ifAbsentPut: [GlorpTimeStampType new typeString: 'timestamp'].
]

{ #category : #constants }
OcelotPlatform >> usesNullForEmptyStrings [
	"Return true if this database is likely to use nil as an empty string value"
	^false.
]

{ #category : #types }
OcelotPlatform >> varchar [
	^self typeNamed: #varchar ifAbsentPut: [GlorpVarCharType new].
]
