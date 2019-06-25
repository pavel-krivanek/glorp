"
This generates version numbers by adding one to the previous value of the designated field.
"
Class {
	#name : #VersionNumberVersionGenerator,
	#superclass : #VersionGenerator,
	#category : #GlorpDatabase
}

{ #category : #'VisualWorks metadata' }
VersionNumberVersionGenerator class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #sequencing }
VersionNumberVersionGenerator >> nextValueFor: aField in: aRow [
	| oldValue |
	oldValue := aRow at: aField ifAbsent: [0].
	^(oldValue isNil ifTrue: [0] ifFalse: [oldValue]) + 1
]
