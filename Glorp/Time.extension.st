Extension { #name : #Time }

{ #category : #'*Glorp' }
Time >> millisecond: anInteger [ 

	nanos := (anInteger rem: 1000) * 1000000

]

{ #category : #'*Glorp' }
Time >> milliseconds [
	^ (nanos / 1000000.0)truncated 
]
