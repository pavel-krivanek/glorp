Extension { #name : #DatabasePlatform }

{ #category : #'*eoglorp' }
DatabasePlatform classSide >> createLoginFromConnectionDictionary: aDict [ 
	self subclassResponsibility
]

{ #category : #'*eoglorp' }
DatabasePlatform classSide >> loginWithConnectionDictionary: aDict [ 
	| platformClass |
	platformClass := self allSubclasses
		detect: [:cls | cls understandsConnectionDictionary: aDict].
	^platformClass isNil ifFalse:
		[platformClass createLoginFromConnectionDictionary: aDict]
]

{ #category : #'*eoglorp' }
DatabasePlatform classSide >> understandsConnectionDictionary: aDict [

	^false
]
