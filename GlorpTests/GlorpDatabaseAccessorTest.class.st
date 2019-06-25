Class {
	#name : #GlorpDatabaseAccessorTest,
	#superclass : #GlorpTestCase,
	#category : #'GlorpTests-GlorpTest'
}

{ #category : #'VisualWorks metadata' }
GlorpDatabaseAccessorTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #tests }
GlorpDatabaseAccessorTest >> testLoggingSwitch [
	| currentSetting accessor |
	currentSetting := DatabaseAccessor loggingEnabled.
	accessor := DatabaseAccessor new.
	[DatabaseAccessor loggingEnabled: true.
	self assert: accessor logging.
	DatabaseAccessor loggingEnabled: false.
	self deny: accessor logging.
	accessor logging: true.
	self assert: accessor logging.
	accessor logging: false.
	self deny: accessor logging.
	DatabaseAccessor loggingEnabled: true.
	self deny: accessor logging] ensure: [DatabaseAccessor loggingEnabled: currentSetting].
]
