Class {
	#name : #GlorpDatabaseBasedTest,
	#superclass : #GlorpTestCase,
	#instVars : [
		'system'
	],
	#category : #'GlorpDBTests-GlorpTest'
}

{ #category : #'VisualWorks metadata' }
GlorpDatabaseBasedTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #support }
GlorpDatabaseBasedTest >> setUp [
	system := GlorpDemoDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database.
	system session: GlorpMockSession new.
	system session system: system.
]
