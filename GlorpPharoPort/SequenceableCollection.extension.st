Extension { #name : #SequenceableCollection }

{ #category : #'*GlorpPharoPort' }
SequenceableCollection >> atIndex: anInteger [ 
	^self at: anInteger
]

{ #category : #'*GlorpPharoPort' }
SequenceableCollection >> isSameSequenceAs: otherCollection [
	
	^ self hasEqualElements: otherCollection
]
