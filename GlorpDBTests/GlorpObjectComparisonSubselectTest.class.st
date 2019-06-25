Class {
	#name : #GlorpObjectComparisonSubselectTest,
	#superclass : #GlorpObjectComparisonJoinsTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpObjectComparisonSubselectTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #support }
GlorpObjectComparisonSubselectTest >> setUp [
	super setUp.
	session system useJoinsForAnySatisfy: false.
]
