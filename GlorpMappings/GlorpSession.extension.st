Extension { #name : #GlorpSession }

{ #category : #'*GlorpMappings-accessing' }
GlorpSession >> databaseTableClass [

	^system databaseTableClass
]

{ #category : #'*GlorpMappings-private' }
GlorpSession >> embeddedObjectsFor: anObject [
	"Return all the objects embedded into this one"
	| embedded descriptor |
	descriptor := self descriptorFor: anObject.
	descriptor isNil ifTrue: [^#()].
	embedded := OrderedCollection new: 3.
	descriptor mappings do: [:each |
		(each class == EmbeddedValueOneToOneMapping) ifTrue: [
			embedded add: (each getValueFrom: anObject)]].
	^embedded.
]
