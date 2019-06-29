"
My sole purpose is to link to GlorpTreeNode, to investigate alsoFetching recursively.

Instance Variables:
	id	<Integer>	unique id for me, the root instance
	root	<GlorpTreeNode>	the root tree node held by me
"
Class {
	#name : #GlorpRootNode,
	#superclass : #Object,
	#instVars : [
		'id',
		'root'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpRootNode class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpRootNode >> id [
	^id
]

{ #category : #accessing }
GlorpRootNode >> id: anInteger [
	id := anInteger.
]

{ #category : #accessing }
GlorpRootNode >> root [
	^root
]

{ #category : #accessing }
GlorpRootNode >> root: aGlorpTreeNode [
	root := aGlorpTreeNode.
]
