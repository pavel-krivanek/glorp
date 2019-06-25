Class {
	#name : #GlorpFakeElementBuilder,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #GlorpTests
}

{ #category : #'VisualWorks metadata' }
GlorpFakeElementBuilder class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpFakeElementBuilder >> value: anObject [
	value := anObject.
]

{ #category : #'element builder protocol' }
GlorpFakeElementBuilder >> valueOf: aField [
	^value.
]

{ #category : #'element builder protocol' }
GlorpFakeElementBuilder >> valueOfField: aField in: anArray [

	^value.
]
