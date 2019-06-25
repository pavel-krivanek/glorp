Class {
	#name : #GlorpNoProxyCollectionReadTest,
	#superclass : #TestCase,
	#category : #GlorpTests
}

{ #category : #'VisualWorks metadata' }
GlorpNoProxyCollectionReadTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'XProgramming.SUnit'
	)

]

{ #category : #tests }
GlorpNoProxyCollectionReadTest >> testReadCollectionWithoutProxies [
	| persons session |
	session := GlorpSessionResource current newSession.
	session platform supportsMultipleOpenCursors ifFalse: [^self].
	(session system descriptorFor: GlorpPerson) mappings do:
		[:each | (each respondsTo: #shouldProxy:) ifTrue: [each shouldProxy: false]].
	session beginTransaction.
	[session beginUnitOfWork.
	session register: GlorpPerson example1.
	session register: GlorpPerson example2.
	session commitUnitOfWork.
	session reset.
	persons := session read: GlorpPerson.
	self assert: persons size = 2] ensure: [session rollbackTransaction].
]
