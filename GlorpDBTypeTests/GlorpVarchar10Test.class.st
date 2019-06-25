Class {
	#name : #GlorpVarchar10Test,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #GlorpDBTypeTests
}

{ #category : #'VisualWorks metadata' }
GlorpVarchar10Test class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpVarchar10Test >> defaultDatabaseType [
	^self platform varchar: 10.
]

{ #category : #tests }
GlorpVarchar10Test >> testVarCharWithEscapedCharacters [
	stType := String.
	self helpTestValue: nil.
	#($\ $~ $` $! $@ $# $$ $% $^ $& $* $( $) $_ $- $+ $= $| $} ${ $] $[ $" $' $: $; $? $/ $> $. $< $,)
		do: [:ea | self helpTestValue: 'abc' , (String with: ea) , 'def']
]