"
GlorpTransientEmployee is used to test that not all subclasses need to be persistent in inheritance mapping.
"
Class {
	#name : #GlorpTransientEmployee,
	#superclass : #GlorpEmployee,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpTransientEmployee class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
