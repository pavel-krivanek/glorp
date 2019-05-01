Extension { #name : #ScaledDecimal }

{ #category : #'*GlorpExtensions' }
ScaledDecimal >> glorpPrintSQLOn: aStream [ 

	self printOn: aStream showingDecimalPlaces: scale
]
