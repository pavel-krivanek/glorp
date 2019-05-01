Extension { #name : #UndefinedObject }

{ #category : #'*GlorpExtensions' }
UndefinedObject >> glorpPrintSQLOn: aCommand [

	aCommand nextPutAll: 'NULL'.
]
