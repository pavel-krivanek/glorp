Class {
	#name : #GlorpTimestampWithTimeZoneTest,
	#superclass : #GlorpTimestampTest,
	#instVars : [
		'priorTimeZone'
	],
	#category : #GlorpDBTypeTests
}

{ #category : #'VisualWorks metadata' }
GlorpTimestampWithTimeZoneTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpTimestampWithTimeZoneTest >> defaultDatabaseType [
	"For now, non-supporting platforms just repeat the superclass' tests.  Later, raise explicit test skip for non-supporting platforms."

	self platform isPostgreSQLPlatform ifTrue: [^self platform timestamptz].
	^super defaultDatabaseType
]

{ #category : #setUp }
GlorpTimestampWithTimeZoneTest >> setUp [
	| exdiConnection tz |
	super setUp.
	self platform isPostgreSQLPlatform ifTrue:
		[exdiConnection := connection connection.
		priorTimeZone := exdiConnection timezone.
		tz := exdiConnection suggestedDefaultTimeZone.
		exdiConnection timezone: tz].
]

{ #category : #setUp }
GlorpTimestampWithTimeZoneTest >> tearDown [
	| exdiConnection |
	self platform isPostgreSQLPlatform ifTrue:
		[exdiConnection := connection connection.
		exdiConnection timezone: priorTimeZone].
	super tearDown.
]
