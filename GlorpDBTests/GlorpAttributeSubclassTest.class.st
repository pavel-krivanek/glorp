"
Subclasses of GlorpAttributeModel get tested here.
"
Class {
	#name : #GlorpAttributeSubclassTest,
	#superclass : #GlorpSessionBasedTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpAttributeSubclassTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #running }
GlorpAttributeSubclassTest >> setUp [
	super setUp.
	session system: (GlorpAttributeSubclassSystem forPlatform: session platform).
	session beginTransaction.
]

{ #category : #running }
GlorpAttributeSubclassTest >> tearDown [
	session rollbackTransaction.
	super tearDown.
]

{ #category : #running }
GlorpAttributeSubclassTest >> testAlsoFetchOuterJoin [
	"Since a GlorpBlockModel manages the allocation of space for names longer than 50 chars, this test exercises GlorpBlockModel as well as GlorpSubsequenceModel (see GlorpAttributeSubclassSystem>>descriptorForGlorpTravelFile: which should not be confused with the method of the same name in GlorpOrderedLinkDescriptorSystem)."

	

	self writeChunckedStringsCheckReadIn:
		[| query |
		query := Query read: GlorpTravelFile.
		query orderBy: [:each | each nameLength].
		query alsoFetch: [:each | each nameChunks beOuterJoin].
		session execute: query].
]

{ #category : #running }
GlorpAttributeSubclassTest >> testReadChunckedString [
	"Since a GlorpBlockModel manages the allocation of space for names longer than 50 chars, this test exercises GlorpBlockModel as well as GlorpSubsequenceModel (see GlorpAttributeSubclassSystem>>descriptorForGlorpTravelFile: which should not be confused with the method of the same name in GlorpOrderedLinkDescriptorSystem)."

	self writeChunckedStringsCheckReadIn:
		[session read: GlorpTravelFile orderBy: [:each | each nameLength]].
]

{ #category : #running }
GlorpAttributeSubclassTest >> testRelationshipOuterJoin [
	"Since a GlorpBlockModel manages the allocation of space for names longer than 50 chars, this test exercises GlorpBlockModel as well as GlorpSubsequenceModel (see GlorpAttributeSubclassSystem>>descriptorForGlorpTravelFile: which should not be confused with the method of the same name in GlorpOrderedLinkDescriptorSystem)."

	
	| mapping |
	mapping := (session system descriptorFor: GlorpTravelFile) mappingForAttributeNamed: #nameChunks.
	self deny: mapping join isOuterJoin.
	mapping join beOuterJoin.
	self writeChunckedStringsCheckReadIn:
		[session read: GlorpTravelFile orderBy: [:each | each nameLength]].
	self assert: mapping join isOuterJoin.
	mapping join privateBeOuterJoin: nil.
]

{ #category : #running }
GlorpAttributeSubclassTest >> writeChunckedStringsCheckReadIn: aBlock [
	"Since a GlorpBlockModel manages the allocation of space for names longer than 50 chars, this test exercises GlorpBlockModel as well as GlorpSubsequenceModel (see GlorpAttributeSubclassSystem>>descriptorForGlorpTravelFile: which should not be confused with the method of the same name in GlorpOrderedLinkDescriptorSystem)."

	| shortString string50 stringOver50 string150 stringOver450 filesFromDB |
	self assert: 50 > (shortString := 'We need a short name to test') size.
	self assert: 50 = (string50 := 'We need a 50-chars name to test chunks effectively') size.
	self assert: 50 < (stringOver50 := 'We also need a name that is quite a bit longer than 50 chars to test the overflow case') size.
	self assert: 150 = (string150 := 'And we require a name that is exactly 150 characters long so that it will cause one overflow and so will test the to-manyness of a DirectToManyMapping') size.
	self assert: 450 < (stringOver450 := 'And if anything is more when all is most, it is indubitably clear that an effective test of this new facility of mapping strings to inline + overflow, of which I am inordinately proud, will require its being demonstrated on an unusually long filename such as will cause several overflows - shall we say five or so? - in order to stun viewers with its reliability and my coding skills, and incidentally verify that something I wrote actually works for once. :-)') size.
	session inUnitOfWorkDo:
		[session register: (GlorpTravelFile new name: shortString).
		session register: (GlorpTravelFile new name: string50).
		session register: (GlorpTravelFile new name: stringOver50).
		session register: (GlorpTravelFile new name: string150).
		session register: (GlorpTravelFile new name: stringOver450)].
	session reset.
	filesFromDB := aBlock value.
	self assert: filesFromDB size = 5.
	self assert: (filesFromDB at: 1) name = shortString.
	self assert: (filesFromDB at: 2) name = string50.
	self assert: (filesFromDB at: 3) name = stringOver50.
	self assert: (filesFromDB at: 4) name = string150.
	self assert: (filesFromDB at: 5) name = stringOver450.
]
