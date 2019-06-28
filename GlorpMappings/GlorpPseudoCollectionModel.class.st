"
I am an attribute model serving a to-many mapping between a table and an object that is simple (i.e. unmapped by Glorp) and answers false to #glorpIsCollection.  Typically this object wraps a String, ByteArray or other sequenceable collection, subsequences of which I wish to store in successive rows, and iterates (in responce to the minimal collection protocol I send) by returning successive subsequences or else returning itself repeatedly with its state set to provide successive subsequences.  I handle getting and setting all the subsequences as a collection, and also adding individual subsequences one by one when alsoFetched as part of a larger query.

Unlike GlorpSubsequenceModel, I require my target object to manage iteration.  It must understand #do: and #add:.  Like GlorpSubsequenceModel, my current implementation requires that an earlier mapping allocate the space I need for a new instance of the overall mapping (obviously, I cannot even know the total needed while I am knitting subsequences one by one);  this could be altered to grow capacity when required.

Instance Variables:
	pseudoCollectionType	<Class>	What is the class of the object that manages our iteration.
"
Class {
	#name : #GlorpPseudoCollectionModel,
	#superclass : #GlorpAttributeModel,
	#instVars : [
		'pseudoCollectionType'
	],
	#category : #GlorpMappings
}

{ #category : #'VisualWorks metadata' }
GlorpPseudoCollectionModel class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #copying }
GlorpPseudoCollectionModel >> copyFrom: anAttributeModel [
	anAttributeModel isNil ifTrue: [^self].
	super copyFrom: anAttributeModel.
	(anAttributeModel class includesBehavior: self class) ifFalse: [^self].
	pseudoCollectionType := anAttributeModel pseudoCollectionType.
]

{ #category : #knitting }
GlorpPseudoCollectionModel >> knit: owningObject to: memberObject at: anInteger [
	"We are a collection attribute of a mapping that, via #writeTheOrderField, knows the indices of its elements, and ensures they are read."

	^(self getValueFrom: owningObject) add: memberObject
]

{ #category : #mapping }
GlorpPseudoCollectionModel >> loopOver: aPseudoCollection doing: aBlock [
	"We return true to #isCollectionAttribute and false to #isDictionaryAttribute.  Our parameter, being a string, will return false to #glorpIsCollection, but we will treat it as such, breaking it into substrings."

	| index |
	aPseudoCollection isNil ifTrue: [^nil].
	self checkTargetType: aPseudoCollection.	"check the whole thing, so no need to check subsequences"
	index := 0.
	aPseudoCollection do:
		[:each | index := index + 1.
		aBlock value: index value: each glorpRealObject]
]

{ #category : #accessing }
GlorpPseudoCollectionModel >> pseudoCollectionType [
	^pseudoCollectionType
]

{ #category : #accessing }
GlorpPseudoCollectionModel >> pseudoCollectionType: aClass [
	"of the pseudoCollection class must understand #add: and #do: and (if sequenceable) must manage iteration state when they are called to preserve sequence order."

	pseudoCollectionType := aClass.
]

{ #category : #'get/set' }
GlorpPseudoCollectionModel >> setValueIn: anObject to: aSequenceableCollection [
	"A prior mapping must have allocated the pseudoCollection total length.  Another handles the inline-mapped content.  Put the remaining subsequences in the allocated but unwritten part of the pseudoCollection."

	| pseudoCollection |
	aSequenceableCollection isNil ifTrue: [^aSequenceableCollection].
	aSequenceableCollection isEmpty ifTrue: [^aSequenceableCollection].
	pseudoCollection := self getValueFrom: anObject.
	aSequenceableCollection do: [:each | pseudoCollection add: each].
	^aSequenceableCollection
]
