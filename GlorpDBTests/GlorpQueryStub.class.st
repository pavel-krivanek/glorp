"
A test class. This behaves like a query, but doesn't go to the database, it just returns whatever it was told to return on its creation, regardless of the parameters or session.

Instance Variables:
	result	<Object>	The thing we should return.


"
Class {
	#name : #GlorpQueryStub,
	#superclass : #AbstractReadQuery,
	#instVars : [
		'result'
	],
	#category : #GlorpDBTests
}

{ #category : #'instance creation' }
GlorpQueryStub class >> newQuery [
	^self new.
]

{ #category : #'VisualWorks metadata' }
GlorpQueryStub class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
GlorpQueryStub >> executeWithParameters: parameterArray in: aSession [ 

	aSession register: result.
	^result.
]

{ #category : #initialize }
GlorpQueryStub >> initialize [

	super initialize.
	readsOneObject := true.
]

{ #category : #accessing }
GlorpQueryStub >> result [
	^result
]

{ #category : #accessing }
GlorpQueryStub >> result: anObject [
	result := anObject
]