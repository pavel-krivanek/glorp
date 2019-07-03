Extension { #name : #AbstractProxy }

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> asSetElement [
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> doesNotUnderstand: aMessage [

	^self getValue perform: aMessage selector withArguments: aMessage arguments.
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> instVarAt: index [ 
	"Primitive. Answer a fixed variable in an object. The numbering of the 
	variables corresponds to the named instance variables. Fail if the index 
	is not an Integer or is not the index of a fixed variable. Essential. See 
	Object documentation whatIsAPrimitive."

	<primitive: 73>
	"Access beyond fixed variables."
	^self basicAt: index - self class instSize		
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> isNumber [

	^false
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> isSelfEvaluating [
	^false
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> isString [

	^false
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> longPrintOn: aStream limitedTo: sizeLimit indent: indent [
	"Append to the argument, aStream, the names and values of all of the receiver's instance variables.  Limit is the length limit for each inst var."

	self class allInstVarNames doWithIndex:
		[:title :index |
		indent timesRepeat: [aStream tab].
		aStream nextPutAll: title;
		 nextPut: $:;
		 space;
		 tab;
		 nextPutAll: 
			((self instVarAt: index) printStringLimitedTo: (sizeLimit -3 -title size max: 1));
		 cr]
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> longPrintStringLimitedTo: aLimitValue [
	"Answer a String whose characters are a description of the receiver."
	
	| str |
	str := String streamContents: [:aStream | self longPrintOn: aStream limitedTo: aLimitValue indent: 0].
	"Objects without inst vars should return something"
	^ str isEmpty ifTrue: [self printString, String cr] ifFalse: [str]
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> printStringLimitedTo: limit [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString."
	| limitedString |
	limitedString := String streamContents: [:s | self printOn: s] limitedTo: limit.
	limitedString size < limit ifTrue: [^ limitedString].
	^ limitedString , '...etc...'
]

{ #category : #'*GlorpQueries-Pharo' }
AbstractProxy >> shouldBePrintedAsLiteral [

	^false
]
