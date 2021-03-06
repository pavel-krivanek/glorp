mapping
parametersIn: anElementBuilder
	| parameters |
	self shouldUseFilteredRead ifTrue: [^anElementBuilder command parameters].
	parameters := IdentityDictionary new.
	self conditional casesDo: [:each |
		each join mappableSourceFieldsDo:
			[:eachSource | parameters at: eachSource put: (anElementBuilder valueOfField: eachSource)]].
	^parameters