Class {
	#name : #GlorpExampleSystem,
	#superclass : #Object,
	#instVars : [
		'objects'
	],
	#category : #'GlorpTestModels-GlorpTest'
}

{ #category : #'instance creation' }
GlorpExampleSystem class >> new [

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
GlorpExampleSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #initialize }
GlorpExampleSystem >> initialize [

	objects := Dictionary new.
]

{ #category : #misc }
GlorpExampleSystem >> lookupObject: aNumber ofClass: aClass ifAbsentPut: absentBlock [

	^(objects at: aClass ifAbsentPut: [Dictionary new]) at: aNumber ifAbsentPut: absentBlock.
]

{ #category : #api }
GlorpExampleSystem >> objectNumber: aNumber ofClass: aClass [

	| symbol instance|
	instance := self lookupObject: aNumber ofClass: aClass ifAbsentPut: [aClass new].
	symbol := ('example', aClass name, 'Number', aNumber printString, ':') asSymbol.
	self perform: symbol with: instance.
	^instance.
]
