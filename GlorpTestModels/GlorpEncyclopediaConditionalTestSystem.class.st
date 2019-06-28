"
I add a conditional mapping to an entry and another to an author.  These mappings are either to an actual entry or to a pseudo-entry held by the encylopedia, depending on the size of the text supplied.
"
Class {
	#name : #GlorpEncyclopediaConditionalTestSystem,
	#superclass : #GlorpEncyclopediaDescriptorSystem,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpEncyclopediaConditionalTestSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #classes }
GlorpEncyclopediaConditionalTestSystem >> classModelForGlorpEncyclopediaFeature: aClassModel [
	aClassModel newAttributeNamed: #encyclopedia.
	aClassModel newAttributeNamed: #featured type: GlorpEncyclopediaEntry.
	(aClassModel newAttributeNamed: #featuredEntryText type: String) useDirectAccess: false.
]

{ #category : #descriptors }
GlorpEncyclopediaConditionalTestSystem >> descriptorForGlorpEncyclopediaFeature: aDescriptor [
	"We either have a 'featured' entry and put its id in field featuredEntryID, or we have the feature entry string directly in field featuredEntryString.  The first case is the representativeMapping and so decides the conditional name, referenceClass, etc."

	| featuredEntryStringField featuredEntryIDField encycEntryTable conditional featuredEntryMapping table |
	table := self tableNamed: 'ENCYC_WITH_FEATURE'.
	aDescriptor table: table.
	
	(aDescriptor directMapping from: #id to: (table fieldNamed: 'ENCYC_ID')) beForPseudoVariable.
	aDescriptor oneToOneMapping
		attributeName: #encyclopedia;
		referenceClass: GlorpEncyclopedia;
		join: (Join
				from: (table fieldNamed: 'ENCYC_ID')
				to: ((self tableNamed: 'ENCYC') fieldNamed: 'ID')).
	"For testing"
	featuredEntryIDField := aDescriptor table fieldNamed: 'featuredEntryID'.
	(aDescriptor directMapping from: #featuredEntryID to: featuredEntryIDField) beForPseudoVariable.
	featuredEntryStringField := aDescriptor table fieldNamed: 'featuredEntryString'.
	(aDescriptor directMapping from: #featuredEntryString to: featuredEntryStringField) beForPseudoVariable.

	encycEntryTable := self tableNamed: 'ENCYC_ENTRY'.
	conditional := aDescriptor newMapping: ConditionalMapping.
	featuredEntryMapping := (conditional newMapping: OneToOneMapping)
		attributeName: #featured;
		join: (Join
				from: featuredEntryIDField
				to: (encycEntryTable fieldNamed: 'ID')).
	conditional
		forField: featuredEntryStringField	"nil size = 0 so gets string case but returns nil anyway"
		attribute: [:object | object featuredEntryText size > featuredEntryStringField type width
						ifFalse: [object featuredEntryText]
						ifTrue: [nil]]
		if: [:each | each isNil] useMapping: featuredEntryMapping.
	conditional otherwise: (DirectMapping from: #featuredEntryText to: featuredEntryStringField).
	aDescriptor resetMappedFields.	"from ConditionalMapping>>newMapping - maybe the otherwise: should call this?"
	"conditional debugRead: true.
	conditional debugWrite: true."
]

{ #category : #examples }
GlorpEncyclopediaConditionalTestSystem >> exampleEncyclopediaFeatures [
	^self exampleEncyclopedias collect:
		[:each |
		GlorpEncyclopediaFeature new
			encyclopedia: each;
			yourself]
]

{ #category : #tables }
GlorpEncyclopediaConditionalTestSystem >> tableForENCYC_WITH_FEATURE: aTable [
	"Add a featured entry whose text will be stored locally if short but in an entry of the linked encyclopedia if long."

	(aTable createFieldNamed: 'ENCYC_ID' type: platform int4) bePrimaryKey.
	aTable createFieldNamed: 'featuredEntryID' type: (platform varChar: 50).	"The entry table's id is a varchar"
	aTable createFieldNamed: 'featuredEntryString' type: (platform varchar: 30).
]
