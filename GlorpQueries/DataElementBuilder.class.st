"
This builds raw data items rather than persistent objects with descriptors.  It is used if we do e.g.
	aQuery retrieve: [:each | each address streetName].
giving us back simple data objects.
"
Class {
	#name : #DataElementBuilder,
	#superclass : #ElementBuilder,
	#category : #'GlorpQueries-Glorp'
}

{ #category : #'VisualWorks metadata' }
DataElementBuilder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'building objects' }
DataElementBuilder >> buildObjectFrom: anArray [
	self row: anArray.
	instance := self valueOf: expression.
]

{ #category : #'building objects' }
DataElementBuilder >> didValidationFail: validateResult [

	"In other words, don't treat the result of the validation send to the object as a failure if the object was the boolean false, so returning self would normally be interpreted as the failure"
	validateResult == self instance ifTrue: [^false].

	^super didValidationFail: validateResult.
]

{ #category : #'selecting fields' }
DataElementBuilder >> fieldsForSelectStatement [
	^Array with: expression.
]

{ #category : #'selecting fields' }
DataElementBuilder >> fieldsFromMyPerspective [
	^expression mappedFields.
]

{ #category : #'building objects' }
DataElementBuilder >> findInstanceForRow: aRow proxyType: proxyType [

	^self.
]

{ #category : #copying }
DataElementBuilder >> onCompoundCursor: aGlorpCursoredStream [
	^expression class == ConstantExpression
		ifFalse: [self cursor: aGlorpCursoredStream]
		ifTrue: [CompoundConstantBuilder new postCopy
				expression: expression;
				query: query;
				fieldTranslations: fieldTranslations;
				cursor: aGlorpCursoredStream]
]
