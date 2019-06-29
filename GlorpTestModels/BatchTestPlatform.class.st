"
I am a test platform for batch insert and update code.  This code, when bound, is nowhere used, since my superclass, which did use it, now always uses array binding. 


"
Class {
	#name : #BatchTestPlatform,
	#superclass : #SQLServerPlatform,
	#category : #'GlorpTestModels-Glorp'
}

{ #category : #'VisualWorks metadata' }
BatchTestPlatform class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #binding }
BatchTestPlatform >> bindingsForGroupWritingFor: aCommand [
	"Binding in batch is my reason-d'etre."

	^aCommand batchStatementBindings
]

{ #category : #commands }
BatchTestPlatform >> insertCommandForRows: aCollectionOfDatabaseRows binding: aBoolean session: aSession [
	"I do not array bind;  whether binding or not, I can only group if I support group-writing of values."

	^self supportsGroupWritingValues
		ifTrue: [InsertSelectRowsCommand
				forRows: aCollectionOfDatabaseRows
				useBinding: aBoolean
				session: aSession
				ifNoIdentityColumn: InsertMultiValuesCommand]
		ifFalse: [InsertSelectRowCommand
				forRows: aCollectionOfDatabaseRows
				useBinding: aBoolean
				session: aSession
				ifNoIdentityColumn: InsertCommand]
]

{ #category : #commands }
BatchTestPlatform >> updateCommandForRows: someDatabaseRows binding: aBoolean session: aSession [
	^(someDatabaseRows first fields anySatisfy: [:each | each type isRelativeType])
		ifFalse: [BatchTestUpdateCommand forRows: someDatabaseRows useBinding: aBoolean session: aSession]
		ifTrue: [self relativeUpdateCommand forRows: someDatabaseRows useBinding: aBoolean session: aSession]
]

{ #category : #testing }
BatchTestPlatform >> usesArrayBindingToGroupWrite [
	"My purpose is to test batch binding, so we deliberately do not use arrays."

	^false
]
