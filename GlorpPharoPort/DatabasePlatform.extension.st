Extension { #name : #DatabasePlatform }

{ #category : #'*GlorpPharoPort' }
DatabasePlatform >> defaultPort [
	"self subclassResponsibility.
	for this instance i'll return 5432, but all platforms must be return you own port"
	^ '5432'.
]

{ #category : #'*GlorpPharoPort' }
DatabasePlatform >> supportsArithmeticOperatorsOnDates [
	"Answer whether arithmetic operators such as + or - can be used on DATE like columns.
	Some platforms require the use of specific functions."
	
	^true
]
