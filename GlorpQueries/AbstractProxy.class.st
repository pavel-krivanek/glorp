"
testThis is an abstract superclass for proxy objects. It inherits from ProtoObject, which is part of the platform specific layer, but implements most of the proxy functionality.

Instance Variables:
	isInstantiated	<Boolean>	Has this proxy been instantiated or not.
	value	<Object>	What we are proxying for.
"
Class {
	#name : #AbstractProxy,
	#superclass : #ProtoObject,
	#instVars : [
		'value',
		'isInstantiated'
	],
	#category : #'GlorpQueries-Glorp'
}

{ #category : #'instance creation' }
AbstractProxy class >> new [

	^super new proxyInitialize.
]

{ #category : #'VisualWorks metadata' }
AbstractProxy class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
AbstractProxy >> = anObject [
	"In VA we inherit this as identity. Need to override"
	^anObject = self getValue.
]

{ #category : #printing }
AbstractProxy >> basicPrintOn: aStream [ 
	aStream nextPut: ${.
	isInstantiated 
		ifTrue: [self getValue basicPrintOn: aStream]
		ifFalse: [aStream nextPutAll: 'uninstantiated proxy'].
	aStream nextPut: $}
]

{ #category : #printing }
AbstractProxy >> basicPrintString [
	| aStream |
	aStream := WriteStream on: String new.
	self basicPrintOn: aStream.
	^aStream contents
]

{ #category : #overrides }
AbstractProxy >> basicSize [
	^self getValue basicSize.
]

{ #category : #'dnu handling' }
AbstractProxy >> doesNotUnderstand: sel args: args [ 
	"This is the variant for ObjectStudio"
	^self getValue perform: sel withArguments: args
]

{ #category : #api }
AbstractProxy >> getValue [

	self subclassesMustImplement
]

{ #category : #notification }
AbstractProxy >> glorpPostFetch: aSession [
]

{ #category : #notification }
AbstractProxy >> glorpPostFetchValidate: aSession [
]

{ #category : #overrides }
AbstractProxy >> hash [
	^self getValue hash.
]

{ #category : #overrides }
AbstractProxy >> inspect [
	^self getValue inspect.
]

{ #category : #testing }
AbstractProxy >> isGlorpProxy [
	^true.
]

{ #category : #overrides }
AbstractProxy >> isImmutable [
	^self getValue isImmutable.
]

{ #category : #testing }
AbstractProxy >> isInstantiated [
	isInstantiated isNil ifTrue: [isInstantiated := false].
	^isInstantiated
]

{ #category : #accessing }
AbstractProxy >> isKindOf: aClass [
	self isInstantiated ifTrue: [^value isKindOf: aClass].
	^false
]

{ #category : #printing }
AbstractProxy >> printOn: aStream [ 
	aStream nextPut: ${.
	isInstantiated 
		ifTrue: [self getValue printOn: aStream]
		ifFalse: [aStream nextPutAll: 'uninstantiated proxy'].
	aStream nextPut: $}
]

{ #category : #printing }
AbstractProxy >> printString [

	| aStream |
	aStream := WriteStream on: (String new: 16).
	self printOn: aStream.
	^aStream contents
]

{ #category : #initialize }
AbstractProxy >> proxyInitialize [

	isInstantiated := false.
]

{ #category : #overrides }
AbstractProxy >> store [
	"For Object Studio compatibility"
	^self inspectorString.
]

{ #category : #accessing }
AbstractProxy >> uninstantiate [

	value := nil.
	isInstantiated := false.
]

{ #category : #accessing }
AbstractProxy >> ~= anObject [ 

	^(self = anObject) not
]
