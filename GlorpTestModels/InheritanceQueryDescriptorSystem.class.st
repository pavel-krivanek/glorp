"
The abstract class Station and its concrete subclasses CustomerStation and FeederStation are each represented in itheir own table.  The tables for the concrete subclasses include a link to the table of the abstract superclass.  (Because this descriptor system exists solely for test purposes, neither the superclass nor the subclass tables have any other columns.)

Stations are connected by the successor relation.
"
Class {
	#name : #InheritanceQueryDescriptorSystem,
	#superclass : #GlorpTestDescriptorSystem,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
InheritanceQueryDescriptorSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #classes }
InheritanceQueryDescriptorSystem >> classModelForCustomerStation: aClassModel [

	aClassModel newAttributeNamed: #id type: SmallInteger.
	aClassModel newAttributeNamed: #successor collection: Array of: Successor.
]

{ #category : #classes }
InheritanceQueryDescriptorSystem >> classModelForFeederStation: aClassModel [

	aClassModel newAttributeNamed: #id type: SmallInteger.
	aClassModel newAttributeNamed: #successor collection: Array of: Successor.
]

{ #category : #classes }
InheritanceQueryDescriptorSystem >> classModelForStation: aClassModel [

	aClassModel newAttributeNamed: #id type: SmallInteger.
	aClassModel newAttributeNamed: #successor collection: Array of: Successor
]

{ #category : #classes }
InheritanceQueryDescriptorSystem >> classModelForSuccessor: aClassModel [

	aClassModel newAttributeNamed: #id type: SmallInteger.
	aClassModel newAttributeNamed: #successorCustomer type: CustomerStation.
	aClassModel newAttributeNamed: #successorFeeder type: FeederStation.
	aClassModel newAttributeNamed: #station type: Station
]

{ #category : #descriptors }
InheritanceQueryDescriptorSystem >> descriptorForCustomerStation: aDescriptor [
	| stationTable customerTable |
	(self typeResolverFor: Station) register: aDescriptor.
	stationTable := self tableNamed: 'NOTIFIER_STATION'.
	aDescriptor table: stationTable.
	customerTable := self tableNamed: 'NOTIFIER_CUSTOMERSTATION'.
	aDescriptor table: customerTable.
	aDescriptor addMultipleTableJoin:
		(Join
			from: (stationTable fieldNamed: 'ID')
			to: (customerTable fieldNamed: 'STATION')).
	aDescriptor toManyMapping
		attributeName: #successor;
		join: (Join from: (stationTable fieldNamed: 'ID')
					to: ((self tableNamed: 'NOTIFIER_SUCCESSOR') fieldNamed: 'STATION'));
		proxyAction: [:owner :value | value postFetchGlorp].
	aDescriptor directMapping
		from: #id to: (stationTable fieldNamed: 'ID');
		converter: (PluggableDatabaseConverter new
					name: '@yourself|yourself';
					dbToStConverter: [:aValue | aValue yourself];
					stToDbConverter: [:aValue | aValue yourself];
					yourself).
]

{ #category : #descriptors }
InheritanceQueryDescriptorSystem >> descriptorForFeederStation: aDescriptor [
	| stationTable feederTable |
	(self typeResolverFor: Station) register: aDescriptor.
	stationTable := self tableNamed: 'NOTIFIER_STATION'.
	aDescriptor table: stationTable.
	feederTable := self tableNamed: 'NOTIFIER_FEEDERSTATION'.
	aDescriptor table: feederTable.
	aDescriptor addMultipleTableJoin:
		(Join
			from: (stationTable fieldNamed: 'ID')
			to: (feederTable fieldNamed: 'STATION')).
	aDescriptor toManyMapping
		attributeName: #successor;
		join: (Join
				from: (stationTable fieldNamed: 'ID')
				to: ((self tableNamed: 'NOTIFIER_SUCCESSOR') fieldNamed: 'STATION'));
		proxyAction: [:owner :value | value postFetchGlorp].
	aDescriptor directMapping
		from: #id to: (stationTable fieldNamed: 'ID');
		converter: (PluggableDatabaseConverter new
					name: '@yourself|yourself';
					dbToStConverter: [:aValue | aValue yourself];
					stToDbConverter: [:aValue | aValue yourself];
					yourself).
]

{ #category : #descriptors }
InheritanceQueryDescriptorSystem >> descriptorForStation: aDescriptor [
	aDescriptor table: (self tableNamed: 'NOTIFIER_STATION').
	(self typeResolverFor: Station) register: aDescriptor abstract: true.
]

{ #category : #descriptors }
InheritanceQueryDescriptorSystem >> descriptorForSuccessor: aDescriptor [
"The original example from which this test set up came had converter and proxyAction behaviour.  Trivial behaviours - #yourself in the converter and #postFetchGlorp in the proxyActions - have been left in below."

	| table |
	table := self tableNamed: 'NOTIFIER_SUCCESSOR'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #id to: (table fieldNamed: 'ID');
		converter: (PluggableDatabaseConverter new
					name: '@yourself|yourself';
					dbToStConverter: [:aValue | aValue yourself];
					stToDbConverter: [:aValue | aValue yourself];
					yourself).
	aDescriptor oneToOneMapping
		attributeName: #station;	"this relation points at the predecessor"
		join: (Join
				from: ((self tableNamed: 'NOTIFIER_SUCCESSOR') fieldNamed: 'STATION')
				to: ((self tableNamed: 'NOTIFIER_STATION') fieldNamed: 'ID'));
		proxyAction: [:owner :value | value postFetchGlorp].
	aDescriptor oneToOneMapping
		attributeName: #successorCustomer;	"I can point to a successor customer station ... "
		join: (Join
				from: ((self tableNamed: 'NOTIFIER_SUCCESSOR') fieldNamed: 'NEXTCUSTOMER')
				to: ((self tableNamed: 'NOTIFIER_CUSTOMERSTATION') fieldNamed: 'STATION'));
		proxyAction: [:owner :value | value postFetchGlorp].
	aDescriptor oneToOneMapping
		attributeName: #successorFeeder;	" ... and/or a successor feeder station"
		join: (Join
				from: ((self tableNamed: 'NOTIFIER_SUCCESSOR') fieldNamed: 'NEXTFEEDER')
				to: ((self tableNamed: 'NOTIFIER_FEEDERSTATION') fieldNamed: 'STATION'));
		proxyAction: [:owner :value | value postFetchGlorp].
]

{ #category : #tables }
InheritanceQueryDescriptorSystem >> tableForNOTIFIER_CUSTOMERSTATION: aTable [
	(aTable createFieldNamed: 'STATION' type: platform integer) bePrimaryKey.
	aTable
		addForeignKeyFrom: ((self tableNamed: 'NOTIFIER_CUSTOMERSTATION') fieldNamed: 'STATION')
		to: ((self tableNamed: 'NOTIFIER_STATION') fieldNamed: 'ID').
]

{ #category : #tables }
InheritanceQueryDescriptorSystem >> tableForNOTIFIER_FEEDERSTATION: aTable [
	(aTable createFieldNamed: 'STATION' type: platform integer) bePrimaryKey.
	aTable
		addForeignKeyFrom: ((self tableNamed: 'NOTIFIER_FEEDERSTATION') fieldNamed: 'STATION')
		to: ((self tableNamed: 'NOTIFIER_STATION') fieldNamed: 'ID').
]

{ #category : #tables }
InheritanceQueryDescriptorSystem >> tableForNOTIFIER_STATION: aTable [
	(aTable
		createFieldNamed: 'ID'
		type: platform integer) bePrimaryKey.
]

{ #category : #tables }
InheritanceQueryDescriptorSystem >> tableForNOTIFIER_SUCCESSOR: aTable [
	(aTable createFieldNamed: 'ID' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'NEXTCUSTOMER' type: platform integer.
	aTable createFieldNamed: 'STATION' type: platform integer.
	aTable createFieldNamed: 'NEXTFEEDER' type: platform integer.
	aTable
		addForeignKeyFrom: ((self tableNamed: 'NOTIFIER_SUCCESSOR') fieldNamed: 'NEXTCUSTOMER')
		to: ((self tableNamed: 'NOTIFIER_CUSTOMERSTATION') fieldNamed: 'STATION').
	aTable
		addForeignKeyFrom: ((self tableNamed: 'NOTIFIER_SUCCESSOR') fieldNamed: 'NEXTFEEDER')
		to: ((self tableNamed: 'NOTIFIER_FEEDERSTATION') fieldNamed: 'STATION').
	aTable
		addForeignKeyFrom: ((self tableNamed: 'NOTIFIER_SUCCESSOR') fieldNamed: 'STATION')
		to: ((self tableNamed: 'NOTIFIER_STATION') fieldNamed: 'ID').
]

{ #category : #'type resolvers' }
InheritanceQueryDescriptorSystem >> typeResolverForStation [
	"The abstract class Station and its concrete subclasses CustomerStation and FeederStation are each represented in itheir own table.  The tables for the concrete subclasses include a link to the table of the abstract superclass."

	^HorizontalTypeResolver forRootClass: Station
]
