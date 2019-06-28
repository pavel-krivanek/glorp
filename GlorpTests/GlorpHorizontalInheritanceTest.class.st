Class {
	#name : #GlorpHorizontalInheritanceTest,
	#superclass : #GlorpTestCase,
	#instVars : [
		'session'
	],
	#category : #'GlorpTests-GlorpDBTests'
}

{ #category : #resources }
GlorpHorizontalInheritanceTest class >> resources [
	^Array with: GlorpDatabaseLoginResource with: GlorpDemoTablePopulatorResource with: GlorpSessionResource
]

{ #category : #'VisualWorks metadata' }
GlorpHorizontalInheritanceTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #support }
GlorpHorizontalInheritanceTest >> setUp [
	super setUp.
	session := GlorpSessionResource current newSession.
	session system: (GlorpInheritanceDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database).
	session beginTransaction.
]

{ #category : #support }
GlorpHorizontalInheritanceTest >> tearDown [
	session rollbackTransaction.
	super tearDown.
	session reset.
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testClassSelection [

	| classes |
	classes := (session system descriptorFor: GlorpInventoryItem) classesRequiringIndependentQueries collect: [:each | each name ].
	self assert: classes size = 3.
	#(#GlorpNonperishableItem #GlorpPerishableItem #GlorpUnassembledItem) do: [:name |
		self assert: (classes includes: name) ].

	classes := (session system descriptorFor: GlorpPerishableItem) classesRequiringIndependentQueries collect: [:each | each name ].
	self assert: classes size = 1.
	#(#GlorpPerishableItem) do: [:name |
		self assert: (classes includes: name) ].

	classes := (session system descriptorFor: GlorpNonperishableItem) classesRequiringIndependentQueries collect: [:each | each name ].
	self assert: classes size = 2.
	#(#GlorpNonperishableItem #GlorpUnassembledItem) do: [:name |
		self assert: (classes includes: name)].
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testDirectQuery [

	| items query item |
	self writeTestHarness.
	query := Query read: GlorpInventoryItem
				where: [:each | each name = 'TV'].
	items := session execute: query.
	self assert: items size = 1.
	self assert: (items select: [:emp | emp isMemberOf: GlorpNonperishableItem]) size = 1.

	session reset.
	items := session read: GlorpInventoryItem
				where: [:each | each name = 'bicycle'].
	self assert: items size = 1.
	self assert: (items select: [:emp | emp isMemberOf: GlorpUnassembledItem]) size = 1.

	session reset.
	items := session read: GlorpPerishableItem
				where: [:each | each name = 'bicycle'].
	self assert: items size = 0.

	session reset.
	item := session readOneOf: GlorpPerishableItem
		where: [:each | each name = 'bicycle'].
	self assert: item isNil.
	item := session readOneOf: GlorpInventoryItem
		where: [:each | each name = 'something that does not exist'].
	self assert: item isNil.
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testDirectSingleQueryForSubclasses [

	| items query |
	self writeTestHarness.
	(session system descriptorFor: GlorpInventoryItem) typeResolver useSingleQueryIfPossible: true.
	query := Query read: GlorpInventoryItem
				where: [:each | each name = 'TV'].
	items := session execute: query.
	self assert: items size = 1.
	self assert: (items select: [:emp | emp isMemberOf: GlorpNonperishableItem]) size = 1.

	session reset.
	items := session read: GlorpInventoryItem
				where: [:each | each name = 'bicycle'].
	self assert: items size = 1.
	self assert: (items select: [:emp | emp isMemberOf: GlorpUnassembledItem]) size = 1.

	session reset.
	items := session read: GlorpPerishableItem
				where: [:each | each name = 'bicycle'].
	self assert: items size = 0.
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testDirectSingleQueryForSubclassesNoWhereClause [

	| items query normalResult filtered |
	self writeTestHarness.
	(session system descriptorFor: GlorpInventoryItem) typeResolver useSingleQueryIfPossible: true.
	query := Query read: GlorpInventoryItem.
	items := session execute: query.
	self assert: items size = 7.
	GlorpInventoryItem allSubclasses do: [:each |
		normalResult := session read: each.
		filtered := items select: [:other | other isKindOf: each].
		self assert: normalResult size = filtered size].
]

{ #category : #'tests - tags' }
GlorpHorizontalInheritanceTest >> testForwardLookup [
	| image |
	self writeTestHarnessForTags.
	image := session
				readOneOf: GlorpImage
				where: [:each | each location = 'testlocation'].
	self assert: image tags size = 2.
	self assert: (image tags contains: [:tag| tag key = 'first']).
	self assert: (image tags contains: [:tag| tag key = 'second']).
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testNilVariableJoin [
	| warehouse |
	self writeTestHarness.
	warehouse := session readOneOf: GlorpWarehouse
				where: [:each | each address = '123 Some Ave.'].
	session beginUnitOfWork.
	session register: warehouse.
	warehouse currentItem: nil.
	session commitUnitOfWork.
	session reset.
	warehouse := session readOneOf: GlorpWarehouse
				where: [:each | each address = '123 Some Ave.'].
	self assert: warehouse currentItem isNil
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testOrderBy [
	"We can't use database-level ordering in horizontal inheritance because it does multiple queries. We could, I suppose, sort after the fact, but we don't right now"

	| items query |
	query := Query read: GlorpInventoryItem
				where: [:each | each id <= 4].
	query orderBy: #name.
	self should: [items := session execute: query] raise: Dialect error.
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testReadNonAbstractPolymorphic [
	"This test excercises a problem that existed with MappingExpression caching its mapping
	and which was then copied to the newly created MappingExpressions for subclasses.
	This isn't a problem when reading from an abstract class since there are no mappings to cache."

	| wagon |
	
	self writeTestHarness.
	wagon := session readOneOf: GlorpNonperishableItem where: [:each | each name = 'wagon'].
	self should: [wagon serialNumber = 99958]
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testReadRelationship [
	| warehouse |
	
	self writeTestHarness.
	warehouse := session readOneOf: GlorpWarehouse
				where: [:each | each address = '123 Some Ave.'].
	self assert: warehouse address = '123 Some Ave.'.
	self assert: warehouse currentItem name = 'squash'.
	self assert: (warehouse items collect: [:each | each name]) asSortedCollection asArray = #('apples' 'bicycle' 'fridge').
]

{ #category : #tests }
GlorpHorizontalInheritanceTest >> testReadRelationshipSingleQuery [
	| warehouse |

	(session system descriptorFor: GlorpInventoryItem) typeResolver useSingleQueryIfPossible: true.	
	self writeTestHarness.
	warehouse := session readOneOf: GlorpWarehouse
				where: [:each | each address = '123 Some Ave.'].
	self assert: warehouse address = '123 Some Ave.'.
	self assert: warehouse currentItem name = 'squash'.
	self assert: (warehouse items collect: [:each | each name]) asSortedCollection asArray = #('apples' 'bicycle' 'fridge').
]

{ #category : #'tests - reviews' }
GlorpHorizontalInheritanceTest >> testReadReviews [
	"Just read the class and verify we got the numbers the test hardness wrote."

	| reviews |
	self writeTestHarnessForPictureReviews.
	reviews := session read: GlorpPictureReview.
	self assert: reviews size = 4.
	(reviews glorpGroupedBy: [:each | each picture yourself class]) do:
		[:each | self assert: each size = 2].
]

{ #category : #'tests - reviews' }
GlorpHorizontalInheritanceTest >> testReadReviewsOfOnePortrait [
	"Just read a portrait and verify we got the numbers the test hardness wrote."

	| reviews portrait query |
	self writeTestHarnessForPictureReviews.
	portrait := session
		readOneOf: GlorpPortrait
		where: [:e | e subjectFullName = 'TestSomeone'].
	query := Query
		read: GlorpPictureReview
		where: [:each | each picture = portrait].
	query useANSIJoins: false.
	reviews := session execute: query.
	self assert: reviews size = 2.

"This fails and should be looked at.  The LHS thinks it is a GlorpTaggableObject, so complains it has no primaryKey.  The right side knows it is a GlorpPortrait subclass with primary key.
session read: GlorpPictureReview where:
		[:each || q |
		q := Query readOneOf: GlorpPortrait where:
			[:e | e subjectFullName = 'TestSomeone'].
		each picture = q].

The Schema is
	GlorpTaggableObject -* PictureReview
		Portrait
		Image
Either the ID's sequence must be shared across all subclasses of GlorpTaggableObject or PictureReview must hold the taggable objects subclass-specific key as well as its ID if it is to link to the taggable object subclass."
]

{ #category : #'tests - tags' }
GlorpHorizontalInheritanceTest >> testReverseLookup [
	| image |
	self writeTestHarnessForTags.
	image := session
				readOneOf: GlorpImage
				where: [:each | each tags anySatisfy: [:tag| tag key = 'third']].
	self assert: image tags size = 2.
	self assert: (image tags contains: [:tag| tag key = 'first'])not.
	self assert: (image tags contains: [:tag| tag key = 'second']).
]

{ #category : #'tests - tags' }
GlorpHorizontalInheritanceTest >> testTagObjectLookup [
	| image |
	self writeTestHarnessForTags.
	image := session
				readOneOf: GlorpTaggableObject
				where: [:each | each tags
						anySatisfy: [:tag | tag key = 'third']].
	self assert: image tags size = 2.
	self assert: (image tags
			contains: [:tag | tag key = 'first']) not.
	self
		assert: (image tags
				contains: [:tag | tag key = 'second'])
]

{ #category : #support }
GlorpHorizontalInheritanceTest >> writeTestHarness [

	| squash apples fridge bicycle warehouse |
	session inUnitOfWorkDo: [
	session register: (squash := GlorpPerishableItem new id: 1; name: 'squash'; age: 10; yourself).
	session register: (GlorpPerishableItem new id: 2; name: 'zucchini'; age: 14; yourself).
	session register: (apples := GlorpPerishableItem new id: 3; name: 'apples'; age: 4; yourself).
	session register: (GlorpNonperishableItem new id: 4; name: 'TV'; serialNumber: 56893; yourself).
	session register: (fridge := GlorpNonperishableItem new id: 5; name: 'fridge'; serialNumber: 12345; yourself).
	session register: (bicycle := GlorpUnassembledItem new id: 6; name: 'bicycle'; serialNumber: 83754; assemblyCost: 100; yourself).
	session register: (GlorpUnassembledItem new id: 7; name: 'wagon'; serialNumber: 99958; assemblyCost: 20; yourself).
	warehouse := GlorpWarehouse new.
	warehouse address: '123 Some Ave.'.
	warehouse currentItem: squash.
	warehouse items: (Array with: apples with: fridge with: bicycle).
	session register: warehouse].
	session reset.
]

{ #category : #support }
GlorpHorizontalInheritanceTest >> writeTestHarnessForPictureReviews [
	| image1 portrait2 rev1 rev2 rev3 rev4 |
	session inUnitOfWorkDo:
		[image1 := GlorpImage new location: 'testlocation'.
		session register: image1.
		portrait2 := GlorpPortrait new id: -1; subjectFullName: 'TestSomeone'.
		session register: portrait2.

		rev1 := GlorpPictureReview new sequence: 1; picture: image1.
		rev2 := GlorpPictureReview new sequence: 2; picture: image1.
		rev3 := GlorpPictureReview new sequence: 1; picture: portrait2.
		rev4 := GlorpPictureReview new sequence: 2; picture: portrait2.

		session register: rev1.
		session register: rev2.
		session register: rev3.
		session register: rev4].
	session reset.
]

{ #category : #support }
GlorpHorizontalInheritanceTest >> writeTestHarnessForTags [

	| tag1 tag2 tag3 image1 image2 |
	session inUnitOfWorkDo: [
		tag1 := GlorpTag new label: 'First'; generateKeyFromLabel.
		tag2 := GlorpTag new label: 'Second'; generateKeyFromLabel.
		tag3 := GlorpTag new label: 'Third'; generateKeyFromLabel.

		image1 := GlorpImage new location: 'testlocation'.
		session register: image1.
	
		image1 tags add: tag1.
		image1 tags add: tag2.
	
		image2 := GlorpImage new location: 'testlocation2'.
		session register: image2.
	
		image2 tags add: tag2.
		image2 tags add: tag3].
	session reset.
]
