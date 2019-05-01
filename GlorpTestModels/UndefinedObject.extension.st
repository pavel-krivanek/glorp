Extension { #name : #UndefinedObject }

{ #category : #'*GlorpTestModels' }
UndefinedObject >> assertEqual: anObject [
	GlorpTestModelClass new assert: anObject = nil.
]
