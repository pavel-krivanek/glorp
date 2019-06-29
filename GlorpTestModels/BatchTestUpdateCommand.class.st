"
No platform we support uses batch binding in update today, so we do not complicate implementors of #bindingTypes in UpdateCommand and subclasses with that case but instead have this test-only mock command to exercise it.
"
Class {
	#name : #BatchTestUpdateCommand,
	#superclass : #UpdateCommand,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
BatchTestUpdateCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #'bound values' }
BatchTestUpdateCommand >> batchBindingTypes: arrayBindingTypes [
	"Were batch binding to be used in the UpdateCommand hierarchy, not just in this test, this metghod should be pushed up and called on bindingTypes as needed."

	| size all |
	size := arrayBindingTypes size.
	all := Array new: allRows size * size.
	0 to: allRows size - 1 do:
		[:i || index | index := i * size.
		all replaceElementsFrom: index + 1 to: index + size withArray: arrayBindingTypes startingAt: 1].
	^all
]

{ #category : #'bound values' }
BatchTestUpdateCommand >> bindingTypes [
	^(self shouldUseGroupWriting not or: [self platform usesArrayBindingToGroupWrite])
		ifTrue: [super bindingTypes]
		ifFalse: [self batchBindingTypes: super bindingTypes]
]
