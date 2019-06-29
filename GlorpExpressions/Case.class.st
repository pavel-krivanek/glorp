"
This represents a function which prints prefix, printing CASE, followed by the argument in parentheses, and then the rest of the MS SQL Server CASE statement, with a single test condition (WHEN) and a default value (ELSE):

CASE (arg1)
	WHEN arg2 THEN arg3 
	ELSE arg4
END AS arg5

For example:

CASE ('SELECT count(*) FROM aTable')
	WHEN '0' THEN 0 
	ELSE 1 
END AS arg3

"
Class {
	#name : #Case,
	#superclass : #PrefixFunction,
	#instVars : [
		'argumentTypes'
	],
	#category : #GlorpExpressions
}

{ #category : #'VisualWorks metadata' }
Case class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'initialize-release' }
Case >> argumentTypes: anArray [ 
	argumentTypes := anArray.
]

{ #category : #'initialize-release' }
Case >> initialize [
	super initialize.
	function := 'CASE'.
	separator := ' '.
	argumentTypes := OrderedCollection new: 3.
]

{ #category : #printing }
Case >> printBasicSQLOn: aStream withParameters: aDictionary forSelect: aBoolean [
	"This prints e.g.
		CASE base WHEN arg1 THEN arg2 ELSE arg3 END AS alias
(the AS alias is optional).  Typically it appears in the Select statements of queries that are returning collection checks (e.g. retrieving an isEmpty boolean) that do not allow direct booleans in Select lists.
	Our printing of constants with types is unfortunately tied up with relation expressions, so we shortcircuit some of the logic and just have the types print directly via
		argumentType print: argument on: aStream
This will not let us e.g. bind parameters to this function, but we don't expect to be doing that right now.  If the arguments are booleans, we expect them to be values, not boolean-valued ConstantExpressions;  see, for example, the #exists function in SQLPlatform>>initializeFunctions, and SQLPlatform>>printBoolean:for:.  In cases where there is no platform-handling behaviour and both value and ConstantExpression on value return the same to printSQL..., it does not matter."
	
	aStream
		nextPutAll: function;
		nextPut: $(.
	aBoolean
		ifTrue: [base printSelectSQLOn: aStream withParameters: aDictionary]
		ifFalse: [base printSQLOn: aStream withParameters: aDictionary].
	aStream nextPut: $).
	1 to: arguments size do:
		[:i || keyword argument argumentType |
		keyword := #(' WHEN ' ' THEN ' ' ELSE ') at: i.
		argument := arguments at: i.
		argumentType := argumentTypes at: i.
		aStream nextPutAll: keyword.
		argumentType print: argument on: aStream].
	aStream nextPutAll: ' END '.
	alias notNil ifTrue:
		[aStream
			nextPutAll: 'AS ';
			nextPutAll: alias].
]
