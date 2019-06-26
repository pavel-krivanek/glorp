Extension { #name : #GlorpDemoDescriptorSystem }

{ #category : #'*GlorpTests-test support' }
GlorpDemoDescriptorSystem >> testIDLessThan5: aValue [
	"A test method, used for conditional mapping tests"
	^aValue < 5.
]

{ #category : #'*GlorpTests-test support' }
GlorpDemoDescriptorSystem >> testIDMoreThan5: aValue [
	"A test method, used for conditional mapping tests"
	^aValue > 5.
]
