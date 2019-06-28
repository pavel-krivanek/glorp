"
I use blocks to get and/or set values from/on my object.  (If either block is nil, I use my superclass behaviour, i.e. direct instvar access or #perform:{with:}) for that case.)

Instance Variables:
	getValueBlock	<BlockClosure | nil>	the block I use to get the value from the object
	setValueBlock	<BlockClosure | nil>	the block I use to set the value on the object

To make an attribute be of my class, send #beBlockAccess after defining the attribute in #classModelFor<DomainClass>: or send #getValueBlock: or #setValueBlock: to a Mapping using that attribute (BE AWARE: if any other mapping already also uses the same attribute, re-send #attributeName: <theAttributeNameSymbol> to update it to hold the new instance).
"
Class {
	#name : #GlorpBlockModel,
	#superclass : #GlorpAttributeModel,
	#instVars : [
		'getValueBlock',
		'setValueBlock'
	],
	#category : #GlorpMappings
}

{ #category : #'VisualWorks metadata' }
GlorpBlockModel class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #copying }
GlorpBlockModel >> copyFrom: anAttributeModel [
	anAttributeModel isNil ifTrue: [^self].
	super copyFrom: anAttributeModel.
	(anAttributeModel class includesBehavior: self class) ifFalse: [^self].
	getValueBlock := anAttributeModel getValueBlock.
	setValueBlock := anAttributeModel setValueBlock.
]

{ #category : #accessing }
GlorpBlockModel >> getValueBlock [
	^getValueBlock
]

{ #category : #accessing }
GlorpBlockModel >> getValueBlock: aOneArgBlock [
	getValueBlock := aOneArgBlock.
]

{ #category : #'get/set' }
GlorpBlockModel >> getValueFrom: anObject [
	^getValueBlock isNil
		ifTrue: [super getValueFrom: anObject]
		ifFalse: [getValueBlock value: anObject]
]

{ #category : #accessing }
GlorpBlockModel >> setValueBlock [
	^setValueBlock
]

{ #category : #accessing }
GlorpBlockModel >> setValueBlock: aTwoArgBlock [
	setValueBlock := aTwoArgBlock.
]

{ #category : #'get/set' }
GlorpBlockModel >> setValueIn: anObject to: aValue [
	^setValueBlock isNil
		ifTrue: [super setValueIn: anObject to: aValue]
		ifFalse: [setValueBlock value: anObject value: aValue]
]

{ #category : #validation }
GlorpBlockModel >> validateCanRead [
	"If we have a block, we have no practical way of knowing whether it does what the user wants or not, so we cannot validate."

	setValueBlock isNil ifTrue: [super validateCanRead].
]

{ #category : #validation }
GlorpBlockModel >> validateCanWrite [
	"If we have a block, we have no practical way of knowing whether it does what the user wants or not, so we cannot validate."

	getValueBlock isNil ifTrue: [super validateCanWrite].
]
