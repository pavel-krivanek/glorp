Class {
	#name : #GlorpObjectWithNoAccessors,
	#superclass : #Object,
	#instVars : [
		'alue'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpObjectWithNoAccessors class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpObjectWithNoAccessors >> extremelyPrivateValue: aString [
	alue := aString
]
