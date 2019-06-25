"
GlorpSalariedEmployee is currently a standalone class unrelated to the rest of its hierarchy.

Instance Variables:
	salary	<Number>	to test immutable literal values


"
Class {
	#name : #GlorpSalariedEmployee,
	#superclass : #GlorpWorkingStiff,
	#instVars : [
		'salary'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpSalariedEmployee class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpSalariedEmployee >> id [
	^id
]

{ #category : #accessing }
GlorpSalariedEmployee >> id: anInteger [
	id := anInteger
]

{ #category : #accessing }
GlorpSalariedEmployee >> salary [
	^salary
]

{ #category : #accessing }
GlorpSalariedEmployee >> salary: aNumber [
	salary := aNumber
]
