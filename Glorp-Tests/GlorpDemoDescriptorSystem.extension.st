Extension { #name : #GlorpDemoDescriptorSystem }

{ #category : #'*Glorp-Tests' }
GlorpDemoDescriptorSystem >> testIDLessThan5: aValue [
	"A test method, used for conditional mapping tests"
	^aValue < 5.
]

{ #category : #'*Glorp-Tests' }
GlorpDemoDescriptorSystem >> testIDMoreThan5: aValue [
	"A test method, used for conditional mapping tests"
	^aValue > 5.
]
