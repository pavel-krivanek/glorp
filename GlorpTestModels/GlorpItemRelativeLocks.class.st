"
My superclass tests relative fields.  I add two lock fields to test the combination of relative and lock fields.

Instance Variables:
	lock1	<Integer>	VersionType - values are generated
	lock2	<Integer>	GlorpIntegerType ?all values are provided by the user?


"
Class {
	#name : #GlorpItemRelativeLocks,
	#superclass : #GlorpItemWithQty,
	#instVars : [
		'lock1',
		'lock2'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpItemRelativeLocks class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpItemRelativeLocks >> lock1 [

	^lock1
]

{ #category : #accessing }
GlorpItemRelativeLocks >> lock1: anInteger [
	"My database field is of VersionType, so my update values are generated, but this method can set a start value in a test."

	lock1 := anInteger.
]

{ #category : #accessing }
GlorpItemRelativeLocks >> lock2 [

	^lock2
]

{ #category : #accessing }
GlorpItemRelativeLocks >> lock2: anInteger [
	"My database field is _not_ of VersionType.  This is debatable:  generation is normal for lock fields.  Change or clarify.  Also I am not used in tests.  Use or lose me."

	lock2 := anInteger.
]
