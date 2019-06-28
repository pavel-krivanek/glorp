Extension { #name : #ElementBuilder }

{ #category : #'*GlorpDatabase-translating fields' }
ElementBuilder >> valueOf: anExpression [
	^expression valueInBuilder: self.
]

{ #category : #'*GlorpDatabase-translating fields' }
ElementBuilder >> valueOfField: aField [
	"aField is either a database field, or a constant expression containing a non-varying value that isn't derived from the row"
	(aField class == ConstantExpression) ifTrue: [^aField value].
	^self row atIndex: (self translateFieldPosition: aField).
]

{ #category : #'*GlorpDatabase-translating fields' }
ElementBuilder >> valueOfField: aField in: aRow [
	"The elementBuilder holds the row, so #valueOfField: is the recommended protocol in all ordinary cases.  An AdHocProxy's readBlock could be set by an AdHocMapping at one point, then evaluated later, after the ElementBuilder had been assigned another row.  This protocol remains for that case -  see #testReadAdHocProxied."

	(aField class == ConstantExpression) ifTrue: [^aField value].
	^aRow atIndex: (self translateFieldPosition: aField).
]
