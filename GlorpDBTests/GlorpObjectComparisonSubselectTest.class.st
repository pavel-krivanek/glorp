Class {
	#name : #GlorpObjectComparisonSubselectTest,
	#superclass : #GlorpObjectComparisonJoinsTest,
	#category : #GlorpDBTests
}

{ #category : #support }
GlorpObjectComparisonSubselectTest >> setUp [
	super setUp.
	session system useJoinsForAnySatisfy: false.
]
