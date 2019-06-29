"
I handle types that understand numeric operators.
"
Class {
	#name : #GlorpAbstractNumericType,
	#superclass : #GlorpDatabaseType,
	#category : #'GlorpDatabaseTypes-Glorp-PostgreSQL'
}

{ #category : #'VisualWorks metadata' }
GlorpAbstractNumericType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpAbstractNumericType >> beRelative [
	"When a mapping to a field with this type updates the database, the difference between the original and changed values is added to the value in the database, and (if #supportsReturningUpdatedValues is true) the resulting value in the database is returned, to be set on the object."

	^(GlorpRelativeValueType new underlyingType: self)
		platform: self platform;
		selector: self selector;
		typeString: self typeString;
		yourself
]

{ #category : #converting }
GlorpAbstractNumericType >> impliedSmalltalkType [
	^Number.
]
