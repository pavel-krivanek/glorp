Class {
	#name : #GlorpEmployee,
	#superclass : #GlorpWorkingStiff,
	#category : #GlorpTestModels
}

{ #category : #'as yet unclassified' }
GlorpEmployee class >> glorpTypeResolver [
	^FilteredTypeResolver forRootClass: GlorpEmployee
]
