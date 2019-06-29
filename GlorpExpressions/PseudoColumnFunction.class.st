"
My pupose is to set an alias on my base.

	- I provide a wrapping alias to any RelationExpression on which I am called.  Ordinarily, this RelationExpression will be acting as a field in the source or target of a join, and therefore as a column in a SELECT list.

I set the alias of any other 

My name is usually just an empty string.  My alias is usually not empty.  I therefore merely print my base expression (expected to be a RelationExpression)
	- as an aliased expression in a SELECT list
	- as merely the unaltered base expression in a join
I suppress binding while printing my base:  see the comment in my #printSQLOn:withParameters:

Background remark:  my existence probably indicates some issue in aliasing which better understanding could eliminate.  FieldExpressions can be alised but those aliases are not printed to the SELECT list.
"
Class {
	#name : #PseudoColumnFunction,
	#superclass : #FunctionExpression,
	#category : #'GlorpExpressions-Glorp-Expressions'
}

{ #category : #'VisualWorks metadata' }
PseudoColumnFunction class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #copying }
PseudoColumnFunction >> createFor: arguments withBase: anExpression symbol: aSymbol [
	arguments isEmpty ifTrue:	"we've set our alias;  normal machinery will handle it"
		[^super createFor: #() withBase: anExpression symbol: aSymbol].
	anExpression class == RelationExpression ifTrue:	
		[^(super createFor: #() withBase: anExpression symbol: aSymbol)
			alias: arguments first value].
	anExpression class == MappingExpression ifTrue:	
		[^(super createFor: #() withBase: anExpression symbol: aSymbol)
			alias: arguments first value].
	"assume anExpression has an alias instvar; just set it"
	^anExpression alias: arguments first value
]

{ #category : #accessing }
PseudoColumnFunction >> mappingSequenceName [
	^base mappingSequenceName
]

{ #category : #printing }
PseudoColumnFunction >> printSQLOn: aStream withParameters: aDictionary [
	"I present a RelationExpression as a field to a FieldExpression.  The rightChild of a RelationExpression could be a bound value, but I cannot handle binding.  Even if FieldExpression>>addBoundExpressionsIn: were extended to call me (which would require DatabaseField>>addBoundExpressionIn: to understand it as well, as a no-op) the FieldExpression will call #translateField: on me and rebuild me on its base, so the boundExpression into which I write a bindMarker within the call below will be the same but _not_ identical to the boundExpression cached earlier to find the bind count.  We therefore keep things simple by switching off binding as we print."

	"aStream nextPut: $(."
	| outerBindingState |
	outerBindingState := aStream useBinding.
	[aStream useBinding: false.
	base printSelectSQLOn: aStream withParameters: aDictionary]
		ensure: [aStream useBinding: outerBindingState].
	"aStream nextPut: $)."
]

{ #category : #printing }
PseudoColumnFunction >> printTreeOn: aStream [
	aStream nextPutAll: self class name.
	aStream nextPut: $(.
	alias isNil ifFalse: [aStream nextPutAll: alias].
	aStream nextPut: $,; nextPut: $ .
	base printTreeOn: aStream.
	aStream nextPut: $).
]

{ #category : #testing }
PseudoColumnFunction >> printsIntoJoins [
	"The alias is only needed (or wanted) when the expression is printed in a SELECT field list.  As the bug which cased aliases to be printed elsewhere for PrefixFunctions is now fixed, arguably this method is no longer needed, but it serves to abort printing earlier."

	^false
]

{ #category : #accessing }
PseudoColumnFunction >> table [
	^self base table
]
