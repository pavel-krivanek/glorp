"
I define two inheitance-using systems, a small one for subclasses of GlorpTaggableObject and a larger one ubclasses of GlorpInventoryItem.
"
Class {
	#name : #GlorpInheritanceDescriptorSystem,
	#superclass : #GlorpTestDescriptorSystem,
	#category : #'GlorpTestModels-GlorpMappings'
}

{ #category : #'VisualWorks metadata' }
GlorpInheritanceDescriptorSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #misc }
GlorpInheritanceDescriptorSystem >> addHourlyRateEmbeddedMappingTo: aDescriptor [
	| table imaginaryEmbeddedTable |
	table   := self tableNamed: 'EMPLOYEE'.
	imaginaryEmbeddedTable := self tableNamed: 'MONEY_IMAGINARY_TABLE'.
	^(aDescriptor newMapping: EmbeddedValueOneToOneMapping)
		attributeName: #hourlyRate;
		referenceClass: GlorpMoney;
		fieldTranslation: (Join new
						addSource: (table fieldNamed: 'HOUR_AMT')
						target: (imaginaryEmbeddedTable fieldNamed: 'AMOUNT');
						addSource: (table fieldNamed: 'HOUR_CURR')
						target: (imaginaryEmbeddedTable fieldNamed: 'CURRENCY'));
		yourself.
]

{ #category : #'initialize-release' }
GlorpInheritanceDescriptorSystem >> allTableNames [

	^#('EMPLOYEE' 'OFFICE' 'PERISHABLE_ITEM' 'NONPERISHABLE_ITEM' 'UNASSEMBLED_ITEM' 'WORKING_STIFF' 'POULTRY' 'TAX' 'WAREHOUSE' 'WAREHOUSE_ITEM_LINK'  'GLORP_IMAGE' 'GLORP_TAG' 'GLORP_TAGS' 'GLORP_PORTRAIT' 'GLORP_PICTURE_REVIEW').
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> classModelForGlorpImage: aClassModel [ 
	aClassModel newAttributeNamed: #id.
	aClassModel newAttributeNamed: #location.
	aClassModel newAttributeNamed: #tags collectionOf: GlorpTag.
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> classModelForGlorpTag: aClassModel [ 
	aClassModel newAttributeNamed: #id.
	aClassModel newAttributeNamed: #key.
	aClassModel newAttributeNamed: #label
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> classModelForGlorpTaggableObject: aClassModel [
]

{ #category : #classes }
GlorpInheritanceDescriptorSystem >> classModelForGlorpWarehouse: aClassModel [
	aClassModel newAttributeNamed: #id.
	aClassModel newAttributeNamed: #address.
	aClassModel newAttributeNamed: #currentItem type: GlorpInventoryItem.
	aClassModel newAttributeNamed: #items collectionOf: GlorpInventoryItem.
]

{ #category : #'initialize-release' }
GlorpInheritanceDescriptorSystem >> constructAllClasses [
	^(super constructAllClasses)
		add: GlorpOffice;
		add: GlorpEmployee;
		add: GlorpManager;
		add: GlorpRegionalManager;
		add: GlorpLineWorker;
		add: GlorpInventoryItem;
		add: GlorpPerishableItem;
		add: GlorpNonperishableItem;
		add: GlorpUnassembledItem;
		add: GlorpWorkingStiff;
		add: GlorpPoultry;
		add: GlorpTax;
		add: GlorpBasicTax;
		add: GlorpSurcharge;
		add: GlorpWarehouse;
		add: GlorpTag;
		add: GlorpTaggableObject;
		add: GlorpImage;
		add: GlorpContractor;	"we need not add GlorpMoney;  see #stealGlorpMoneyFromOtherSystem"
		add: GlorpPortrait;
		add: GlorpPictureReview;
		yourself
]

{ #category : #'initialize-release' }
GlorpInheritanceDescriptorSystem >> constructAllTables [
	"This method usually returns tables, though there seems no need for it to do so."

	super constructAllTables.
	self stealGlorpMoneyFromOtherSystem.
	^tables
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpContractor: aDescriptor [
	"This subclass has an embedded mapping, to test tracing and building of such cases."

	| table |
	table := self tableNamed: 'EMPLOYEE'.
	aDescriptor table: table.
	aDescriptor directMapping from: #id to: (table fieldNamed: 'ID').
	aDescriptor directMapping from: #name to: (table fieldNamed: 'NAME').
	(self typeResolverFor: GlorpEmployee)
		register: aDescriptor
		keyedBy: 'C'
		field: (table fieldNamed: 'EMPLOYEE_TYPE').
	self addHourlyRateEmbeddedMappingTo: aDescriptor.
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpEmployee: aDescriptor [
	"Add the GlorpContractor>>hourlyRate embedded mapping to this superclass conditionally (the condition being the concrete object is a Contractor).  This is a by-hand example of how to handle embedded objects in such classes.  The idea is that Glorp will construct this on the fly, so reading Employees does not omit the hourly rate of Contractors."

	| table hourlyRateConditional typeResolutionField embeddedMapping |
	table := self tableNamed: 'EMPLOYEE'.
	aDescriptor table: table.
	aDescriptor directMapping from: #id to: (table fieldNamed: 'ID').
	aDescriptor directMapping from: #name to: (table fieldNamed: 'NAME').
	typeResolutionField := table fieldNamed: 'EMPLOYEE_TYPE'.
	(self typeResolverFor: GlorpEmployee) register: aDescriptor keyedBy: 'E' field: typeResolutionField.
	"The code below lets GlorpEmployee handle GlorpContractor's embedded mapping."
	hourlyRateConditional := aDescriptor newMapping: ConditionalMapping.
	embeddedMapping := self addHourlyRateEmbeddedMappingTo: hourlyRateConditional.
	hourlyRateConditional 
		forField: typeResolutionField
		attribute: [:object | (self descriptorFor: object class) typeMapping keyedBy]
		if: [:x | x = 'C']
		useMapping: embeddedMapping;
		otherwise: (hourlyRateConditional newMapping: ConstantMapping).
	"We must set the index from GlorpContractor (GlorpEmployee has no such instVar, so attribute validation fails)."
	embeddedMapping attribute privateAndbasicSetInstVarIndex:
		((self descriptorFor: GlorpContractor) mappingForAttributeNamed: #hourlyRate) attribute instVarIndex.
	"Alternatively, we could set useDirectAccess: false and give GlorpEmployee do-nothing #hourlyRate accessors."
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpImage: aDescriptor [ 
	| table |
	table := self tableNamed: 'GLORP_IMAGE'.
	aDescriptor table: table.
	aDescriptor directMapping from: #id to: (table fieldNamed: 'id').
	aDescriptor directMapping from: #location to: (table fieldNamed: 'location').
	aDescriptor manyToManyMapping
		attributeName: #tags;
		referenceClass: GlorpTag;
		join: (Join
				from: (table fieldNamed: 'id')
				to: ((self tableNamed: 'IMAGETAGS') fieldNamed: 'obj_id')).
	(self typeResolverFor: GlorpTaggableObject)
		register: aDescriptor.
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpInventoryItem: aDescriptor [
	(self typeResolverFor: GlorpInventoryItem) register: aDescriptor abstract: true.
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpLineWorker: aDescriptor [
	| table |
	table := self tableNamed: 'EMPLOYEE'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
	(self typeResolverFor: GlorpEmployee) register: aDescriptor keyedBy: 'W' field: (table fieldNamed: 'EMPLOYEE_TYPE').
	aDescriptor addMapping: (DirectMapping from: #productionLine to: (table fieldNamed: 'PRODUCTION_LINE')).
	^aDescriptor
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpManager: aDescriptor [
	| table |
	table := self tableNamed: 'EMPLOYEE'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
	aDescriptor addMapping: (DirectMapping from: #branch to: (table fieldNamed: 'BRANCH')).
	(self typeResolverFor: GlorpEmployee) register: aDescriptor keyedBy: 'M' field: (table fieldNamed: 'EMPLOYEE_TYPE').
	^aDescriptor
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpNonperishableItem: aDescriptor [

	| table |
	table := self tableNamed: 'NONPERISHABLE_ITEM'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
	aDescriptor addMapping: (DirectMapping from: #serialNumber to: (table fieldNamed: 'SERIAL_NUMBER')).
	(self typeResolverFor: GlorpInventoryItem) register: aDescriptor.
	^aDescriptor
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpOffice: aDescriptor [
	| table |
	table := self tableNamed: 'OFFICE'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (OneToManyMapping new
			attributeName: #employees;
			referenceClass: GlorpEmployee;
			join: (Join 
				from: (table fieldNamed: 'ID')
				to: ((self tableNamed: 'EMPLOYEE') fieldNamed: 'OFFICE_ID'))).
	aDescriptor addMapping: (OneToOneMapping new
		attributeName: #employeeOfMonth;
		referenceClass: GlorpEmployee;
		join: (Join
				from: (table fieldNamed: 'EMPLOYEE_OF_MONTH')
				to: ((self tableNamed: 'EMPLOYEE') fieldNamed: 'ID'))).
	^aDescriptor
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpPerishableItem: aDescriptor [

	| table |
	table := self tableNamed: 'PERISHABLE_ITEM'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
	aDescriptor addMapping: (DirectMapping from: #age to: (table fieldNamed: 'AGE')).
	(self typeResolverFor: GlorpInventoryItem) register: aDescriptor.
	^aDescriptor
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpPictureReview: aDescriptor [
	aDescriptor table: (self tableNamed: 'GLORP_PICTURE_REVIEW').
	aDescriptor oneToOneMapping
		attributeName: #picture;
		referenceClass: GlorpTaggableObject;
		join: (self
				polymorphicJoinFromField: (aDescriptor table fieldNamed: 'pictureID')
				toAll: GlorpTaggableObject subclasses).
	(aDescriptor directMapping from: #pictureID to: (aDescriptor table fieldNamed: 'pictureID')) beForPseudoVariable.
	aDescriptor directMapping from: #sequence to: (aDescriptor table fieldNamed: 'sequence').
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpPortrait: aDescriptor [ 
	| table |
	table := self tableNamed: 'GLORP_PORTRAIT'.
	aDescriptor table: table.
	aDescriptor directMapping from: #id to: (table fieldNamed: 'id').
	aDescriptor directMapping from: #subjectFullName to: (table fieldNamed: 'subjectFullName').
	aDescriptor manyToManyMapping
		attributeName: #tags;
		referenceClass: GlorpTag;
		join: (Join
				from: (table fieldNamed: 'id')
				to: ((self tableNamed: 'IMAGETAGS') fieldNamed: 'obj_id')).
	(self typeResolverFor: GlorpTaggableObject)
		register: aDescriptor.
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpPoultry: aDescriptor [
	"Poultry does not participate in the InventoryItem heirarchy (ie it will not be retrieved when asking for an InventoryItem)"
	| table |
	table := self tableNamed: 'POULTRY'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
	aDescriptor addMapping: (DirectMapping from: #age to: (table fieldNamed: 'AGE')).
	aDescriptor addMapping: (DirectMapping from: #featherColor to: (table fieldNamed: 'FEATHER_COLOR')).
	^aDescriptor
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpRegionalManager: aDescriptor [
	| table |
	table := self tableNamed: 'EMPLOYEE'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
	aDescriptor addMapping: (DirectMapping from: #branch to: (table fieldNamed: 'BRANCH')).
	aDescriptor addMapping: (DirectMapping from: #region to: (table fieldNamed: 'REGION')).
	(self typeResolverFor: GlorpEmployee) register: aDescriptor keyedBy: 'R' field: (table fieldNamed: 'EMPLOYEE_TYPE').
	^aDescriptor
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpTag: aDescriptor [ 
	| table |
	table := self tableNamed: 'GLORP_TAG'.
	aDescriptor table: table.
	(aDescriptor newMapping: DirectMapping)
		from: #id
		to: (table fieldNamed: 'id').
	(aDescriptor newMapping: DirectMapping)
		from: #key
		to: (table fieldNamed: 'key').
	(aDescriptor newMapping: DirectMapping)
		from: #label
		to: (table fieldNamed: 'label').
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpTaggableObject: aDescriptor [
	"We use one of our subtables to get a stand-in for the VariableJoin's target field.  As the VariableJoin's sourceField is the same for all targets, it does not matter which one we pick.  A sane query will replace the targetField with the sourceField in #condensePrimaryKeyComparison."

	| firstSubclassField |
	firstSubclassField := (self tableNamed: 'GLORP_IMAGE')  fieldNamed: 'id'.
	aDescriptor table: DatabaseTable new.
	aDescriptor table fields add: firstSubclassField.
	aDescriptor table addAsPrimaryKeyField: firstSubclassField.
	(aDescriptor directMapping from: #id to: firstSubclassField) beForPseudoVariable.
	"The next line is the only real part of this descriptor."
	(self typeResolverFor: GlorpTaggableObject)
		register: aDescriptor
		abstract: true.
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpUnassembledItem: aDescriptor [

	| table |
	table := self tableNamed: 'UNASSEMBLED_ITEM'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
	aDescriptor addMapping: (DirectMapping from: #serialNumber to: (table fieldNamed: 'SERIAL_NUMBER')).
	aDescriptor addMapping: (DirectMapping from: #assemblyCost to: (table fieldNamed: 'ASSEM_COST')).
	(self typeResolverFor: GlorpInventoryItem) register: aDescriptor.
	^aDescriptor
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpWarehouse: aDescriptor [

	| table linkTable |
	table := self tableNamed: 'WAREHOUSE'.
	aDescriptor table: table.
	aDescriptor directMapping from: #id to: (table fieldNamed: 'ID').
	aDescriptor directMapping from: #address to: (table fieldNamed: 'ADDRESS').
	aDescriptor oneToOneMapping
		attributeName: #currentItem;
		join: (self
				polymorphicJoinFromField: (table fieldNamed: 'CURRENT_ITEM_ID')
				toAll: (Array with: GlorpNonperishableItem with: GlorpPerishableItem with: GlorpUnassembledItem)).
	linkTable := self tableNamed: 'WAREHOUSE_ITEM_LINK'.
	(aDescriptor newMapping: ManyToManyMapping)
		attributeName: #items;
		join: (Join from: (table fieldNamed: 'ID')
					to: (linkTable fieldNamed: 'WAREHOUSE_ID'));
		reverseJoin: (self
					polymorphicJoinFromField: (linkTable fieldNamed: 'ITEM_ID')
					toAll: (Array with: GlorpNonperishableItem with: GlorpPerishableItem with: GlorpUnassembledItem)).
	^aDescriptor
]

{ #category : #'descriptors/employees' }
GlorpInheritanceDescriptorSystem >> descriptorForGlorpWorkingStiff: aDescriptor [
	"Working stiff does not participate in the Employee type mapping scheme (it uses its own table)"
	| table |
	table := self tableNamed: 'WORKING_STIFF'.
	aDescriptor table: table.
	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
	^aDescriptor
]

{ #category : #utility }
GlorpInheritanceDescriptorSystem >> polymorphicJoinFromField: aField toAll: concreteSubClasses [
	"Return a polymorphic join to the subclasses from the given field.  This assumes the target classes all have an ID field in their tables."

	| polymorphicJoin |
	polymorphicJoin := VariableJoin new.
	concreteSubClasses do: 
		[:eachClass |
		polymorphicJoin
			addJoinFor: eachClass
			as: (Join
					from: aField
					to: ((self descriptorFor: eachClass) primaryTable fieldNamed: 'ID'))].
	^polymorphicJoin
]

{ #category : #'initialize-release' }
GlorpInheritanceDescriptorSystem >> stealGlorpMoneyFromOtherSystem [
	"We want GlorpMoney for our embedded mapping test, so we steal its initialized table, class and descriptor (in that order) from its owning descriptor system, switching them to point to our system as needed."

	| glorpMoneySystem |
	glorpMoneySystem := GlorpDemoDescriptorSystem new.
	glorpMoneySystem platform: self platform.
	tables
		at: 'MONEY_IMAGINARY_TABLE'
		ifAbsentPut: [glorpMoneySystem tableNamed: 'MONEY_IMAGINARY_TABLE'].
	classModels
		at: GlorpMoney
		ifAbsentPut: [(glorpMoneySystem classModelFor: GlorpMoney) system: self].
	descriptors
		at: GlorpMoney
		ifAbsentPut: [(glorpMoneySystem descriptorFor: GlorpMoney) system: self].
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForEMPLOYEE: aTable [
	| officeId |
	aTable name: 'EMPLOYEE'.
	(aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
	aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
	officeId := aTable createFieldNamed: 'OFFICE_ID' type: platform int4.
	aTable addForeignKeyFrom: officeId
		to: ((self tableNamed: 'OFFICE') fieldNamed: 'ID').
	aTable createFieldNamed: 'EMPLOYEE_TYPE' type: (platform varChar: 20).
	aTable createFieldNamed: 'BRANCH' type: (platform varChar: 20).
	aTable createFieldNamed: 'REGION' type: (platform varChar: 20).
	aTable createFieldNamed: 'PRODUCTION_LINE' type: (platform varChar: 20).
	"The following fields are only used by GlorpContractor."
	aTable createFieldNamed: 'HOUR_AMT' type: platform int4.
	aTable createFieldNamed: 'HOUR_CURR' type: (platform varChar: 5).
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> tableForGLORP_IMAGE: aTable [ 
	(aTable createFieldNamed: 'id' type: platform sequence) bePrimaryKey.
	aTable
		createFieldNamed: 'location'
		type: (platform varChar: 250).
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> tableForGLORP_PICTURE_REVIEW: aTable [
	| pictureField fkConstraint |
	pictureField := (aTable createFieldNamed: 'pictureID' type: platform integer) bePrimaryKey.
	(aTable createFieldNamed: 'sequence' type: platform integer) bePrimaryKey.
	fkConstraint := aTable
		addForeignKeyFrom: pictureField
		to: ((self tableNamed: 'GLORP_IMAGE') fieldNamed: 'ID').
	fkConstraint shouldCreateInDatabase: false.
	fkConstraint := aTable
		addForeignKeyFrom: pictureField
		to: ((self tableNamed: 'GLORP_PORTRAIT') fieldNamed: 'ID').
	fkConstraint shouldCreateInDatabase: false.
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> tableForGLORP_PORTRAIT: aTable [
	"We could use the same sequence for portrait as for image in most cases (to avoid clashing sequence numbers see BasicTypeResolver>>validate), but not in SQLServer, SQLite and MySQL each of which usesIdentityColumns. In that case, the returned ids are governed by each table not by the sequence, of which the database is unaware, so there is duplication of ids."

	(aTable createFieldNamed: 'id' type: platform integer) bePrimaryKey.
	aTable
		createFieldNamed: 'subjectFullName'
		type: (platform varChar: 250).
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> tableForGLORP_TAG: aTable [ 
	(aTable createFieldNamed: 'id' type: platform sequence) bePrimaryKey.
	aTable
		createFieldNamed: 'key'
		type: (platform varChar: 200).
	aTable
		createFieldNamed: 'label'
		type: (platform varChar: 200).
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> tableForGLORP_TAGS: aTable [ 
	| tagKey tagObjKey |
	tagKey := aTable createFieldNamed: 'tag_id' type: platform int4.
	aTable
		addForeignKeyFrom: tagKey
		to: ((self tableNamed: 'GLORP_TAG')
				fieldNamed: 'id').
	tagObjKey := aTable createFieldNamed: 'obj_id' type: platform int4.
	aTable
		addForeignKeyFrom: tagObjKey
		to: ((self tableNamed: 'GLORP_IMAGE')
				fieldNamed: 'id')
]

{ #category : #'descriptors/images' }
GlorpInheritanceDescriptorSystem >> tableForIMAGETAGS: aTable [ 
	| tagKey tagObjKey |
	tagKey := aTable createFieldNamed: 'tag_id' type: platform int4.
	aTable
		addForeignKeyFrom: tagKey
		to: ((self tableNamed: 'GLORP_TAG')
				fieldNamed: 'id').
	tagObjKey := aTable createFieldNamed: 'obj_id' type: platform int4.
	aTable
		addForeignKeyFrom: tagObjKey
		to: ((self tableNamed: 'GLORP_IMAGE')
				fieldNamed: 'id')
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForNONPERISHABLE_ITEM: aTable [
	aTable name: 'NONPERISHABLE_ITEM'.
	(aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
	aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
	aTable createFieldNamed: 'SERIAL_NUMBER' type: platform int4.
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForOFFICE: aTable [
	| empOfMonth |
	aTable name: 'OFFICE'.
	(aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
	empOfMonth := aTable createFieldNamed: 'EMPLOYEE_OF_MONTH' type: platform int4.
	"Cheat by removing this, because it makes a cycle that we can't really handle yet"
	"aTable addForeignKeyFrom: empOfMonth
		to: ((self tableNamed: 'EMPLOYEE') fieldNamed: 'ID')."
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForPERISHABLE_ITEM: aTable [
	aTable name: 'PERISHABLE_ITEM'.
	(aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
	aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
	aTable createFieldNamed: 'AGE' type: platform int4.
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForPOULTRY: aTable [
	aTable name: 'POULTRY'.
	(aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
	aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
	aTable createFieldNamed: 'AGE' type: platform int4.
	aTable createFieldNamed: 'FEATHER_COLOR' type: (platform varChar: 20).
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForTAX: aTable [
	| superTaxId |
	(aTable createFieldNamed: 'ID' type: platform serial) bePrimaryKey.
	aTable createFieldNamed: 'NAME' type: platform text.
	aTable createFieldNamed: 'TYPE' type: (platform varchar: 16).
	superTaxId := aTable createFieldNamed: 'TAX_ID' type: platform int4.
	aTable addForeignKeyFrom: superTaxId to: ((self tableNamed: 'TAX') fieldNamed: 'ID').
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForUNASSEMBLED_ITEM: aTable [

	aTable name: 'UNASSEMBLED_ITEM'.
	(aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
	aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
	aTable createFieldNamed: 'SERIAL_NUMBER' type: platform int4.
	aTable createFieldNamed: 'ASSEM_COST' type: platform int4.
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForWAREHOUSE: aTable [

	(aTable createFieldNamed: 'ID' type: platform serial) bePrimaryKey.
	aTable createFieldNamed: 'ADDRESS' type: (platform varChar: 50).
	aTable createFieldNamed: 'CURRENT_ITEM_ID' type: platform int4.
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForWAREHOUSE_ITEM_LINK: aTable [

	| warehouseId |
	warehouseId := aTable createFieldNamed: 'WAREHOUSE_ID' type: platform int4.
	aTable addForeignKeyFrom: warehouseId to: ((self tableNamed: 'WAREHOUSE') fieldNamed: 'ID').
	aTable createFieldNamed: 'ITEM_ID' type: platform int4.
]

{ #category : #tables }
GlorpInheritanceDescriptorSystem >> tableForWORKING_STIFF: aTable [
	aTable name: 'WORKING_STIFF'.
	(aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
	aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
]

{ #category : #'type resolvers' }
GlorpInheritanceDescriptorSystem >> typeResolverForGlorpInventoryItem [
	^HorizontalTypeResolver forRootClass: GlorpInventoryItem.
]

{ #category : #'type resolvers' }
GlorpInheritanceDescriptorSystem >> typeResolverForGlorpTaggableObject [
   ^HorizontalTypeResolver forRootClass: GlorpTaggableObject
]
