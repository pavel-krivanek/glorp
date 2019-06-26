"
A command to delete our set of rows.
"
Class {
	#name : #DeleteCommand,
	#superclass : #RowBasedCommand,
	#category : #'GlorpDatabase-GlorpCore'
}

{ #category : #'VisualWorks metadata' }
DeleteCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
DeleteCommand >> arrayBoundFields [
	"For a delete, it makes no difference, we only ever include the primary key fields"
	^self singleRowBoundFields.
]

{ #category : #'bound values' }
DeleteCommand >> bindingTypes [
	"This was pushed down from the superclass when refactoring changed that for the other command subclasses.  In the simplest case, we need only write and only bind the primaryKey fields to delete, but review this command and QueryDeleteCommand before attempting any simplifications here."

	| all basic size |
	^self shouldUseGroupWriting
		ifTrue:
			[basic := self row nonGeneratedFields collect: [:each | each type].
			size := basic size.
			all := Array new: (allRows size * size).
			0 to: allRows size - 1 do:
				[:i || index | index := i * size.
				all replaceElementsFrom: index + 1 to: index + size withArray: basic startingAt: 1].
			all]
		ifFalse: [self singleRowBoundFields collect: [:each | each type]]
]

{ #category : #accessing }
DeleteCommand >> blockFactor [
	^1.
]

{ #category : #executing }
DeleteCommand >> printSQL [
	self nextPutAll: 'DELETE FROM '.
	row table printSQLOn: self withParameters: #().
	self nextPutAll: ' WHERE '.
	row printPrimaryKeyTemplateOn: self.
]

{ #category : #accessing }
DeleteCommand >> singleRowBoundFields [
	| fields |
	fields := row table primaryKeyFields.
	fields isEmpty ifTrue: [fields := row fields].
	^fields asArray
]
