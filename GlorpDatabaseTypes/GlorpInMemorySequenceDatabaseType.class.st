Class {
	#name : #GlorpInMemorySequenceDatabaseType,
	#superclass : #GlorpDatabaseType,
	#instVars : [
		'representationType'
	],
	#classInstVars : [
		'count'
	],
	#category : #GlorpDatabaseTypes
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

{ #category : #'exdi specific' }
GlorpInMemorySequenceDatabaseType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^representationType exdiType.
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
