Class {
	#name : #GlorpTimeType,
	#superclass : #GlorpDatabaseType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'VisualWorks metadata' }
GlorpTimeType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'conversion-times' }
GlorpTimeType >> converterForStType: aClass [

	^self platform converterNamed: #time.
]

{ #category : #'exdi specific' }
GlorpTimeType >> exdiType [
	"Return a symbol that the VisualWorks EXDI uses to indicate the database type -- this is a symbol which is often the name of a Smalltalk class, but with variations for multiple db types that correspond to the same Smalltalk symbol. It also varies by Database. This is equivalent to the values returned by methods like #odbcConversion or #oracleConversion"
	^#Time.
]

{ #category : #converting }
GlorpTimeType >> impliedSmalltalkType [
	^Time.
]

{ #category : #SQL }
GlorpTimeType >> print: aValue on: aStream [
	aStream nextPutAll: (self platform printTime: aValue for: self).
]