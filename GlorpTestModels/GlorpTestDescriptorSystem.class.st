"
This is an abstract superclass for all descriptor systems whose tables should be set up as part of the standard GLORP testing process. See GlorpDemoTablePopulatorResource.
"
Class {
	#name : #GlorpTestDescriptorSystem,
	#superclass : #DescriptorSystem,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpTestDescriptorSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
