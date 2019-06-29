"
The GlorpTravelFolder and GlorpTravelFile test classes are not (at time of creation) connected to GlorpTravelAgent and the other long-established Glorp test classes;  they have a separate descriptor system, etc..  Their names were chosen just to make it obvious that they are also test objects.
"
Class {
	#name : #GlorpTravelFile,
	#superclass : #Object,
	#instVars : [
		'id',
		'name'
	],
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpTravelFile class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpTravelFile >> <= aTravelFile [
	^self name <= aTravelFile name.
]

{ #category : #accessing }
GlorpTravelFile >> id [

	^id
]

{ #category : #accessing }
GlorpTravelFile >> id: anObject [

	id := anObject
]

{ #category : #accessing }
GlorpTravelFile >> name [

	^name
]

{ #category : #accessing }
GlorpTravelFile >> name: anObject [

	name := anObject
]

{ #category : #accessing }
GlorpTravelFile >> nameChunks [
	^name
]

{ #category : #accessing }
GlorpTravelFile >> nameChunks: someStrings [
	"Having this method exist is the easiest way to prevent validation complaining about the mapping named #namedChunks being readable as well as writable.  However it is not clear it needs to do anything.  (Later, evolve GlorpSubsequenceMappings not to need this.)"
]
