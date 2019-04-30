Extension { #name : #DatabaseRow }

{ #category : #'*Glorp' }
DatabaseRow >> at: aField forcePut: aValue [ 
	"Write the value. If there's a previous value, overwrite it. Use with extreme caution."
	| wrapper |
	aValue isGlorpExpression ifTrue: [self error: 'cannot store expressions in rows'].
	aField table == self table ifFalse: [self error: 'Invalid table'].
	wrapper := self contentsAt: aField ifAbsentPut: [FieldValueWrapper new].
	wrapper privateSetContents: aValue.
	^wrapper.
]

{ #category : #'*Glorp' }
DatabaseRow >> at: aField put: aValue [ 
	
	"For generated fields, we expect the real value to be provided later by the database, so don't write a nil value"
	
	| wrapper |
"	aValue isGlorpExpression ifTrue: [self error: 'cannot store expressions in rows']."
	aField table == self table ifFalse: [self error: 'Invalid table'].
	wrapper := self contentsAt: aField ifAbsentPut: [FieldValueWrapper new].
	(aValue isNil and: [aField isGenerated]) ifFalse: [wrapper contents: aValue].
	wrapper isNowContainedBy: self and: aField.
	^wrapper.
]

{ #category : #'*Glorp' }
DatabaseRow >> numberOfFields [
	^contents
		inject: 0
		into:
			[:sum :each | sum + (each == self class emptySlot ifTrue: [0] ifFalse: [1])].
]

{ #category : #'*Glorp' }
DatabaseRow >> unifyField: eachSourceField withField: eachTargetField inRow: targetRow [
	| sourceWrapper targetWrapper |
	sourceWrapper := self wrapperAt: eachSourceField ifAbsent: [nil].
	targetWrapper := targetRow wrapperAt: eachTargetField ifAbsent: [nil].
	sourceWrapper isNil
		ifTrue:
			[targetWrapper isNil
				ifTrue:
					[targetWrapper := FieldValueWrapper new.
					targetRow wrapperAt: eachTargetField put: targetWrapper].
			^self wrapperAt: eachSourceField put: targetWrapper].
	targetWrapper isNil ifTrue: [^targetRow wrapperAt: eachTargetField put: sourceWrapper].
	sourceWrapper unifyWith: targetWrapper.
]
