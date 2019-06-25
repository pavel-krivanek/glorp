Class {
	#name : #GlorpMappingDBTest,
	#superclass : #GlorpTestCase,
	#instVars : [
		'system',
		'session'
	],
	#category : #'GlorpDBTests-GlorpTest'
}

{ #category : #testing }
GlorpMappingDBTest class >> isAbstract [
	^self sunitName = #GlorpMappingDBTest
]

{ #category : #resources }
GlorpMappingDBTest class >> resources [
	^Array with: GlorpSessionResource.
]

{ #category : #'VisualWorks metadata' }
GlorpMappingDBTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #support }
GlorpMappingDBTest >> inTransactionDo: aBlock [
	[session beginTransaction.
	aBlock value] ensure: [session rollbackTransaction].
]

{ #category : #Running }
GlorpMappingDBTest >> setUp [
	super setUp.
	session := GlorpSessionResource current newSession.
	system := session system.
]

{ #category : #support }
GlorpMappingDBTest >> tearDown [
	super tearDown.
	session reset.
	session resetPermissions.
	session := nil.
	system := nil.
]
