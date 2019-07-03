"
This tests the ability to do a union operation on queries, returning results corresponding to multiple different queries.
"
Class {
	#name : #GlorpQueryUnionTest,
	#superclass : #GlorpSessionBasedTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpQueryUnionTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #support }
GlorpQueryUnionTest >> setUp [
	super setUp.
	session beginTransaction.
	self writeAddressOrderingRows.
]

{ #category : #support }
GlorpQueryUnionTest >> tearDown [
	session rollbackTransaction.
	super tearDown.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testBasicExcept [
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	query2 := Query read: GlorpAddress where: [:each | each id = 2].	
	union := query1 except: query2.
	result := session execute: union.
	self assert: result size = 1.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testBasicExcept2 [
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: [:each | each id in: #(1 2)].	
	query2 := Query read: GlorpAddress where: [:each | each id = 1].
	union := query1 except: query2.
	result := session execute: union.
	self assert: result size = 1.
	self assert: result first id = 2.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testBasicExcept3 [
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	query2 := Query read: GlorpAddress where: [:each | each street = 'Alpha'].	
	union := query1 except: query2.
	result := session execute: union.
	self assert: result size = 0.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testBasicIntersect [
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	query2 := Query read: GlorpAddress where: [:each | each id = 2].	
	union := query1 intersect: query2.
	result := session execute: union.
	self assert: result size = 0.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testBasicIntersect2 [
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	query2 := Query read: GlorpAddress where: [:each | each id in: #(1 2)].	
	union := query1 intersect: query2.
	result := session execute: union.
	self assert: result size = 1.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testBasicIntersect3 [
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	query2 := Query read: GlorpAddress where: [:each | each street = 'Alpha'].	
	union := query1 intersect: query2.
	result := session execute: union.
	self assert: result size = 1.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testBasicUnion [
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	query2 := Query read: GlorpAddress where: [:each | each id = 2].	
	union := query1 unionAll: query2.
	result := session execute: union.
	self assert: result size = 2.
	self assert: result first id = 1.
	self assert: result last id = 2.
	self assert: (result allSatisfy: [:each | each class == GlorpAddress]).
]

{ #category : #'tests-unit' }
GlorpQueryUnionTest >> testCompoundCommandCreate [
	| query1 union command |
	query1 := Query read: GlorpAddress.
	union := query1 unionAll: query1.
	union session: session.
	command := union sqlWith: #().
	self assert: command class == CompoundSelectCommand.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testCompoundWithSingleQuery [
	"Test that the coding of CompoundQuery is robust to the trivial case of there only being a single query.  We deliberately do not set the operation, thus verifying that a single query nowhere consults it.  This test demonstrates that both 'requiresDistinct' and 'readsOneObject' are initialized on the assumption there will be multiple queries."

	| union result |
	self writePeople.
	union := CompoundQuery new addQuery:
		(Query readOneOf: GlorpAddress where: [:each | each id = 2]).
	union requiresDistinct: false.	"only one query, so we cannot need to read distinct"
	union readsOneObject:		"only one query, so we could need to just one object"
		union queries first readsOneObject.
	result := session execute: union.
	self assert: result class == GlorpAddress.
	self assert: result street = 'Beta'.
	self assert: result number = '200'
]

{ #category : #'tests-unit' }
GlorpQueryUnionTest >> testCreateCompoundQuery [
	| query1 union |
	query1 := Query read: GlorpAddress.
	union := query1 unionAll: query1.
	self assert: union class == CompoundQuery.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testOrderByInAlsoFetchUnion [
	"On Oracle, SQLServer and MySQL, a compound query with same-name fields (from different tables, of course) will raise a duplicate/ambiguous error.  Glorp aliases the fields to avoid this."

	| query1 query2 union result |
	self writePeople.
	query1 := Query read: GlorpPerson where: [:each | each id = 86].
	query2 := Query read: GlorpPerson where: [:each | each id = 87].
	query1 alsoFetch: [:each | each address].
	query2 alsoFetch: [:each | each address].
	union := query1 unionAll: query2.
	union orderBy: [:each | each name].
	union orderBy: [:each | each address number].
	result := session execute: union.
	self assert: result first id = 86.
	self assert: result last id = 87.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testOrderByInUnion [
	| query1 query2 union result |
	self writePeople.
	query1 := Query read: GlorpAddress where: [:each | each id > 1].
	query1 retrieve: #id.
	query2 := Query read: GlorpPerson.
	query2 retrieve: [:each | each id].
	union := query1 unionAll: query2.
	union orderBy: [:each | each id descending].
	result := session execute: union.
	self assert: result = #(87 86 3 2).
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testOrderBySameNameFieldsInAlsoFetchUnion [
	| query1 query2 union result |
	self writePeople.
	query1 := Query read: GlorpPerson where: [:each | each id = 86].
	query2 := Query read: GlorpPerson where: [:each | each id = 87].
	query1 alsoFetch: [:each | each address].
	query2 alsoFetch: [:each | each address].
	union := query1 unionAll: query2.
	union orderBy: [:each | each id].
	union orderBy: [:each | each address id alias: 'AddressTableID'].
	result := session execute: union.
	self assert: result first id = 86.
	self assert: result last id = 87.
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testRetrieveFixedValue [
	| query1 query2 union result |
	self writePeople.
	query1 := Query read: GlorpPerson where: [:each | each id = 86].
	query1 retrieve: #id.
	query1 retrieve: [:each | each getConstant: 0 alias: #hasPaid].
	query2 := Query read: GlorpPerson where: [:each | each id = 87].
	query2 retrieve: #id.
	query2 retrieve: [:each | each getConstant: 1 alias: #hasPaid].
	union := query1 unionAll: query2.
	union orderBy: [:each | each id descending].
	result := session execute: union.
	self assert: result = #(#(87 1) #(86 0)).
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testThreeWayUnion [
	| query1 query2 union result query3 |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	query2 := Query read: GlorpAddress where: [:each | each id = 2].	
	query3 := Query read: GlorpAddress where: [:each | each id = 3].	

	union := (query1 unionAll: query2) unionAll: query3.
	union orderBy: [:each | each id].
	result := session execute: union.
	self assert: result size = 3.
	self assert: result first id = 1.
	self assert: result last id = 3.
	self assert: (result allSatisfy: [:each | each class == GlorpAddress]).
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testThreeWayUnionNested [
	"If we send #unionAll: to a CompoundQuery that is already a union, we create an unnested CompoundQuery for efficiency.  If we send it in reverse order, we do not check, so create a union within a union.  The same SQL code is generated but the bracketting differs:
	(...) UNION ALL ((...) UNION ALL (...))
in the nested query, compared to
	(...) UNION ALL (...) UNION ALL (...)
in the flattened query."

	| query1 query2 union result query3 |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	query2 := Query read: GlorpAddress where: [:each | each id = 2].	
	query3 := Query read: GlorpAddress where: [:each | each id = 3].	

	union := query3 unionAll: (query1 unionAll: query2).
	union orderBy: [:each | each id].
	result := session execute: union.
	self assert: result size = 3.
	self assert: result first id = 1.
	self assert: result last id = 3.
	self assert: (result allSatisfy: [:each | each class == GlorpAddress]).
]

{ #category : #'tests-unit' }
GlorpQueryUnionTest >> testUnionSQL [
	"Use expandMacros to avoid platform-specific line-end conventions blocking string matching."

	| query1 union command |
	query1 := Query read: GlorpAddress where: [:each | each id = 1].
	union := query1 unionAll: query1.
	union session: session.
	command := union sqlWith: #().
	self assert: ('SELECT * FROM (*SELECT *<n> FROM GR_ADDRESS t1<n> WHERE *t1.ID = * UNION ALL *SELECT *<n> FROM GR_ADDRESS t1<n> WHERE *t1.ID = *' expandMacros withUnixLineEndings match: command sqlString withUnixLineEndings).
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testUnionWithEmpty [
	| query1 query2 union result |
	query1 := Query read: GlorpAddress where: false.
	query2 := Query read: GlorpAddress where: [:each | each id = 2].	
	union := query1 unionAll: query2.
	result := session execute: union.
	self assert: result size = 1.
	self assert: result first id = 2.
	self assert: (result allSatisfy: [:each | each class == GlorpAddress]).
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testUnionWithParameters [
	| query1 query2 union result field1 dict |
	field1 := (system tableNamed: 'GR_ADDRESS') fieldNamed: 'ID'.
	query1 := Query read: GlorpAddress where: [:each | each id = (each parameter: field1)].
	query2 := Query read: GlorpAddress where: [:each | each id = ((each parameter: field1) + 1)].	
	union := query1 unionAll: query2.
	union orderBy: [:each | each id].
	dict := Dictionary new at: field1 put: 2; yourself.
	result := union executeWithParameters: dict in: session.
	self assert: result size = 2.
	self assert: result first id = 2.
	self assert: result last id = 3.
	self assert: (result allSatisfy: [:each | each class == GlorpAddress]).
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testUnionWithRetrieveDisaparateResults [
	| query1 query2 union result |
	self writePeople.
	query1 := Query read: GlorpAddress.
	query1 retrieve: #id.
	query2 := Query read: GlorpPerson.
	query2 retrieve: #id.
	union := query1 unionAll: query2.
	result := session execute: union.
	self assert: result asSortedCollection asArray = #(1 2 3 86 87).
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testUnionWithRetrieveThoroughlyDisaparateResults [
	"Fields from mismatched tables"
	| query1 query2 union result |
	self writePeople.
	query1 := Query read: GlorpAddress.
	query1 retrieve: [:each | each street].
	query2 := Query read: GlorpPerson.
	query2 retrieve: [:each | each name].
	union := query1 unionAll: query2.
	result := session execute: union.
	self assert: result asSortedCollection asArray = #('Alpha' 'Beta' 'Gamma' 'person1' 'person2').
]

{ #category : #'tests-functional' }
GlorpQueryUnionTest >> testUnionWithRetrieveThoroughlyDisaparateResults2 [
	"The tables will get aliased differently, make sure that works"

	| query1 query2 union result |
	self writePeople.
	query1 := Query read: GlorpAddress where: [:each | each id = 2].
	query1 retrieve: [:each | each street].
	query2 := Query read: GlorpPerson where: [:each | each id = 87].
	query2 retrieve: [:each | each address street].
	union := query1 unionAll: query2.
	result := session execute: union.
	self assert: result asSortedCollection asArray = #('Beta' 'Gamma').
]

{ #category : #support }
GlorpQueryUnionTest >> writeAddressOrderingRows [

	session writeRow: session system exampleAddressRowForOrdering1.
	session writeRow: session system exampleAddressRowForOrdering2.
	session writeRow: session system exampleAddressRowForOrdering3.
]

{ #category : #support }
GlorpQueryUnionTest >> writePeople [

	session writeRow: session system examplePersonRowForOrdering1.
	session writeRow: session system examplePersonRowForOrdering2.
]
