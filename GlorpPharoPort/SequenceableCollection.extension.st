Extension { #name : #SequenceableCollection }

{ #category : #'*GlorpPharoPort' }
SequenceableCollection >> atIndex: anInteger [ 
	^self at: anInteger
]

{ #category : #'*GlorpPharoPort' }
SequenceableCollection >> isSameSequenceAs: otherCollection [
	
	^ self hasEqualElements: otherCollection
]

{ #category : #'*GlorpPharoPort' }
SequenceableCollection >> tokensBasedOn: anObject [

	^ self splitOn: anObject
]
