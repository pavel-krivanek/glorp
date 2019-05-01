Extension { #name : #Dictionary }

{ #category : #'*GlorpExtensions' }
Dictionary >> glorpAddAll: aCollection [
	"An addAll: that can work for either a dictionary argument or a collection of associations"
	aCollection glorpAddAllToDictionary: self.
]
