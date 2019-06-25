Class {
	#name : #GlorpCharType,
	#superclass : #GlorpAbstractStringType,
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpCharType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #initialize }
GlorpCharType >> initialize [
	super initialize.
	typeString := 'char'.
]

{ #category : #testing }
GlorpCharType >> isVariableWidth [
	^false.
]

{ #category : #accessing }
GlorpCharType >> typeString [

	^self typeName, '(', width printString, ')'.
]
