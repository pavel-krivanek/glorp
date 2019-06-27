Class {
	#name : #GlorpMessageCollectorTest,
	#superclass : #GlorpTestCase,
	#instVars : [
		'collector'
	],
	#category : #'GlorpTests-GlorpTest'
}

{ #category : #'VisualWorks metadata' }
GlorpMessageCollectorTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #tests }
GlorpMessageCollectorTest >> messageCollectorDNUObjectStudio [
	| caught |
	caught := false.
	[collector basicDoesNotUnderstand: #foo args: #()] on: MessageNotUnderstood
		do: [:signal | caught := true. signal sunitExitWith: nil].
	self assert: caught
]

{ #category : #support }
GlorpMessageCollectorTest >> setUp [
	super setUp.
	collector := MessageArchiver new
]

{ #category : #tests }
GlorpMessageCollectorTest >> testExpressionCreation [
	| exp |
	exp := collector foo asGlorpExpression.
	self assert: exp name == #foo.
	self assert: exp base class == BaseExpression
]

{ #category : #tests }
GlorpMessageCollectorTest >> testMessageCollectorDNU [
	| message caught |
	Dialect isObjectStudio ifTrue: [
		^self messageCollectorDNUObjectStudio].
	message := Message selector: #foo arguments: #().
	caught := false.
	[collector basicDoesNotUnderstand: message] on: MessageNotUnderstood
		do: [:signal | caught := true. signal sunitExitWith: nil].
	self assert: caught
]

{ #category : #tests }
GlorpMessageCollectorTest >> testMessageIntercept [

	| foo |
	foo := collector foo.
	self assert: foo privateGlorpSelector == #foo.
	self assert: foo privateGlorpReceiver == collector.
]
