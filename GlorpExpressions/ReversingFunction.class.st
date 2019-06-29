"
I print my arguments in reverse.  Use me when it is essential for the MessageArchiver to have the base argument first, to parse correctly, but the SQL needs it to appear second.  Typically, this happens when a constant must be printed first in the SQL but lacks the information that MessageArchiver expects to parse a block into a GlorpExpression.
"
Class {
	#name : #ReversingFunction,
	#superclass : #InfixFunction,
	#category : #GlorpExpressions
}

{ #category : #'VisualWorks metadata' }
ReversingFunction class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #printing }
ReversingFunction >> printSQLOn: aStream withParameters: aDictionary [
	"Print the function in reverse, arguments first then base.  It is unlikely there would be more than one argument;  if there were, they would also be printed in reverse."

	| translated |
	self printsIntoJoins ifFalse:	"this guard clause may be needless"
		[^base printSQLOn: aStream withParameters: aDictionary].
	self functionParts size to: 1 do:
		[:i |	"In reverse order print each argument ..."
		i > arguments size ifFalse:
			[translated := self convertValueOf: (arguments at: i) in: aDictionary.
			translated isGlorpExpression
				ifTrue: [translated printSQLOn: aStream withParameters: aDictionary]
				ifFalse: [self type print: translated on: aStream]].
		aStream	"... then each function part ..."
			nextPut: $ ;
			nextPutAll: (functionParts at: i);
			nextPut: $ ].
	"... and finally, the base."
	base printSQLOn: aStream withParameters: aDictionary.
]

{ #category : #printing }
ReversingFunction >> printTreeOn: aStream [
	"I assume the function has only has one part.  Method #printUnqualifiedSQLOn:withParameters: assumes it may have many parts and an equal number of arguments.  Method #printSQLOn:withParameters: assumes it may have many arguments and even more parts.  These discrepancies exactly reflect the super implementations, which are under review."

	arguments reverse printOn: aStream.
	aStream
		nextPut: $ ;
		nextPutAll: function;
		nextPut: $ .
	base printOn: aStream.
]

{ #category : #printing }
ReversingFunction >> printUnqualifiedSQLOn: aStream withParameters: aDictionary [
	self functionParts size to: 1 do:
		[:index || arg functionPart |
		arg := arguments at: index.
		functionPart := functionParts at: index.
		arg printUnqualifiedSQLOn: aStream withParameters: aDictionary.
		aStream
			nextPut: $ ;
			nextPutAll: functionPart;
			nextPut: $ ].
	base printUnqualifiedSQLOn: aStream withParameters: aDictionary.
]
