Extension { #name : #Proxy }

{ #category : #'*GlorpQueries-Pharo' }
Proxy >> = anObject [
	"In VA we inherit this as identity. Need to override"
	^self isGlorpProxy & anObject isGlorpProxy
		ifTrue: [ self getValue = anObject getValue ]
		ifFalse: [ super = anObject ]
]

{ #category : #'*GlorpQueries-Pharo' }
Proxy >> species [

	self isInstantiated ifTrue: [^value species].
	query isNil ifTrue: [^Proxy].
	query resultClass isNil ifTrue: [^Proxy].
	^query resultClass species

]
