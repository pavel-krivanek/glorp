Class {
	#name : #GlorpDatabaseBasedTest,
	#superclass : #GlorpTestCase,
	#instVars : [
		'system'
	],
	#category : #GlorpDBTests
}

{ #category : #support }
GlorpDatabaseBasedTest >> setUp [
	system := GlorpDemoDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database.
	system session: GlorpMockSession new.
	system session system: system.
]
