Extension { #name : #String }

{ #category : #'*GlorpExtensions-glorp' }
String >> glorpIsCollection [
	"For our purposes, these aren't collections, but rather a simple database type"
	^false.
]

{ #category : #'*GlorpExtensions-glorp' }
String >> glorpPrintSQLOn: aCommand [
	| platform |
	aCommand nextPut: $'.	
	platform := [aCommand platform] on: MessageNotUnderstood do: [:ex | ex return: nil].
	platform isNil
		ifFalse: [platform printEscapedString: self on: aCommand]
		ifTrue: [aCommand nextPutAll: self].
	aCommand nextPut: $'.
]

{ #category : #'*GlorpExtensions-glorp' }
String >> like: aPattern [ 
	"This uses, with permission, the code from ObjectStudio that implements this."
	^self 
		likePattern: aPattern
		from: 1
		sourceStart: 1


	":Section Reference
							like: aPattern
		Description:        	Returns true if the receiver contains a string being
                   	 			matched by the parameter 'aPattern'. Using the wildcard
					  		$% serves as placeholder for 0-n $_ as a placeholder
					  		for a single matched character.
		Assumptions:        	'aPattern' is expected to be of class String.
		Return Value:       	true or false.
		Receiver Modified:  	No.
		Examples:			('abcdefg' like: 'abc%') -> true
							('abcdefg' like: 'abc__fg') -> true
  							('abcdefg' like: '_defg') -> false
	:End"
]

{ #category : #'*GlorpExtensions-glorp' }
String >> likePattern: aPattern from: patternStart sourceStart: sourceStart [ 
	"Note that this uses, with permission, the code from ObjectStudio that does this. It's a recursive implementation, but this is primarily for in-memory mimicking of database operations so the performance limitations shouldn't be a big issue."
	| c |
	patternStart > aPattern size ifTrue: [^sourceStart > self size].
	c := aPattern at: patternStart.
	c == $% 
		ifTrue: 
			[sourceStart to: self size + 1
				do: 
					[:ind | 
					(self 
						likePattern: aPattern
						from: patternStart + 1
						sourceStart: ind) ifTrue: [^true]].
			^false].
	sourceStart > self size ifTrue: [^false].
	(c == $_ or: [c == (self at: sourceStart)]) 
		ifTrue: 
			[^self 
				likePattern: aPattern
				from: patternStart + 1
				sourceStart: sourceStart + 1].
	^false


	":Section Reference
							likePattern: aPattern from: patternStart sourceStart: sourceStart
		Description:        	Returns true if the receiver contains a string being
                    				matched by the parameter 'aPattern'. Using the wildcard
					  		$% serves as placeholder for 0-n $_ as a placeholder
					  		for a single matched character.
		Assumptions:        'aPattern' is expected to be of class String.
		Return Value:       true or false.
		Receiver Modified:  No.
	:End"
]
