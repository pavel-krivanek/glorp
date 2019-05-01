"
Mempry Sequence type

Instance Variables
	representationType:		<Object>

representationType
	- xxxxx

"
Class {
	#name : #GlorpInMemorySequenceDatabaseType,
	#superclass : #GlorpDatabaseType,
	#instVars : [
		'representationType'
	],
	#classInstVars : [
		'count'
	],
	#category : #'Glorp-Types'
}

{ #category : #accessing }
GlorpInMemorySequenceDatabaseType class >> next [

	(count isNil)
	ifTrue: [count := 0].
	count := count + 1.
	^count
]

{ #category : #'instance creation' }
GlorpInMemorySequenceDatabaseType class >> representedBy: dbType [

	^super new
		representedBy: dbType
]

{ #category : #accessing }
GlorpInMemorySequenceDatabaseType class >> reset [

	count := 0
]

{ #category : #converting }
GlorpInMemorySequenceDatabaseType >> impliedSmalltalkType [
	^Integer.
]

{ #category : #testing }
GlorpInMemorySequenceDatabaseType >> isGenerated [

	^true
]

{ #category : #SQL }
GlorpInMemorySequenceDatabaseType >> preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: anAccessor [

	aDatabaseRow at: aDatabaseField put: (self class next)
]

{ #category : #'initialize-release' }
GlorpInMemorySequenceDatabaseType >> representedBy: dbType [

	representationType := dbType
]

{ #category : #SQL }
GlorpInMemorySequenceDatabaseType >> typeName [

	^representationType typeName.
]

{ #category : #SQL }
GlorpInMemorySequenceDatabaseType >> typeString [

	^representationType typeString
]
