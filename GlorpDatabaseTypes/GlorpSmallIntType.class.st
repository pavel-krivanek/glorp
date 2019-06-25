"
Small int type 
"
Class {
	#name : #GlorpSmallIntType,
	#superclass : #GlorpAbstractIntegerType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'VisualWorks metadata' }
GlorpSmallIntType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #initialize }
GlorpSmallIntType >> initialize [
	super initialize.
	typeString := 'smallint'.
]
