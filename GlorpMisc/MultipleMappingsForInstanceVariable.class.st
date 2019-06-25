"
This error raises when validating a descriptor if there is more than one mapping to the same instance variable.

Instance Variables:
	attributeNames	<Collection of String>	the list of attributes referencing the same instance variable
	readableMappings	<Collection of Mapping>	the list of mappings referencing the same instance variable


"
Class {
	#name : #MultipleMappingsForInstanceVariable,
	#superclass : #ValidationError,
	#instVars : [
		'attributeNames',
		'readableMappings'
	],
	#category : #GlorpMisc
}

{ #category : #'VisualWorks metadata' }
MultipleMappingsForInstanceVariable class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
MultipleMappingsForInstanceVariable >> attributeNames [
	^attributeNames
]

{ #category : #accessing }
MultipleMappingsForInstanceVariable >> attributeNames: anObject [
	attributeNames := anObject
]

{ #category : #accessing }
MultipleMappingsForInstanceVariable >> messageText [
	^'Multiple readable mappings for one instance variable:<1s>' expandMacrosWith: self readableMappings  printString
]

{ #category : #accessing }
MultipleMappingsForInstanceVariable >> readableMappings [
	^readableMappings
]

{ #category : #accessing }
MultipleMappingsForInstanceVariable >> readableMappings: anObject [
	readableMappings := anObject
]
