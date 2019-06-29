"
This is an abstract superclass for all descriptor systems whose tables should be set up as part of the standard GLORP testing process. See GlorpDemoTablePopulatorResource.
"
Class {
	#name : #GlorpTestDescriptorSystem,
	#superclass : #DescriptorSystem,
	#category : #'GlorpTestModels-Glorp'
}

{ #category : #'VisualWorks metadata' }
GlorpTestDescriptorSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #validation }
GlorpTestDescriptorSystem >> initializeRuntimeMappings [
	"(ToBeImproved - see below.)  If this is called, our 'validateDescriptorSystem' class-instance variable has been set to something other than #always.  Use the omit list for cases where not-proxying loops forever or otherwise compromises the descriptor system fundamentally.  If any tests fail merely because their (over-precise?) assertions assume that proxing happens, alter them to (re)enforce proxying or generalise the assertions."

	| descriptorOmitList unproxyClass |
	super initializeRuntimeMappings.
	unproxyClass := Mapping allSubclasses
		detect: [:each | each name == self class rawValidateDescriptorSystem]
		ifNone: [^self].
	"May also need to omit GlorpTravelAgent if tested with OneToOneMapping or EmbeddedValueOneToOneMapping;"
	descriptorOmitList := Array with: GlorpTravelAgency.	"see GlorpEmbeddedMappingDBTest's class comment."
	self allDescriptors do:
		[:eachDescriptor |
		(descriptorOmitList includes: eachDescriptor describedClass) ifFalse:
			[eachDescriptor mappings do:
				[:each | (each isKindOf: unproxyClass) ifTrue:
						[each shouldProxy: false]]]].

"UNDER DEVELOPMENT: this is not tested for all my subclasses or all Mapping's subclasses.

1) It has been exercised by running GlorpTest after sending
	GlorpDemoDescriptorSystem validateDescriptorSystem: #ToManyMapping
(seven tests still fail but can probably be made to pass, and nothing iterates forever).   Not yet exercised cases include
	GlorpDemoDescriptorSystem validateDescriptorSystem: #OneToOneMapping.
	<OtherGlorpTestDescriptorSystemSubclass validateDescriptorSystem: #<MappingSubclass>.
	GlorpTestDescriptorSystem allSubclasses do:
		[:each | each validateDescriptorSystem: #<MappingSubclass>].
In all such cases, add any loop-forevers to the omit list, and enforce proxying of the relevant mappings in tests which must assume it and (temporarily, prior to rewrite) in tests that need not.

2) Is it that a mapping using GlorpVirtualCollection must proxy, or does the need for this indicate an error to fix, e.g.
	GlorpCursoredStream>>newCollectionOfSize:for: (maybe also ReadStream>>newCollectionOfSize:for:)
sends #new: to GlorpVirtualCollection, which DNUs it.  Should we implement
	GlorpVirtualCollection>>new: anInteger
		^self getQuery collectionType new: anInteger
This is effectively what is done in
	FilteringQuery>>collection: aCollection
		aCollection class == GlorpVirtualCollection ifTrue:
			[collectionType := aCollection getQuery collectionType].
Alternatively, #collectionTypeFor: could convert GlorpVirtualCollection to an OrderedCollection or Array, or
	GlorpVirtualCollection>>new:
could just hardcodedly return one of these."
]
