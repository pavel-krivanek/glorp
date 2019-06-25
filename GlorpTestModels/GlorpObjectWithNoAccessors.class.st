Class {
	#name : #GlorpObjectWithNoAccessors,
	#superclass : #Object,
	#instVars : [
		'alue'
	],
	#category : #GlorpTestModels
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
