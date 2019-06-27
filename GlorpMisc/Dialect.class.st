"
This is an encapsulation layer for dialect differences between Smalltalk. It has a variety of class messages that do different things depending which dialect we are running on.
"
Class {
	#name : #Dialect,
	#superclass : #Object,
	#classInstVars : [
		'dialectName',
		'timestampClass',
		'lookedUpNames',
		'isNamespaceAware',
		'lastSystemTime',
		'lastServerTime'
	],
	#category : #'GlorpMisc-Kernel-Support'
}

{ #category : #files }
Dialect class >> contentsOfFileNamed: aString [ 
	"Given a text file name, read its contents"

	| stream contents fileClass |
	Dialect isVisualWorks ifTrue: [^aString asFilename contentsOfEntireFile].
	Dialect isSqueak ifTrue: [
		stream := (Dialect smalltalkAt: #CrLfFileStream) oldFileNamed: aString.
		[contents := stream contents] ensure: [stream close].
		^contents].

	fileClass := Dialect isVisualAge 
				ifTrue: [self smalltalkAt: #CfsReadFileStream]
				ifFalse: 
					[Dialect isDolphin ifTrue: [self smalltalkAt: #File] ifFalse: [self halt]].
	stream := fileClass read: aString.
	[contents := stream contents] ensure: [stream close].
	^contents
]

{ #category : #strings }
Dialect class >> convert: aString toByteArrayWithEncoding: encodingName [
	self isVisualWorks ifTrue: [^aString asByteArrayEncoding: encodingName].
	self error: 'Not yet implemented'.
]

{ #category : #strings }
Dialect class >> convert: aByteArray toStringWithEncoding: encodingName [
	self isVisualWorks ifTrue: [^aByteArray asStringEncoding: encodingName].
	self error: 'Not yet implemented'.
]

{ #category : #private }
Dialect class >> determineDialect [
	^ dialectName := #Pharo
]

{ #category : #identifying }
Dialect class >> dialectName [

	dialectName isNil ifTrue: [self determineDialect.].
	^ dialectName
]

{ #category : #identifying }
Dialect class >> isPharo [

	^ self dialectName = #Pharo
]

{ #category : #collections }
Dialect class >> needsCollectionMementoFor: aCollection [
	^true.
]

{ #category : #reflection }
Dialect class >> selectorsFor: aClass do: aBlock [
	"Stupid dialects"
	self isVisualWorks ifTrue: [^aClass selectorsAndMethodsDo: [:key :value | aBlock value: key]].
	self isVisualAge ifTrue: [^ aClass methodDictionary keysDo: aBlock].
	self isSqueak ifTrue: [^aClass methodDict keysDo: aBlock].
	self isPharo ifTrue: [^aClass methodDict keysDo: aBlock].
	self error: 'Not yet implemented'.
]

{ #category : #'VisualWorks metadata' }
Dialect class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]
