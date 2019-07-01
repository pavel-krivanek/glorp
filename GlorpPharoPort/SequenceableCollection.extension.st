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
SequenceableCollection >> replaceElementsFrom: start to: stop withSequenceableCollection: replacement startingAt: repStart [ 
	
	^ self replaceFrom: start to: stop with: replacement startingAt: repStart 

]

{ #category : #'*GlorpPharoPort' }
SequenceableCollection >> tokensBasedOn: anObject [

	^ self splitOn: anObject
]
