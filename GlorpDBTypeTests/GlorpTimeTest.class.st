Class {
	#name : #GlorpTimeTest,
	#superclass : #GlorpDatabaseTypeIndividualDBTests,
	#category : #GlorpDBTypeTests
}

{ #category : #'VisualWorks metadata' }
GlorpTimeTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #types }
GlorpTimeTest >> defaultDatabaseType [
	^self platform time
]

{ #category : #tests }
GlorpTimeTest >> testTime [
	self helpTestValue: nil.
	self
		helpTestValue: Time now
		compareWith:
			[:read :original | 
			(read hours = original hours and: [read minutes = original minutes])
				and: [read seconds truncated = original seconds truncated]].
]
