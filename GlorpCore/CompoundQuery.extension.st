Extension { #name : #CompoundQuery }

{ #category : #'*GlorpCore' }
CompoundQuery >> sqlWith: aDictionary [

	self prepare.
	session platform queryWithUnsupportedOperationsEliminatedFrom: self do: [:newQuery | 
		^newQuery
			prepare;
			sqlWith: aDictionary].
	^CompoundSelectCommand
		forQuery: self
		parameters: aDictionary
		useBinding: session useBinding
		session: session
]
