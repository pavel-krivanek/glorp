"
This is an abstract superclass for proxy objects. It inherits from ProtoObject, which is part of the platform specific layer, but implements most of the proxy functionality.

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
AbstractProxy >> doesNotUnderstand: aMessage [

	^self getValue perform: aMessage selector withArguments: aMessage arguments.
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

{ #category : #accessing }
AbstractProxy >> glorpRealObject [
	"Return my value.  Ensure instantiation of a proxy:  use #glorpRealObjectIfNone: to avoid forced instantiation.  (On compilers which inline #yourself, that method will not force instantiation despite having the same Smalltalk implementation  as this method;  see also #yourSelf.)
	Functionally, this method need not be implemented here:  were it not, sending it would DNU and so do  'self getValue perform #glorpRealObject', getting Object's implementor.  This method skips that, speeding things trivially."

	^self getValue
]

{ #category : #accessing }
AbstractProxy >> glorpRealObjectIfNone: aBlock [
	"Return the real object but do NOT force instantiation of a proxy; instead, evaluate the block on the uninstantiated proxy, returning the result."

	^self isInstantiated
		ifTrue: [value]
		ifFalse: [aBlock value]
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
