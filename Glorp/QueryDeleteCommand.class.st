"
This represent a query that does a delete with a where clause

Instance Variables
	query	<SimpleQuery>	The query that holds our where clause.


"
Class {
	#name : #QueryDeleteCommand,
	#superclass : #SelectCommand,
	#instVars : [
		'query',
		'rowCount'
	],
	#category : #'Glorp-Database'
}

{ #category : #accessing }
QueryDeleteCommand >> bindingTypes [
	^#().
]

{ #category : #accessing }
QueryDeleteCommand >> bindings [
	^#().
]

{ #category : #executing }
QueryDeleteCommand >> executeUnboundIn: anAccessor [
	"We leave the rowCount nil if the platform does not support it, to make clear it's not a valid value."

	anAccessor returnRowCount: true.
	anAccessor
		executeSQLStringNoResult: self sqlString
		doing: [(anAccessor platform supportsRowCountFor: self)
				ifTrue: [self rowCount: anAccessor rowCount]]
		forCommand: self.
	^#() readStream
]

{ #category : #accessing }
QueryDeleteCommand >> expectedNumberOfModifiedRows [
	"For polymorphism with DeleteCommand;  return the same guestimated number as expectedRows in a standard Select command."

	^100
]

{ #category : #testing }
QueryDeleteCommand >> isDeleteCommand [

	^true
]

{ #category : #testing }
QueryDeleteCommand >> needsRowCount [
	"Because I override #useBinding to return false, and #executeUnboundIn: to handle rowCount, this is never called.  It is left here to show up if searching for commands that get rowCount, and in case I ever allow binding.  I need rowCount solely to return it to callers of #delete:where: (at the moment, no known callers use this)."

	^true
]

{ #category : #accessing }
QueryDeleteCommand >> printSQL [
	stream nextPutAll: 'DELETE '.
	query printUnqualifiedTablesOn: self.
	query printUnqualifiedWhereClauseOn: self.
]

{ #category : #accessing }
QueryDeleteCommand >> query [

	^query
]

{ #category : #accessing }
QueryDeleteCommand >> query: aSimpleQuery [
	query := aSimpleQuery
]

{ #category : #accessing }
QueryDeleteCommand >> rowCount [

	^rowCount
]

{ #category : #accessing }
QueryDeleteCommand >> rowCount: anInteger [

	rowCount := anInteger
]

{ #category : #reporting }
QueryDeleteCommand >> tables [
	^(self query tablesToPrint collect: [:each | each parent]) asSet.
]

{ #category : #accessing }
QueryDeleteCommand >> useBinding [
	"For simplicity, we don't use binding.  If we did, we would need to compute #bindings and #bindingTypes - doable but, for the moment, we pass."

	^false
]
