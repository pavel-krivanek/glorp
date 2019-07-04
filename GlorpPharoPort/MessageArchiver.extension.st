Extension { #name : #MessageArchiver }

{ #category : #'*GlorpPharoPort' }
MessageArchiver >> isNil [ 

	"in Pharo, the ProtoObject implements isNil message (so the MessageArchiver understands it). We need to pretend that it is not known"
	^self get: #isNil withArguments: #().
]
