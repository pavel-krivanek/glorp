Class {
	#name : #GlorpLineWorker,
	#superclass : #GlorpEmployee,
	#instVars : [
		'productionLine'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpLineWorker class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #comparing }
GlorpLineWorker >> = aLineWorker [
	^super = aLineWorker and: [productionLine = aLineWorker productionLine].
]

{ #category : #accessing }
GlorpLineWorker >> productionLine [
	^productionLine
]

{ #category : #accessing }
GlorpLineWorker >> productionLine: anObject [
	productionLine := anObject
]
