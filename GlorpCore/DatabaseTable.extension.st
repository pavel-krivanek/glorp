Extension { #name : #DatabaseTable }

{ #category : #'*GlorpCore-testing' }
DatabaseTable >> hasForeignKeyConstraintMatching: aConstraint [
	^self foreignKeyConstraints
		anySatisfy: [:each | (each matchesForeignKeyConstraint: aConstraint)].
]

{ #category : #'*GlorpCore-testing' }
DatabaseTable >> hasForeignKeyConstraintTheSameAs: aConstraint [

	^self foreignKeyConstraints anySatisfy: [:each | (each isTheSameAs: aConstraint)].
]

{ #category : #'*GlorpCore-testing' }
DatabaseTable >> hasUniqueConstraintMatching: aConstraint [
	
	^self uniqueConstraints anySatisfy: [:each | each matchesUniqueConstraint: aConstraint]
]
