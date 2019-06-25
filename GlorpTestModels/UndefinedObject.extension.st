Extension { #name : #UndefinedObject }

{ #category : #'*GlorpTestModels-glorp' }
UndefinedObject >> assertEqual: anObject [
	GlorpTestModelClass new assert: anObject = nil.
]
