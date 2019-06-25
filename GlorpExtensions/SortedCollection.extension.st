Extension { #name : #SortedCollection }

{ #category : #'*GlorpExtensions-streams' }
SortedCollection >> writeStream [
	^AddingWriteStream on: self.
]
