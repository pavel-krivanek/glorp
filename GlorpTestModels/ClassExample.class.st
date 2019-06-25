"
I am a data-storing test object.  I trace to myself, to allow examination of the case where the class model value is nil but the database column has a default value (e.g. of 0).

Instance Variables:
	id		<Integer>		the primary key
	trace		<Example | nil>	the previous version
	value	<String>			the data

"
Class {
	#name : #ClassExample,
	#superclass : #Object,
	#instVars : [
		'id',
		'trace',
		'value'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassExample class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassExample class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #'instance creation' }
ClassExample class >> withValue: aValue [

	^(self new)
		value: aValue;
		yourself
]

{ #category : #accessing }
ClassExample >> id [

	^id
]

{ #category : #accessing }
ClassExample >> id: anObject [

	id := anObject
]

{ #category : #'initialize-release' }
ClassExample >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	id := nil.
	trace := nil.
	value := 'test'.
]

{ #category : #accessing }
ClassExample >> trace [

	^trace
]

{ #category : #accessing }
ClassExample >> trace: anObject [

	trace := anObject
]

{ #category : #accessing }
ClassExample >> value [

	^value
]

{ #category : #accessing }
ClassExample >> value: anObject [

	value := anObject
]
