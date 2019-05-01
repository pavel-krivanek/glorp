Extension { #name : #IdentityDictionary }

{ #category : #'*GlorpExtensions' }
IdentityDictionary >> glorpAtIdentity: aKey ifAbsent: aBlock [
	^self at: aKey ifAbsent: aBlock.
]
