Class {
	#name : #GlorpRegionalManager,
	#superclass : #GlorpManager,
	#instVars : [
		'region'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpRegionalManager class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #comparing }
GlorpRegionalManager >> = aRegionalManager [
	^super = aRegionalManager and: [region = aRegionalManager region].
]

{ #category : #accessing }
GlorpRegionalManager >> region [
	^region
]

{ #category : #accessing }
GlorpRegionalManager >> region: anObject [
	region := anObject
]
