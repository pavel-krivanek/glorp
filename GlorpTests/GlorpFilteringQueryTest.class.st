Class {
	#name : #GlorpFilteringQueryTest,
	#superclass : #TestCase,
	#category : #GlorpTests
}

{ #category : #'VisualWorks metadata' }
GlorpFilteringQueryTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'XProgramming.SUnit'
	)

]

{ #category : #support }
GlorpFilteringQueryTest >> setUp [
]

{ #category : #tests }
GlorpFilteringQueryTest >> testSimple [
	| query result |
	query := FilteringQuery on: #( 1 2 3 4 5 6 7 8) filter: [:each :parameters | each odd].
	result := GlorpSession new execute: query.
	self assert: result = #(1 3 5 7).
]
