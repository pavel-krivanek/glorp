Extension { #name : #Query }

{ #category : #'*Glorp' }
Query class >> readManyOf: aClass [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: 'Use #read: instead'.
	^self read: aClass
]

{ #category : #'*Glorp' }
Query class >> readManyOf: aClass where: anExpression [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: 'Use #read:where: instead'. 
	^self read: aClass where: anExpression
]

{ #category : #'*Glorp' }
Query class >> returningManyOf: aClass [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: 'Use #read: instead'.
	^self read: aClass
]

{ #category : #'*Glorp' }
Query class >> returningManyOf: aClass where: anExpression [
	"readManyOf: and returningManyOf: are synonyms of read:. This now seems more natural to me, to be consistent with session API."

	self deprecated: 'Use #read:where: instead'.
	^self read: aClass where: anExpression
]

{ #category : #'*Glorp' }
Query class >> returningOneOf: aClass [
	"Backward-compatibility, since we changed the class name."
	"returningOneOf: is a synonym of readOneOf:. This now seems more natural to me, to be consistent with session API."

	self deprecated: 'Use #readOneOf: instead'.
	^self readOneOf: aClass.
]

{ #category : #'*Glorp' }
Query class >> returningOneOf: aClass where: anExpression [
	"Backward-compatibility, since we changed the class name."
	"returningOneOf: is a synonym of readOneOf:. This now seems more natural to me, to be consistent with session API."

	self deprecated: 'Use #readOneOf:where: instead'.
	^self readOneOf: aClass where: anExpression
]
