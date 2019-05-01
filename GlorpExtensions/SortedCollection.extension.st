Extension { #name : #SortedCollection }

{ #category : #'*GlorpExtensions' }
SortedCollection >> writeStream [
	^AddingWriteStream on: self.
]
