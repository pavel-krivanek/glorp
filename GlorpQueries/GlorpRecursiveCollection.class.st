"
I pretend to be a collection and a stream to Glorp, receiving a collection of blobs that I rearrange into a chain.  To my Glorp domain class, I pretend to be a stream on a single object, not a collection, returning only the first item when asked my contents.

Instance Variables:
	firstItem	<Object>	the first item in the chain


"
Class {
	#name : #GlorpRecursiveCollection,
	#superclass : #Object,
	#instVars : [
		'firstItem'
	],
	#category : #GlorpQueries
}

{ #category : #'instance creation' }
GlorpRecursiveCollection class >> new: aSize [
	"I wrap a chain, not a collection, so cannot usefully pre-size anything."

	^self new
]

{ #category : #'VisualWorks metadata' }
GlorpRecursiveCollection class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpRecursiveCollection >> contents [
	"Respond to collection protocol with the first item in the chain."

	^firstItem
]

{ #category : #accessing }
GlorpRecursiveCollection >> nextPutAll: aSequenceableCollection [
	"For now, we hardcode #next: as the parameter-returning successor method.  Later, we may provide a block or similar and or switch from class-side new: to instance-side copyEmpty{:} as the means to get instances.  We return the parameter merely for consistency with other implementors of #nextPutAll:."

	aSequenceableCollection isEmpty ifTrue: [^aSequenceableCollection].
	(2 to: aSequenceableCollection size)
		inject: (firstItem := aSequenceableCollection first)
		into: [:eachPrev :eachIndex |
			eachPrev next: (aSequenceableCollection at: eachIndex)].
	^aSequenceableCollection
]

{ #category : #streams }
GlorpRecursiveCollection >> writeStream [
	"Return self - I'll be my own pseudo-writeStream on my own pseudo-collection."
]
