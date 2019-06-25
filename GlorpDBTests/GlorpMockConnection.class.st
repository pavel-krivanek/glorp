"
GlorpMockConnection allows any checks which pass through GlorpMockAccessor to work OK..


"
Class {
	#name : #GlorpMockConnection,
	#superclass : #Object,
	#category : #'GlorpDBTests-GlorpDatabase'
}

{ #category : #'VisualWorks metadata' }
GlorpMockConnection class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpMockConnection >> lastAutoIncrementValue [
	^3
]
