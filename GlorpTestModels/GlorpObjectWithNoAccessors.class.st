Class {
	#name : #GlorpObjectWithNoAccessors,
	#superclass : #Object,
	#instVars : [
		'alue'
	],
	#category : #GlorpTestModels
}

{ #category : #accessing }
GlorpObjectWithNoAccessors >> extremelyPrivateValue: aString [
	alue := aString
]
