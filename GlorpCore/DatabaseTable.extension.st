Extension { #name : #DatabaseTable }

{ #category : #'*GlorpCore' }
DatabaseTable >> hasForeignKeyConstraintMatching: aConstraint [
	^self foreignKeyConstraints
		anySatisfy: [:each | (each matchesForeignKeyConstraint: aConstraint)].
]

{ #category : #'*GlorpCore' }
DatabaseTable >> hasForeignKeyConstraintTheSameAs: aConstraint [

	^self foreignKeyConstraints anySatisfy: [:each | (each isTheSameAs: aConstraint)].
]

{ #category : #'*GlorpCore' }
DatabaseTable >> hasUniqueConstraintMatching: aConstraint [
	
	^self uniqueConstraints anySatisfy: [:each | each matchesUniqueConstraint: aConstraint]
]
