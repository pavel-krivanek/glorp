Extension { #name : #Proxy }

{ #category : #'*GlorpPharoPort' }
Proxy >> readSlot: aSlot [
	^aSlot read: self
]

{ #category : #'*GlorpPharoPort' }
Proxy >> stDisplayString [ 

	self isInstantiated
		ifTrue: [ ^self class name , ' on ', value stDisplayString].
	^self class name, ' uninstantiated on ', self query resultClass name
]
