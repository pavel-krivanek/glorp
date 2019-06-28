"
My expression is a ConstantExpression but I am the builder in the cursor returned by a CompoundQuery, copied from a builder of its primaryQuery's builder.  Since the corresponding ConstantExpressions of other subqueries may have different values, I always return the row's value for me, not my expression's value.


"
Class {
	#name : #CompoundConstantBuilder,
	#superclass : #DataElementBuilder,
	#category : #GlorpQueries
}

{ #category : #'VisualWorks metadata' }
CompoundConstantBuilder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #copying }
CompoundConstantBuilder >> onCompoundCursor: aGlorpCursoredStream [
	"Return to the super-super-implementation;  no need for the super-implementation to create me twice."

	^self cursor: aGlorpCursoredStream
]

{ #category : #'translating fields' }
CompoundConstantBuilder >> valueOf: anExpression [
	^self row atIndex: (self translateFieldPosition: expression)
]

{ #category : #'translating fields' }
CompoundConstantBuilder >> valueOfField: aField [
	"The parameter aField is either a database field or a constant expression containing a non-varying value that isn't derived from the database row but was written to the select statement and so returned as a value in the row.  As I am a builder of a compound query, whose subqueries could have different values for tha constant, get the value returned by the row."

	^self row atIndex: (self translateFieldPosition: aField)
]

{ #category : #'translating fields' }
CompoundConstantBuilder >> valueOfField: aField in: aRow [
	"The elementBuilder holds the row, so #valueOfField: is the recommended protocol in all ordinary cases.  An AdHocProxy's readBlock could be set by an AdHocMapping at one point, then evaluated later, after the ElementBuilder had been assigned another row.  This protocol remains for that rare case -  see #testReadAdHocProxied.
	The parameter aField is either a database field or a constant expression containing a non-varying value that isn't derived from the database row but was written to the select statement and so returned as a value in the row.  As I am a builder of a compound query, whose subqueries could have different values for tha constant, get the value returned by the row."

	^aRow atIndex: (self translateFieldPosition: aField)
]
