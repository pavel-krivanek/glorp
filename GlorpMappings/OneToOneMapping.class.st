"
This represents a simple one to one relationship, e.g. from Person to Address. Assuming each person has only one address. Note that this has no methods, since a to-one relationship is the default for RelationshipMapping.
"
Class {
	#name : #OneToOneMapping,
	#superclass : #RelationshipMapping,
	#category : #'GlorpMappings-Glorp'
}

{ #category : #'VisualWorks metadata' }
OneToOneMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
