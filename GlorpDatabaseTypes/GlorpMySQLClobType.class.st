"
MySQL clobs come back from the driver as binary data, so we need to make a subclass that knows it needs a converter for its incoming data.
"
Class {
	#name : #GlorpMySQLClobType,
	#superclass : #GlorpBlobType,
	#category : #GlorpDatabaseTypes
}

{ #category : #'VisualWorks metadata' }
GlorpMySQLClobType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'as yet unclassified' }
GlorpMySQLClobType >> impliedSmalltalkType [
	^String
]
