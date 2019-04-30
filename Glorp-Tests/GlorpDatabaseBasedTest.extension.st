Extension { #name : #GlorpDatabaseBasedTest }

{ #category : #'*Glorp-Tests' }
GlorpDatabaseBasedTest >> assert: aBrackettedString equalsIgnoringOuterBrackets: anotherString [
	self assert: aBrackettedString =
		(anotherString first = $(
			ifTrue: [anotherString]
			ifFalse: ['(', anotherString, ')'])
]
