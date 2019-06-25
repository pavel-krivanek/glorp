Class {
	#name : #GlorpTimeWithTimeZoneTest,
	#superclass : #GlorpTimeTest,
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
