Extension { #name : #IdentityDictionary }

{ #category : #'*GlorpExtensions-accessing' }
IdentityDictionary >> glorpAtIdentity: aKey ifAbsent: aBlock [
	^self at: aKey ifAbsent: aBlock.
]
