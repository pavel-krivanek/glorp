Extension { #name : #Collection }

{ #category : #'*GlorpTestModels-glorp' }
Collection >> assertEqual: aCollection [
	"A convenience method for testing"
	self asSortedCollection with: aCollection asSortedCollection do: [:a :b |
		a assertEqual: b].
]
