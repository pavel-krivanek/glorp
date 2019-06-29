"
I am an attribute model serving a to-many mapping between a table and a String, ByteArray or other sequenceable collection that normally answers false to #glorpIsCollection, but subsequences of which I wish to store in successive rows.  I do not use direct access.  I handle getting and setting all the subsequences as a collection, and also adding individual subsequences one by one when alsoFetched as part of a larger query.

My current implementation requires that an earlier mapping allocate the space I need for a new instance of the overall mapping (obviously, I cannot even know the total needed when I am knitting);  this could be altered to grow capacity when required.  If the value of 'preStart' is not zero, I assume that another mapping (possibly the same one if it is conditional) handles the initial subsequence.

Instance Variables:
	preStart	<Integer>	the end point of that part of the overall sequence that is written inline
	step	<Integer>	the length of a subsequence
"
Class {
	#name : #GlorpSubsequenceModel,
	#superclass : #GlorpAttributeModel,
	#instVars : [
		'preStart',
		'step'
	],
	#category : #GlorpMappings
}

{ #category : #'VisualWorks metadata' }
GlorpSubsequenceModel class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #mapping }
GlorpSubsequenceModel >> chunk: aString doing: aBlock [
	"We return true to #isCollectionAttribute and false to #isDictionaryAttribute.  Our parameter returns false to #glorpIsCollection, but we treat it as a sequenced collection of zero or more substrings."

	| startPosition endPosition |
	preStart < aString size ifFalse: [^self].	"the size of this pseudo-collection is zero"
	startPosition := preStart + 1.
	endPosition := preStart + step.
	"iterate over any and all chunks before the last ..."
	[endPosition < aString size] whileTrue:
		[aBlock value: (aString copyFrom: startPosition to: endPosition).
		startPosition := endPosition + 1.
		endPosition := endPosition + step].
	"... then the last whole-size-or-less chunk."
	aBlock value: (aString copyFrom: startPosition to: aString size).
]

{ #category : #copying }
GlorpSubsequenceModel >> copyFrom: anAttributeModel [
	anAttributeModel isNil ifTrue: [^self].
	super copyFrom: anAttributeModel.
	(anAttributeModel class includesBehavior: self class) ifFalse: [^self].
	preStart := anAttributeModel subsequencesStartAfter.
	step := anAttributeModel subsequenceStep.
]

{ #category : #'initialize-release' }
GlorpSubsequenceModel >> initialize [
	"For now, assume the name that would directly access our overall sequence is taken by another mapping, so make indirect access the default.  Later, arrange some 'clever' way of setting the direct access instvar index without risking a name clash."

	super initialize.
	useDirectAccess := false.
	preStart := 0.	"read and write the entire sequence in this attribute"
]

{ #category : #knitting }
GlorpSubsequenceModel >> knit: owningObject to: memberObject at: anInteger [
	"We are a collection attribute of a mapping that, via #writeTheOrderField, knows the indices of its elements, and ensures they are read."

	| position |
	position := preStart + (anInteger - 1 * step).
	^(self getValueFrom: owningObject)
		replaceElementsFrom: position + 1
		to: position + memberObject size
		withSequenceableCollection: memberObject
		startingAt: 1
]

{ #category : #mapping }
GlorpSubsequenceModel >> loopOver: aString doing: aBlock [
	"We return true to #isCollectionAttribute and false to #isDictionaryAttribute.  Our parameter, being a string, will return false to #glorpIsCollection, but we will treat it as such, breaking it into substrings."

	| index |
	aString isNil ifTrue: [^nil].
	self checkTargetType: aString.	"check the whole thing, so no need to check subsequences"
	index := 0.
	self chunk: aString doing:
		[:each | index := index + 1.
		aBlock value: index value: each glorpRealObject].
]

{ #category : #'get/set' }
GlorpSubsequenceModel >> setValueIn: anObject to: aSequenceableCollection [
	"A prior mapping must have allocated the pseudoCollection total length.  Another handles the inline-mapped content.  Put the remaining subsequences in the allocated but unwritten part of the pseudoCollection."

	| pseudoCollection position |
	aSequenceableCollection isNil ifTrue: [^aSequenceableCollection].
	aSequenceableCollection isEmpty ifTrue: [^aSequenceableCollection].
	position := preStart.
	pseudoCollection := self getValueFrom: anObject.
	aSequenceableCollection do:
		[:each |
		pseudoCollection
			replaceElementsFrom: position + 1
			to: (position := position + each size)
			withSequenceableCollection: each
			startingAt: 1].
	^aSequenceableCollection
]

{ #category : #copying }
GlorpSubsequenceModel >> subsequenceStep [
	^step
]

{ #category : #copying }
GlorpSubsequenceModel >> subsequencesStartAfter [
	^preStart
]

{ #category : #'initialize-release' }
GlorpSubsequenceModel >> subsequencesStartAfter: anInteger stepping: anotherInteger [
	preStart := anInteger.
	step := anotherInteger.
]
