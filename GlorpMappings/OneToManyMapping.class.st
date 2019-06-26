"
This represents a mapping from one object to a collection of others. This class is really only here for backward compatibility. Using ToManyMapping directly will give exactly the same behaviour.


"
Class {
	#name : #OneToManyMapping,
	#superclass : #ToManyMapping,
	#category : #'GlorpMappings-Glorp'
}

{ #category : #'VisualWorks metadata' }
OneToManyMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
