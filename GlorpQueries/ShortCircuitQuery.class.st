"
I do not go to the database but simply return a (copy of a) value I hold, usually nil or an empty collection.  I am used to suppress needless subqueries when it is known the information will soon be provided by another route, e.g. will be alsoFetched.

Instance Variables:
	resultTemplate	<Object | nil>	provides the nil/empty/default value whose copy I return
"
Class {
	#name : #ShortCircuitQuery,
	#superclass : #Object,
	#instVars : [
		'resultTemplate'
	],
	#category : #GlorpQueries
}

{ #category : #'VisualWorks metadata' }
ShortCircuitQuery class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #executing }
ShortCircuitQuery >> executeWithParameters: parameterArray in: aSession [ 
	^resultTemplate copy
]

{ #category : #accessing }
ShortCircuitQuery >> resultTemplate: anObject [ 
	resultTemplate := anObject.
]

{ #category : #testing }
ShortCircuitQuery >> shortCircuitEmptyReturn: parameters [
	^true
]
