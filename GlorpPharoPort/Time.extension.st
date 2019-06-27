Extension { #name : #Time }

{ #category : #'*GlorpPharoPort' }
Time >> millisecond: anInteger [ 

	nanos := (anInteger rem: 1000) * 1000000

]

{ #category : #'*GlorpPharoPort' }
Time >> milliseconds [
	^ (nanos / 1000000.0)truncated 
]
