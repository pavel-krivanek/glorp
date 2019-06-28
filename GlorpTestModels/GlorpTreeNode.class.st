"
I model a parent-child relationships to test them in orderinary SQL and in recursive SQL.

Instance Variables:
	children	<Collection>	child tree nodes
	id	<Integer>	unique id for tree node
	parent	<GlorpTreeNode>	parent tree node

"
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

{ #category : #adding }
GlorpTreeNode >> childrenRecursively: aTreeNode [
	"The parameter is a tree node within the tree of the getter.  If my parent has also been fetched, put me in my parent;  otherwise do nothing (all the nodes will be in the cache but their links were not fetched).
	This example needs work.  The RecursionMapping's attribute should be used more.  We should also consult the #children mapping since it could have ordering or other features to respect when adding."

	(aTreeNode parent isGlorpProxy and: [aTreeNode parent isInstantiated not]) ifTrue: [^self].
	"The next two lines mostly duplicate each other, but the ancestor node's parent will be a proxy (on nil) so we need both."
	(aTreeNode children isGlorpProxy and: [aTreeNode children isInstantiated not]) ifTrue:
		[aTreeNode children: OrderedCollection new].
	(aTreeNode parent children isGlorpProxy and: [aTreeNode parent children isInstantiated not]) ifTrue:
		[aTreeNode parent children: OrderedCollection new].
	aTreeNode parent children add: self.
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
