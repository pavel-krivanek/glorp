Class {
	#name : #ASItemBonus,
	#superclass : #Object,
	#instVars : [
		'item',
		'bonus'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
ASItemBonus class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
ASItemBonus >> bonus [

	^bonus
]

{ #category : #accessing }
ASItemBonus >> bonus: anObject [

	bonus := anObject
]

{ #category : #accessing }
ASItemBonus >> item [

	^item
]

{ #category : #accessing }
ASItemBonus >> item: anObject [

	item := anObject
]
