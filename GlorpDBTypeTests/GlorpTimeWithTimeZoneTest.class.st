Class {
	#name : #GlorpTimeWithTimeZoneTest,
	#superclass : #GlorpTimeTest,
	#instVars : [
		'priorTimeZone'
	],
	#category : #GlorpDBTypeTests
}

{ #category : #'VisualWorks metadata' }
GlorpTimeWithTimeZoneTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpTimeWithTimeZoneTest >> defaultDatabaseType [
	"For now, non-supporting platforms just repeat the superclass' tests.  Later, raise explicit test skip for non-supporting platforms."

	self platform isPostgreSQLPlatform ifTrue: [^self platform timetz].
	^super defaultDatabaseType
]

{ #category : #setUp }
GlorpTimeWithTimeZoneTest >> setUp [

	| exdiConnection tz |
	super setUp.
	self platform isPostgreSQLPlatform
		ifTrue: 
			[exdiConnection := connection connection.
			priorTimeZone := exdiConnection timezone.
			tz := exdiConnection suggestedDefaultTimeZone.
			exdiConnection timezone: tz]
]

{ #category : #setUp }
GlorpTimeWithTimeZoneTest >> tearDown [

	| exdiConnection |
	self platform isPostgreSQLPlatform
		ifTrue: 
			[exdiConnection := connection connection.
			exdiConnection timezone: priorTimeZone].
	super tearDown
]
