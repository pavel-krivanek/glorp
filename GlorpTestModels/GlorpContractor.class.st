"
I exercise embedded mappings in subclasses of FilteredType-resolved hierarchies.

Instance Variables:
	hourlyRate	<GlorpMoney>	to test how embedded mappings work with filtered type resolution


"
Class {
	#name : #GlorpContractor,
	#superclass : #GlorpEmployee,
	#instVars : [
		'hourlyRate'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpContractor class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpContractor >> hourlyRate [
	^hourlyRate
]

{ #category : #accessing }
GlorpContractor >> hourlyRate: aGlorpMoney [
	hourlyRate := aGlorpMoney.
]
