Class {
	#name : #GlorpTreeNode,
	#superclass : #Object,
	#instVars : [
		'id',
		'children',
		'parent'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'instance creation' }
GlorpTreeNode class >> new [
	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
GlorpTreeNode class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #adding }
GlorpTreeNode >> addChild: aGlorpTreeNode [
	aGlorpTreeNode parent: self.
	self children add: aGlorpTreeNode.
]

{ #category : #accessing }
GlorpTreeNode >> children [
	^children
]

{ #category : #accessing }
GlorpTreeNode >> children: aCollection [
	children := aCollection.
]

{ #category : #accessing }
GlorpTreeNode >> id [
	^id
]

{ #category : #accessing }
GlorpTreeNode >> id: anInteger [
	id := anInteger.
]

{ #category : #'initialize-release' }
GlorpTreeNode >> initialize [
	children := OrderedCollection new.
]

{ #category : #accessing }
GlorpTreeNode >> parent [
	^parent
]

{ #category : #accessing }
GlorpTreeNode >> parent: aGlorpTreeNode [
	parent := aGlorpTreeNode.
]

{ #category : #printing }
GlorpTreeNode >> printOn: aStream [
	aStream nextPutAll: 'Node('.
	id printOn: aStream.
	aStream nextPut: $).
]
