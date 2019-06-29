"
This is a select command that uses a number of sub-commands to print multiple queries, and combine them into one for execution. Used in conjunction with compound queries, e.g. using UNION ALL. The query knows what the combination operation is.

Instance Variables:
	commands	<(Collection of: DatabaseCommand)>	The commands we are to print.
"
Class {
	#name : #CompoundSelectCommand,
	#superclass : #QuerySelectCommand,
	#instVars : [
		'commands'
	],
	#category : #GlorpCore
}

{ #category : #'VisualWorks metadata' }
CompoundSelectCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
CompoundSelectCommand >> commands [
	commands isNil ifTrue: [commands := query queries collect: [:each | each sqlWith: parameters]].
	^commands.
]

{ #category : #testing }
CompoundSelectCommand >> hasGrouping [
	^self query hasGrouping
]

{ #category : #testing }
CompoundSelectCommand >> hasOrdering [

	^self query hasOrdering
]

{ #category : #accessing }
CompoundSelectCommand >> parameters: aDictionary [
	parameters := aDictionary.
	commands := nil.
]

{ #category : #executing }
CompoundSelectCommand >> printSQL [
	"Access doesn't like parentheses around the first in a group of compound commands.  A CompoundQuery can have a single command (usually only arises with recursive queries), which likewise allows (though it does not require) dropping the outer parentheses."

	| skipFirst printParentheses |
	self requiresWrapperQuery
		ifTrue: [
			self nextPutAll: 'SELECT '.
			self requiresDistinct
				ifTrue:  [ self nextPutAll: 'DISTINCT '].
			self nextPutAll: '* FROM '.
			self platform supportsAliasInCompoundQuery ifTrue: [self nextPut: $( ]].
	skipFirst := self commands size < 2 or: [self platform parenthesizeAllButFirstCommandInCompoundQuery].
	printParentheses := self platform parenthesizeCommandsInCompoundQuery: query.
	self findBoundExpressions.
	GlorpHelper
		do:
			[:each |
			each boundExpressions: self boundExpressions.
			(printParentheses and: [skipFirst not])
				ifTrue: [self nextPut: $(].
			self nextPutAll: each sqlString.
			(printParentheses and: [skipFirst not])
				ifTrue: [self nextPut: $)].
			skipFirst := false]
		for: self commands
		separatedBy: [query printOperationOn: self].
	(self requiresWrapperQuery and: [self platform supportsAliasInCompoundQuery])
		ifFalse:
			[query printOrderingOn: self.
			query printGroupingOn: self]
		ifTrue: 
			[self nextPut: $).
			query printCompoundSelectAliasesOn: self].
]

{ #category : #testing }
CompoundSelectCommand >> requiresDistinct [
	^self query requiresDistinct.
]

{ #category : #testing }
CompoundSelectCommand >> requiresWrapperQuery [
	^self requiresDistinct
		or: [self hasOrdering
			or: [self hasGrouping]]
]
