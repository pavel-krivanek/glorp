"
This is just an object we can easily identify by identity, used for transaction test debugging. We can put these into a transaction and easily distinguish them from their copies.

"
Class {
	#name : #IdentityHashPrintingObject,
	#superclass : #Object,
	#category : #GlorpTests
}

{ #category : #'VisualWorks metadata' }
IdentityHashPrintingObject class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #printing }
IdentityHashPrintingObject >> printOn: aStream [
	aStream nextPutAll: 'thing with hash '.
	self identityHash printOn: aStream.
]
