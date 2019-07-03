Class {
	#name : #GlorpQueryTableAliasingTest,
	#superclass : #GlorpDatabaseBasedTest,
	#instVars : [
		'query',
		'expression',
		'elementBuilder',
		'session'
	],
	#category : #'GlorpTests-GlorpTest'
}

{ #category : #'VisualWorks metadata' }
GlorpQueryTableAliasingTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #utility }
GlorpQueryTableAliasingTest >> helpTestPrintingWhereClause: anExpression [
	| command |
	query 
		initResultClass: GlorpCustomer
		whereClause: expression
		singleObject: true.
	query setupTracing.
	query computeFields.
	command := GlorpNullCommand useBinding: false session: session.
	anExpression	
		printSQLOn: command
		withParameters: Dictionary new.
	^command sqlString.
]

{ #category : #support }
GlorpQueryTableAliasingTest >> setUp [
	super setUp.
	query := SimpleQuery new.
	expression := BaseExpression new.
	expression descriptor: (system descriptorFor: GlorpCustomer).
	(expression descriptor mappingForAttributeNamed: #name) shouldProxy: false.
	elementBuilder := ObjectBuilder for: expression in: query.
	expression assignTableAliasesStartingAt: Set new prefix: 't'.
	session := GlorpSession new.
	session system: system.
	query session: system session.
]

{ #category : #tests }
GlorpQueryTableAliasingTest >> testAliasWithEmbeddedMapping [

	self unfinished.
]

{ #category : #tests }
GlorpQueryTableAliasingTest >> testBuildingObject [
	"This is a non-database-connecting test, so we force all mappings that could require DB connection (or cache prepping) to proxy.  They all do by default anyway, but this makes the test robust to any test-run-configuration-induced changes."

	| customer |
	elementBuilder descriptor mappings do:
		[:each | each mapsSimpleObject ifFalse: [each shouldProxy: true]].
	elementBuilder instance: GlorpCustomer new.
	elementBuilder requiresPopulating: true.
	elementBuilder buildObjectFrom: #(12 'Name').
	customer := elementBuilder instance.
	self assert: customer class == GlorpCustomer.
	self assert: customer id = 12.
	self assert: customer name = 'Name'.
]

{ #category : #tests }
GlorpQueryTableAliasingTest >> testElementBuilderFields [
	elementBuilder fieldsForSelectStatement 
		do: [:each | self assert: each table name = 't1']
]

{ #category : #tests }
GlorpQueryTableAliasingTest >> testExpressionTableAlias [
	| fields |
	fields := expression translateFields: expression descriptor mappedFields.
	fields do: [:each | self assert: each table name = 't1']
]

{ #category : #tests }
GlorpQueryTableAliasingTest >> testQueryPrintingFields [
	| stream |
	query 
		initResultClass: GlorpCustomer
		whereClause: expression
		singleObject: true.
	query limit: nil.
	query setupTracing.
	query computeFields.
	stream := String new writeStream.
	query printSelectFieldsOn: stream.
	self assert: stream contents = 't1.ID, t1.NAME'
]

{ #category : #tests }
GlorpQueryTableAliasingTest >> testQueryPrintingSimpleWhereClause [
	| string |
	string := self helpTestPrintingWhereClause: ((expression get: #name) get: #= withArguments: #('Fred')).
	self assert: '(t1.NAME = ''Fred'')' equalsIgnoringOuterBrackets: string.
]

{ #category : #tests }
GlorpQueryTableAliasingTest >> testQueryPrintingTables [
	| stream string |
	query 
		initResultClass: GlorpCustomer
		whereClause: expression
		singleObject: true.
	query setupTracing.
	query computeFields.
	stream := String new writeStream.
	query printTablesOn: stream.
	string := stream contents.
	self assert: string withUnixLineEndings = '<n> FROM GR_CUSTOMER t1' expandMacros withUnixLineEndings.
]
