"
I print the SQL to define and populate a recursive common table expression, before using my superclass' behaviour to select the rows to be returned by my RecursiveQuery.

Instance Variables:
	recursiveUnionCommand	<CompoundSelectCommand>	The union command that defines the recursion we are to print.
"
Class {
	#name : #RecursiveCommand,
	#superclass : #CompoundSelectCommand,
	#instVars : [
		'recursiveUnionCommand'
	],
	#category : #GlorpCore
}

{ #category : #'VisualWorks metadata' }
RecursiveCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
RecursiveCommand >> printSQL [
	| recursionTable |
	self nextPutAll: self platform withRecursive; space.
	self platform isSQLite3Platform ifTrue:	"SQLite unions can only have limits at the end"
		[self query unionQuery queries first limit: nil].
	recursionTable := self query unionQuery queries last baseExpression descriptor table.
	self nextPutAll: recursionTable name.
	self nextPut: $(.
	GlorpHelper
		do: [:each | self nextPutAll: each name]
		for: recursionTable fields
		separatedBy: [self nextPut: $,; space].
	self nextPut: $).
	self nextPutAll: ' AS '.
	self query ensureRecursionTableToPrint.
	"We find boundExpressions earlier so as to have them before the recursive union prints."
	self findBoundExpressions.
	self recursiveUnionCommand boundExpressions: self boundExpressions.
	self cr; nextPut: $(.
	self nextPutAll: self recursiveUnionCommand sqlString.
	self nextPut: $); cr.
	super printSQL.
]

{ #category : #accessing }
RecursiveCommand >> recursiveUnionCommand [
	recursiveUnionCommand isNil ifTrue: [recursiveUnionCommand := query unionQuery sqlWith: parameters].
	^recursiveUnionCommand
]
