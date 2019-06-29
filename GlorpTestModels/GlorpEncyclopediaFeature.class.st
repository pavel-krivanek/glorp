"
I associate an encyclopedia with some featured entry that is either from that encyclopedia or the reification of an inline text field into an entry.  I help test conditional mappings.

Instance Variables:
	encyclopedia	<GlorpEncyclopedia>
	featured	<GlorpEncyclopediaEntry>


"
Class {
	#name : #GlorpEncyclopediaFeature,
	#superclass : #Object,
	#instVars : [
		'encyclopedia',
		'featured'
	],
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpEncyclopediaFeature class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpEncyclopediaFeature >> encyclopedia [

	^encyclopedia
]

{ #category : #accessing }
GlorpEncyclopediaFeature >> encyclopedia: aGlorpEncyclopedia [
	encyclopedia := aGlorpEncyclopedia.
]

{ #category : #'accessing - conditional' }
GlorpEncyclopediaFeature >> featured [
	^featured
]

{ #category : #'accessing - conditional' }
GlorpEncyclopediaFeature >> featured: aGlorpEncyclopediaEntry [
	featured := aGlorpEncyclopediaEntry.
]

{ #category : #'accessing - conditional' }
GlorpEncyclopediaFeature >> featuredEntryText [
	"I pretend to Glorp that I am the direct getter of instvar featuredEntryText.  Actually I get it from my feature instance."

	^featured isNil
		ifFalse: [featured text]
		ifTrue: [nil]
]

{ #category : #'accessing - conditional' }
GlorpEncyclopediaFeature >> featuredEntryText: aString [
	"I pretend to Glorp that I am the direct setter of instvar featuredEntryText.  Actually I store it in my feature instance."

	featured isNil
		ifTrue: [featured := GlorpEncyclopediaEntry new text: aString]
		ifFalse: [featured text: aString].
]
