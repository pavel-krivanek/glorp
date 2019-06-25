Class {
	#name : #GlorpSessionBasedTest,
	#superclass : #GlorpDatabaseBasedTest,
	#instVars : [
		'session'
	],
	#category : #'GlorpDBTests-GlorpTest'
}

{ #category : #resources }
GlorpSessionBasedTest class >> resources [
	^Array with: GlorpDatabaseLoginResource with: GlorpSessionResource with: GlorpDemoTablePopulatorResource.
]

{ #category : #'VisualWorks metadata' }
GlorpSessionBasedTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #support }
GlorpSessionBasedTest >> setUp [
	super setUp.
	session := GlorpSessionResource current newSession.
	system session: session.
	session system: system.
]

{ #category : #support }
GlorpSessionBasedTest >> tearDown [
	session isNil ifFalse: [session reset. session resetPermissions].
	session := nil.
	super tearDown.
]
