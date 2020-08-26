Extension { #name : #Proxy }

{ #category : #'*GlorpPharoPort' }
Proxy >> gtDisplayString [ 

	self isInstantiated
		ifTrue: [ ^self class name , ' on ', value gtDisplayString].
	^self class name, ' uninstantiated on ', self query resultClass name 
]

{ #category : #'*GlorpPharoPort' }
Proxy >> gtInspectorVariableNodesIn: aCollection [
	aCollection
		addAll: ((self class allSlots collect: [ :slot | 
			GTInspectorSlotNode hostObject: self slot: slot ]))
]

{ #category : #'*GlorpPharoPort' }
Proxy >> readSlot: aSlot [
	^aSlot read: self
]
