"
When an object is registered, either at top-level or as part of completing the transitive closure of registration, and that object's descriptor includes a ConditionalMapping, neither the conditional mapping nor its resolved mapping for that object adds itself to the transitive closure.  Thus only simple direct mappings can be conditional.  Write a test that shows this, thus fix it.
"
Class {
	#name : #GlorpConditionalMappingDBTest,
	#superclass : #GlorpMappingDBTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpConditionalMappingDBTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #running }
GlorpConditionalMappingDBTest >> setUp [
	super setUp.
	system := GlorpEncyclopediaConditionalTestSystem forPlatform: session system platform.
	session system: system.
	session beginTransaction.	"prevent any transaction in test committing transaction along with the unit of work."
]

{ #category : #running }
GlorpConditionalMappingDBTest >> tearDown [
	session rollbackTransaction.
	super tearDown.
]

{ #category : #running }
GlorpConditionalMappingDBTest >> testNilCompare [
	"Can we use the conditional in a where clause, comparing to nil."

	self writeExampleEncycFeaturesOneMapOneInlineOneNil.
	"Read data using each of the conditional mappings two cases' pseudovariables."
	self assert: (session
				read: GlorpEncyclopediaFeature
				where: [:each | each featuredEntryID notNil]) size = 1.
	self assert: (session
				read: GlorpEncyclopediaFeature
				where: [:each | each featuredEntryString notNil]) size = 1.
	"Read data using the conditional;  check it is being expanded correctly in the where clause."
	self assert: (session read: GlorpEncyclopediaFeature) size = 3.
	self assert: (session
				read: GlorpEncyclopediaFeature
				where: [:each | each featured notNil]) size = 2
		description: 'ConditionalMapping notNil have expanded to ORed conjunction of its mappings in #rewriteEquality'.
	self assert: (session
				read: GlorpEncyclopediaFeature
				where: [:each | each featured isNil]) size = 1
		description: 'ConditionalMapping isNil should have expanded to ANDed conjunction of its mappings in #rewriteEquality'.
]

{ #category : #running }
GlorpConditionalMappingDBTest >> testWriteAndRead [
	"Write both cases and neither for a conditional, then read all."

	| readFeatures |
	self writeExampleEncycFeaturesOneMapOneInlineOneNil.
	readFeatures := session read: GlorpEncyclopediaFeature orderBy: [:each | each encyclopedia id].
	self assert: (readFeatures collect: [:each | each featuredEntryText]) =
		#('There are many different computer programming languages. The best one is Smalltalk.'	"one-one mapping"
		nil					"no text in either mapping"
		'Silence is Golden').		"short text held in the inline mapping"
]

{ #category : #data }
GlorpConditionalMappingDBTest >> writeExampleEncycFeaturesOneMapOneInlineOneNil [
	| encycFeatures stBestEntry |
	encycFeatures := session system exampleEncyclopediaFeatures.
	session transact: [session register: encycFeatures].
	self assert: (session read: GlorpEncyclopediaFeature) size = encycFeatures size.
	session reset.
	self assert: (session
				read: GlorpEncyclopediaFeature
				where: [:each | each featuredEntryID notNil]) isEmpty.
	self assert: (session
				read: GlorpEncyclopediaFeature
				where: [:each | each featuredEntryString notNil]) isEmpty.
	session reset.
	"Write data using the conditional mapping"
	session transact:
		[encycFeatures := session read: GlorpEncyclopediaFeature orderBy: [:each | each encyclopedia id].
		stBestEntry := session readOneOf: GlorpEncyclopediaEntry where: [:each | each id = 'two'].
		encycFeatures first featured: stBestEntry.
		encycFeatures last featuredEntryText: 'Silence is Golden'.
		encycFeatures].
	session reset.
]
