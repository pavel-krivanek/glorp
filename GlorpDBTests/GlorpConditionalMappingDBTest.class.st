"
When an object is registered, either at top-level or as part of completing the transitive closure of registration, and that object's descriptor includes a ConditionalMapping, neither the conditional mapping nor its resolved mapping for that object adds itself to the transitive closure.  Thus only simple direct mappings can be conditional.  Write a test that shows this, thus fix it.
"
Class {
	#name : #GlorpConditionalMappingDBTest,
	#superclass : #GlorpMappingDBTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpConditionalMappingDBTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]
