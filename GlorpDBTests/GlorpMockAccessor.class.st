Class {
	#name : #GlorpMockAccessor,
	#superclass : #DatabaseAccessor,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpMockAccessor class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
GlorpMockAccessor >> basicExecuteSQLString: aString [
	^ReadStream on: #(#(3)).
]

{ #category : #executing }
GlorpMockAccessor >> executeCommand: aCommand returnCursor: aBoolean [
	| result |
	result := #(#(3)).
	^aBoolean ifTrue: [result readStream] ifFalse: [result].
]

{ #category : #executing }
GlorpMockAccessor >> executeSQLString: aString [
	^#((3)).
]

{ #category : #accessing }
GlorpMockAccessor >> schema [
	^''
]