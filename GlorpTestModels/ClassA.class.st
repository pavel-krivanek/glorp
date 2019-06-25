"
ClassA

Instance Variables:
	attrAClassA	<MessageForwarder | Object | ProtoObject | ProtoObject | Proxy>	description of attrAClassA
	attrBClassA	<MessageForwarder | Object | ProtoObject | ProtoObject | Proxy>	description of attrBClassA
	attrCClassA	<MessageForwarder | Object | ProtoObject | ProtoObject | Proxy>	description of attrCClassA
	attrDClassA	<MessageForwarder | Object | ProtoObject | ProtoObject | Proxy>	description of attrDClassA
	attrEClassA	<Boolean>	proxied boolean (a very unusual case, for test 03;  normally, booleans are direct unproxied mappings)
	attrFClassA	<Collection>	some ClassBs
	attrGClassA	<Collection>	some ClassIs
	attrHClassA	<Boolean>	unproxied boolean (the standard case)


"
Class {
	#name : #ClassA,
	#superclass : #Object,
	#instVars : [
		'attrAClassA',
		'attrBClassA',
		'attrCClassA',
		'attrDClassA',
		'attrEClassA',
		'attrFClassA',
		'attrGClassA',
		'attrHClassA'
	],
	#category : #GlorpTestModels
}

{ #category : #'instance creation' }
ClassA class >> new [
	"Answer a newly created and initialized instance."

	^super new initialize
]

{ #category : #'VisualWorks metadata' }
ClassA class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ClassA >> attrAClassA [

	^attrAClassA
]

{ #category : #accessing }
ClassA >> attrAClassA: anObject [

	attrAClassA := anObject
]

{ #category : #accessing }
ClassA >> attrBClassA [

	^attrBClassA
]

{ #category : #accessing }
ClassA >> attrBClassA: anObject [

	attrBClassA := anObject
]

{ #category : #accessing }
ClassA >> attrCClassA [

	^attrCClassA
]

{ #category : #accessing }
ClassA >> attrCClassA: anObject [

	attrCClassA := anObject
]

{ #category : #accessing }
ClassA >> attrDClassA [

	^attrDClassA
]

{ #category : #accessing }
ClassA >> attrDClassA: anObject [

	attrDClassA := anObject
]

{ #category : #accessing }
ClassA >> attrEClassA [
	^attrEClassA
]

{ #category : #accessing }
ClassA >> attrEClassA: aBoolean [
	attrEClassA := aBoolean.
]

{ #category : #accessing }
ClassA >> attrFClassA [

	^attrFClassA
]

{ #category : #accessing }
ClassA >> attrFClassA: anObject [

	attrFClassA := anObject
]

{ #category : #accessing }
ClassA >> attrGClassA [

	^attrGClassA
]

{ #category : #accessing }
ClassA >> attrGClassA: anObject [

	attrGClassA := anObject
]

{ #category : #accessing }
ClassA >> attrHClassA [
	^attrHClassA
]

{ #category : #accessing }
ClassA >> attrHClassA: aBoolean [
	attrHClassA := aBoolean.
]

{ #category : #testing }
ClassA >> hasClassBWithPK: aClassBPKVal [
	^self attrFClassA anySatisfy: [:classB | classB attrAClassB = aClassBPKVal]
]

{ #category : #testing }
ClassA >> hasClassIWithClassC: aClassCObj [
	^self attrGClassA anySatisfy: [:classI | classI attrBClassI = aClassCObj]
]

{ #category : #'initialize-release' }
ClassA >> initialize [
	"Initialize a newly created instance. This method must answer the receiver."

	super initialize.
	attrFClassA := OrderedCollection new.
]

{ #category : #'initialize-release' }
ClassA >> newClassB [

	| newClassB |
	newClassB := ClassB new.
	attrFClassA add: newClassB.
	^newClassB
]

{ #category : #'initialize-release' }
ClassA >> newClassI [

	| newClassI |
	newClassI := ClassI new.
	attrGClassA add: newClassI.
	^newClassI
]
