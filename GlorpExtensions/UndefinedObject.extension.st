Extension { #name : #UndefinedObject }

{ #category : #'*GlorpExtensions-printing' }
UndefinedObject >> glorpPrintSQLOn: aCommand [

	aCommand nextPutAll: 'NULL'.
]
