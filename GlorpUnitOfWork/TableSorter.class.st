"
This implements a topological sort for tables, based on the foreign key constraints between them.

Instance Variables:
	orderedTables	<Collection of: DatabaseTable>	The resulting tables in sorted order.
	tables	<(Collection of: (DatabaseTable))>	The input tables.
	visitedTables	<IdentitySet of: DatabaseTable>	The tables we have already visited during the sort.


"
Class {
	#name : #TableSorter,
	#superclass : #Object,
	#instVars : [
		'orderedTables',
		'tables',
		'visitedTables'
	],
	#category : #'GlorpUnitOfWork-Glorp'
}

{ #category : #'instance creation' }
TableSorter class >> for: tables [

	| sorter |
	sorter := self new.
	tables do: [:each |
		sorter addTable: each].
	^sorter.
]

{ #category : #'instance creation' }
TableSorter class >> new [

	^super new initialize.
]

{ #category : #'VisualWorks metadata' }
TableSorter class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
TableSorter >> addTable: aTable [ 
	tables add: aTable
]

{ #category : #accessing }
TableSorter >> hasBeenVisited: aTable [

	^visitedTables includes: aTable.
]

{ #category : #initializing }
TableSorter >> initialize [
	tables := OrderedCollection new: 100.
	visitedTables := IdentitySet new: 100.
]

{ #category : #accessing }
TableSorter >> markVisited: aTable [

	visitedTables add: aTable.
]

{ #category : #sorting }
TableSorter >> sort [
	orderedTables := OrderedCollection new: tables size.
	tables do: [:each | self visit: each].
	^orderedTables select: [:each | tables includes: each].
]

{ #category : #sorting }
TableSorter >> visit: aTable [ 
	"The essential bit of topological sort. Visit each node in post-order, traversing dependencies, based on foreign key constraints to database-generated fields. "

	(self hasBeenVisited: aTable) ifTrue: [^self].
	self markVisited: aTable.
	self visitDependentTablesFor: aTable.
	orderedTables add: aTable
]

{ #category : #sorting }
TableSorter >> visitDependentTablesFor: aTable [
	"If the foreign key is also in the database (the default), getting this write-order right may be essential to having the database accept it.  If not, but one of a table's fields (key or otherwise) is also an IdentityColumn (i.e. post-write-assigned) primary key of another table, then a Glorp-only foreign key may be of use in getting the post-write-assigned value for the other row before it is written."

	aTable foreignKeyConstraints do:
		[:eachConstraint |
		self visit: eachConstraint targetTable].
]
