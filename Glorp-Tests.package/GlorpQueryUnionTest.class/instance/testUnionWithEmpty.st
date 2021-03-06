tests-functional
testUnionWithEmpty
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: false.
	query2 := Query read: GlorpAddress where: [:each | each id = 2].	
	union := query1 unionAll: query2.
	result := session execute: union.
	self assert: result size = 1.
	self assert: result first id = 2.
	self assert: (result allSatisfy: [:each | each class == GlorpAddress]).