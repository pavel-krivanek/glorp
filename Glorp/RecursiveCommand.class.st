"
I print the SQL to define and populate a recursive common table expression, before using my superclass' behaviour to select the rows to be returned by my RecursiveQuery.
"
Class {
	#name : #RecursiveCommand,
	#superclass : #QuerySelectCommand,
	#category : #'Glorp-Core'
}

{ #category : #executing }
RecursiveCommand >> printSQL [
	| recursionTable |
	self space; nextPutAll: self platform withRecursive; space.
	recursionTable := self query unionQuery queries last baseExpression descriptor table.
	self nextPutAll: recursionTable name.
	self nextPut: $(.
	GlorpHelper
		do: [:each | self nextPutAll: each name]
		for: recursionTable fields
		separatedBy: [self nextPut: $,; space].
	self nextPut: $).
	self nextPutAll: ' AS '.
	self cr; nextPut: $(.
	self nextPutAll: (self query unionQuery sqlWith: parameters) sqlString.
	self nextPut: $); cr.
	super printSQL.
]
