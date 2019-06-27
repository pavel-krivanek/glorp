"
Test storing read data in common table expression and using it for recursive reads.
"
Class {
	#name : #GlorpRecursionTest,
	#superclass : #GlorpMappingDBTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpRecursionTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadAncestors [
	"In a single round trip to the database, get all 3 ancestors of node 9 by recursively reading them."

	| allNodes recursiveQuery |
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query readOneOf: GlorpTreeNode where: [:each | each id = 9])
				retrieveAll:
					(Array
						with: [:each | each id]
						with: [:each | each parent id])
				thenFollow: #parent 
				recursivelyRetrievingAll:
					(Array
						with: [:each | each recurse id]
						with: [:each | each recurse parent id])
				intersect: (Query read: GlorpTreeNode).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 3.
		self assert: (allNodes collect: [:each | each id]) asArray = #(4 2 1)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> testReadDescendants [
	"In a single round trip to the database, get all 8 descendants of node 1 by recursively reading them."

	| allNodes recursiveQuery |
	self inTransactionDo:
		[self writeNodeWithDescendants.
		session reset.
		recursiveQuery :=
			(Query read: GlorpTreeNode where: [:each | each id = 1])
				retrieveAll:
					(Array
						with: [:each | each id]
						with: [:each | each children id])
				thenFollow: #children 
				recursivelyRetrievingAll:
					(Array
						with: [:each | each recurse id]
						with: [:each | each recurse children id])
				intersect: (Query read: GlorpTreeNode).
		allNodes := session execute: recursiveQuery.
		self assert: allNodes size = 8.
		self assert: (allNodes collect: [:each | each id]) sort asArray = #(2 3 4 5 6 7 8 9)].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> writeNodeWithChildren [
	| node1 node2 node2a |
	node1 := GlorpTreeNode new id: 1.
	node2 :=GlorpTreeNode new id: 2.
	node2a := GlorpTreeNode new id: 3.
	node1 addChild: node2.
	node1 addChild: node2a.
	session inUnitOfWorkDo: [session register: node1].
]

{ #category : #'tests-nodes' }
GlorpRecursionTest >> writeNodeWithDescendants [
	| node1 node2a node2b node3aa node3ab node3ac node3ba node3bb node4aaa |
	node4aaa:= GlorpTreeNode new id: 9.
	node3bb := GlorpTreeNode new id: 8.
	node3ba := GlorpTreeNode new id: 7.
	node3ac :=GlorpTreeNode new id: 6.
	node3ab :=GlorpTreeNode new id: 5.
	(node3aa := GlorpTreeNode new id: 4)
		addChild: node4aaa.
	(node2b := GlorpTreeNode new id: 3)
		addChild: node3ba; addChild: node3bb.
	(node2a := GlorpTreeNode new id: 2)
		addChild: node3aa; addChild: node3ab; addChild: node3ac.
	(node1 := GlorpTreeNode new id: 1)
		addChild: node2a; addChild: node2b.
	session inUnitOfWorkDo: [session register: node1].
]
