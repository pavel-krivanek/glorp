Class {
	#name : #GlorpTypeTestsModelClass,
	#superclass : #Object,
	#instVars : [
		'id',
		'test'
	],
	#category : #'GlorpDBTests-Glorp-DBTests'
}

{ #category : #'VisualWorks metadata' }
GlorpTypeTestsModelClass class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #'As yet unclassified' }
GlorpTypeTestsModelClass >> test [
	^test.
]

{ #category : #'As yet unclassified' }
GlorpTypeTestsModelClass >> test: anObject [
	test:= anObject.
]
