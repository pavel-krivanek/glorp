Extension { #name : #SequenceableCollection }

{ #category : #'*GlorpPharoPort' }
SequenceableCollection >> isSameSequenceAs: otherCollection [
	
	^ self hasEqualElements: otherCollection
]
