Class {
	#name : #GlorpSerialType,
	#superclass : #GlorpAbstractIntegerType,
	#instVars : [
		'sequence',
		'increment'
	],
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpSerialType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpSerialType >> hasParameters [
	^true.
]

{ #category : #testing }
GlorpSerialType >> hasSequence [
	^true.
]

{ #category : #accessing }
GlorpSerialType >> increment [
	^increment
]

{ #category : #accessing }
GlorpSerialType >> increment: anInteger [
	increment := anInteger.
]

{ #category : #initialize }
GlorpSerialType >> initializeForField: aDatabaseField in: aDescriptorSystem [
	sequence isNil ifFalse: [^self].
	sequence := aDescriptorSystem databaseSequenceNamed: (aDescriptorSystem sequenceNameForField: aDatabaseField).
	aDatabaseField platform supportsSettingSequenceIncrement ifTrue:
		[increment := aDatabaseField type increment isNil ifFalse:
			[sequence sequenceIncrement: increment]].
	sequence schema: aDatabaseField table schema.
]

{ #category : #accessing }
GlorpSerialType >> isGenerated [
	^true
]

{ #category : #testing }
GlorpSerialType >> isIdentityColumn [
	^self sequence isIdentityColumn.
]

{ #category : #testing }
GlorpSerialType >> isSerial [
	"answer if this is a database-generated primary key column"

	^true
]

{ #category : #sequencing }
GlorpSerialType >> postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: anAccessor [

	^sequence postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: anAccessor.
]

{ #category : #sequencing }
GlorpSerialType >> postWriteAssignSequenceValueFor: aDatabaseField inRows: someDatabaseRows using: anAccessor [
	^sequence postWriteAssignSequenceValueFor: aDatabaseField inRows: someDatabaseRows using: anAccessor
]

{ #category : #sequencing }
GlorpSerialType >> preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: anAccessor [

	^sequence preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: anAccessor.
]

{ #category : #testing }
GlorpSerialType >> printSelectSQLOn: aCommand withParameters: aDictionary [
	"We record our type as serial, but that isn't really useful for a cast. We assume serials are integers, so just print a generic integer type instead."
	self platform integer printSelectSQLOn: aCommand withParameters: aDictionary.
]

{ #category : #accessing }
GlorpSerialType >> sequence [
	^sequence.
]

{ #category : #accessing }
GlorpSerialType >> sequence: aDatabaseSequence [
	sequence := aDatabaseSequence.
]
