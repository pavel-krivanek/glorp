Extension { #name : #GlorpWorkerTask }

{ #category : #'*GlorpPharoPort' }
GlorpWorkerTask >> <= aTask [ 
	
	^(self > aTask) not
]
