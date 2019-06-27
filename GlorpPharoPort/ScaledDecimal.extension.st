Extension { #name : #ScaledDecimal }

{ #category : #'*GlorpPharoPort' }
ScaledDecimal >> glorpPrintSQLOn: aStream [ 

	self printOn: aStream showingDecimalPlaces: scale
]
