"
I am the root class of a FilteredType-resolved hierarchy.

"
Class {
	#name : #GlorpEmployee,
	#superclass : #GlorpWorkingStiff,
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'glorp setup' }
GlorpEmployee class >> glorpTypeResolver [
	^FilteredTypeResolver forRootClass: GlorpEmployee
]

{ #category : #'VisualWorks metadata' }
GlorpEmployee class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
