"
I hold strings to trim, write and read, so checking behaviour under a range of character encodings

Instance Variables:
	byteString	<String>	written to a varchar
	encodedString	<String>	written to an nvarchar (thus sure to get some UTF encoding)
	id	<Integer>	for convenient tracking and recovery of rows for testing


"
Class {
	#name : #GlorpStringExamples,
	#superclass : #Object,
	#instVars : [
		'id',
		'byteString',
		'encodedString'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpStringExamples class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpStringExamples >> byteString [

	^byteString
]

{ #category : #accessing }
GlorpStringExamples >> byteString: anObject [

	byteString := anObject
]

{ #category : #accessing }
GlorpStringExamples >> encodedString [

	^encodedString
]

{ #category : #accessing }
GlorpStringExamples >> encodedString: anObject [

	encodedString := anObject
]

{ #category : #accessing }
GlorpStringExamples >> id [

	^id
]

{ #category : #accessing }
GlorpStringExamples >> id: anObject [

	id := anObject
]
