"
My model consists of classes ClassA, ClassB and so on, with attributes #attrAClassA, #attrBClassA, ..., #attrAClassB, #attrBClassB, ..., etc. (hence my name).  I am used by tests that illustrate some Glorp issues unearthed in live use and fixed by various ARs.
"
Class {
	#name : #AlphaDescriptorSystem,
	#superclass : #GlorpTestDescriptorSystem,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
AlphaDescriptorSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
AlphaDescriptorSystem >> allTableNames [
	^#('TBLA' 'TBLB' 'TBLC' 'TBLE' 'TBLH' 'TBLH1' 'TBLI' 'TBLJ' 'TBLK'  'TBLL' 'TBLM' 'TBLO' 'TBLQ')
]

{ #category : #accessing }
AlphaDescriptorSystem >> attrsOfClassA [
	^#(#attrAClassA #attrBClassA #attrCClassA #attrDClassA)
]

{ #category : #accessing }
AlphaDescriptorSystem >> attrsOfClassH [

	^#(#attrAClassH #attrBClassH #attrCClassH #attrDClassH).
]

{ #category : #accessing }
AlphaDescriptorSystem >> attrsOfClassL [

	^#(#attrAClassL #attrBClassL #attrCClassL).
]

{ #category : #accessing }
AlphaDescriptorSystem >> attrsOfClassO [

	^#(#attrAClassO #attrBClassO #attrCClassO #attrDClassO).
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassA: aClassModel [
	self attrsOfClassA do: [:eachAttrName | aClassModel newAttributeNamed: eachAttrName].
	aClassModel newAttributeNamed: #attrEClassA.
	aClassModel newAttributeNamed: #attrFClassA collectionOf: ClassB.
	aClassModel newAttributeNamed: #attrGClassA collectionOf: ClassI.
	aClassModel newAttributeNamed: #attrHClassA type: Boolean.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassB: aClassModel [
	aClassModel newAttributeNamed: #attrAClassB.
	aClassModel newAttributeNamed: #attrBClassB type: ClassA.
	aClassModel newAttributeNamed: #attrCClassB.
	aClassModel newAttributeNamed: #attrDClassB type: ClassC.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassC: aClassModel [
	aClassModel newAttributeNamed: #attrAClassC.
	aClassModel newAttributeNamed: #attrBClassC.
]

{ #category : #tables }
AlphaDescriptorSystem >> classModelForClassExample: aClassModel [
	aClassModel newAttributeNamed: #id type: Integer.
	aClassModel newAttributeNamed: #trace type: ClassExample.
	aClassModel newAttributeNamed: #value type: String.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassF: aClassModel [
	aClassModel newAttributeNamed: #attrAClassE.
	aClassModel newAttributeNamed: #attrBClassE.
	aClassModel newAttributeNamed: #attrAClassF.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassG: aClassModel [
	aClassModel newAttributeNamed: #attrAClassE.
	aClassModel newAttributeNamed: #attrBClassE.
	aClassModel newAttributeNamed: #attrAClassG.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassH: aClassModel [
	self attrsOfClassH do: [:eachAttrName | aClassModel newAttributeNamed: eachAttrName].
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassI: aClassModel [
	aClassModel newAttributeNamed: #attrAClassI type: ClassA.
	aClassModel newAttributeNamed: #attrBClassI type: ClassC.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassJ: aClassModel [
	aClassModel newAttributeNamed: #attrAClassJ.
	aClassModel newAttributeNamed: #attrBClassJ.
	aClassModel newAttributeNamed: #attrCClassJ collectionOf: ClassK.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassK: aClassModel [
	aClassModel newAttributeNamed: #attrAClassK.
	aClassModel newAttributeNamed: #attrBClassK.
	aClassModel newAttributeNamed: #attrCClassK type: ClassJ.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassL: aClassModel [
	self attrsOfClassL do: [:eachAttrName | aClassModel newAttributeNamed: eachAttrName].
	aClassModel newAttributeNamed: #attrDClassL type: ClassM.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassM: aClassModel [
	aClassModel newAttributeNamed: #attrAClassM.
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassO: aClassModel [
	self attrsOfClassO do: [:eachAttrName | aClassModel newAttributeNamed: eachAttrName].
]

{ #category : #classes }
AlphaDescriptorSystem >> classModelForClassQ: aClassModel [
	aClassModel newAttributeNamed: #attrAClassQ.
	aClassModel newAttributeNamed: #attrBClassQ type: ClassF.
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassA: aDescriptor [
	| table |
	table := self tableNamed: 'TBLA'.
	aDescriptor table: table.
	self attrsOfClassA do:
		[:eachAttrName |
		aDescriptor directMapping
			from: eachAttrName
			to: eachAttrName asString asUppercase].
	(aDescriptor directMapping from: #attrEClassA to: 'ATTRECLASSA')
		converter: self newBooleanConverter;
		shouldProxy: true.
	aDescriptor toManyMapping attributeName: #attrFClassA.
	aDescriptor toManyMapping attributeName: #attrGClassA.
	aDescriptor directMapping from: #attrHClassA to: 'ATTRHCLASSA'.
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassB: aDescriptor [
	| table newMapping join |
	table := self tableNamed: 'TBLB'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #attrAClassB
		to: (table fieldNamed: #attrAClassB asString asUppercase).
	aDescriptor directMapping
		from: #attrCClassB
		to: (table fieldNamed: #attrCClassB asString asUppercase).
	newMapping := aDescriptor oneToOneMapping.
	newMapping attributeName: #attrBClassB.
	join := Join new.
	join
		from: (table fieldNamed: #attrBClassB asString asUppercase)
		to: ((self tableNamed: 'TBLA') fieldNamed: 'ATTRACLASSA').
	newMapping join: join.
	newMapping := aDescriptor oneToOneMapping.
	newMapping attributeName: #attrDClassB.
	join := Join new.
	join
		from: (table fieldNamed: #attrDClassB asString asUppercase)
		to: ((self tableNamed: 'TBLC') fieldNamed: 'ATTRACLASSC').
	newMapping join: join.
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassC: aDescriptor [
	| table |
	table := self tableNamed: 'TBLC'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #attrAClassC
		to: (table fieldNamed: #attrAClassC asString asUppercase).
	aDescriptor directMapping
		from: #attrBClassC
		to: (table fieldNamed: #attrBClassC asString asUppercase).
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassE: aDescriptor [
	| table |
	table := self tableNamed: 'TBLE'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #attrAClassE
		to: (table fieldNamed: #attrAClassE asString asUppercase).
	aDescriptor directMapping
		from: #attrBClassE
		to: (table fieldNamed: #attrBClassE asString asUppercase).
	(self typeResolverFor: ClassE) register: aDescriptor abstract: true.
]

{ #category : #tables }
AlphaDescriptorSystem >> descriptorForClassExample: aDescriptor [
	| table |
	table := self tableNamed: 'CLASS_EXAMPLE'.
	aDescriptor table: table.
	aDescriptor directMapping from: #id to: (table fieldNamed: 'id').
	aDescriptor oneToOneMapping
		attributeName: #trace;
		join: (Join from: (table fieldNamed: 'trace')
				to: (table fieldNamed: 'id')).
	aDescriptor directMapping from: #value to: (table fieldNamed: 'value').
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassF: aDescriptor [
	| table |
	table := self tableNamed: 'TBLE'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #attrAClassE
		to: (table fieldNamed: #attrAClassE asString asUppercase).
	aDescriptor directMapping
		from: #attrBClassE
		to: (table fieldNamed: #attrBClassE asString asUppercase).
	aDescriptor directMapping
		from: #attrAClassF
		to: (table fieldNamed: #attrAClassF asString asUppercase).
	(self typeResolverFor: ClassE)
		register: aDescriptor
		keyedBy: 'F'
		field: (table fieldNamed: 'OBJECT_TYPE').
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassG: aDescriptor [
	| table |
	table := self tableNamed: 'TBLE'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #attrAClassE
		to: (table fieldNamed: #attrAClassE asString asUppercase).
	aDescriptor directMapping
		from: #attrBClassE
		to: (table fieldNamed: #attrBClassE asString asUppercase).
	aDescriptor directMapping
		from: #attrAClassG
		to: (table fieldNamed: #attrAClassG asString asUppercase).
	(self typeResolverFor: ClassE)
		register: aDescriptor
		keyedBy: 'G'
		field: (table fieldNamed: 'OBJECT_TYPE').
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassH: aDescriptor [
	| tableH tableH1 |
	tableH := self tableNamed: 'TBLH'.
	aDescriptor table: tableH.
	tableH1 := self tableNamed: 'TBLH1'.
	aDescriptor table: tableH1.
	aDescriptor addMultipleTableJoin: (Join from: (tableH fieldNamed: 'ATTRACLASSH') to: (tableH1 fieldNamed: 'ATTRACLASSH')).
	#(#attrAClassH #attrBClassH) do:
		[:eachAttrName |
		aDescriptor directMapping
			from: eachAttrName
			to: (tableH fieldNamed: eachAttrName asString asUppercase)].
	#(#attrCClassH #attrDClassH) do:
		[:eachAttrName || eachField mapping | eachField := tableH1 fieldNamed: eachAttrName.
		mapping := aDescriptor adHocMapping
			forAttribute: eachAttrName
			fromDb:
				[:row :elementBuilder :context |
				elementBuilder valueOfField: (context translateField: eachField) in: row]
			toDb:
				[:rows :attribute :attributeRows |
				(rows at: eachField table) at: eachField put: attribute]
		mappingFields: (Array with: eachField).
		mapping shouldProxy: true].
			
		"	
		mapping := aDescriptor adHocMapping
			from: eachAttrName
			to: (((#(#attrAClassH #attrBClassH) includes: eachAttrName) ifTrue: [tableH] ifFalse: [tableH1]) fieldNamed: eachAttrName asString asUppercase).
		mapping field table == tableH ifFalse:
			mapping query retrieve: (#(#attrCClassH #attrDClassH) asOrderedCollection remove: eachAttrName; first)]]."
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassI: aDescriptor [
	| table |
	table := self tableNamed: 'TBLI'.
	aDescriptor table: table.
	aDescriptor oneToOneMapping
		attributeName: #attrAClassI;
		join: (Join new
				from: (table fieldNamed: #attrAClassI asString asUppercase)
				to: ((self tableNamed: 'TBLA') fieldNamed: 'ATTRACLASSA')).
	aDescriptor oneToOneMapping
		attributeName: #attrBClassI;
		join: (Join new
				from: (table fieldNamed: #attrBClassI asString asUppercase)
				to: ((self tableNamed: 'TBLC') fieldNamed: 'ATTRACLASSC')).
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassJ: aDescriptor [
	| table |
	table := self tableNamed: 'TBLJ'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #attrAClassJ
		to: (table fieldNamed: #attrAClassJ asString asUppercase).
	aDescriptor directMapping
		from: #attrBClassJ
		to: (table fieldNamed: #attrBClassJ asString asUppercase).
	aDescriptor toManyMapping
		attributeName: #attrCClassJ;
		orderBy: [:classKObj | classKObj attrBClassK descending].
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassK: aDescriptor [
	| table newMapping join |
	table := self tableNamed: 'TBLK'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #attrAClassK
		to: (table fieldNamed: #attrAClassK asString asUppercase).
	aDescriptor directMapping
		from: #attrBClassK
		to: (table fieldNamed: #attrBClassK asString asUppercase).
	newMapping := aDescriptor oneToOneMapping.
	newMapping attributeName: #attrCClassK.
	join := Join new.
	join
		from: (table fieldNamed: #attrCClassK asString asUppercase)
		to: ((self tableNamed: 'TBLJ') fieldNamed: 'ATTRACLASSJ').
	newMapping join: join.
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassL: aDescriptor [
	| table newMapping join |
	table := self tableNamed: 'TBLL'.
	aDescriptor table: table.
	self attrsOfClassL do:
		[:eachAttrName |
		newMapping := aDescriptor directMapping
			from: eachAttrName
			to: (table fieldNamed: eachAttrName asString asUppercase)].
	newMapping := aDescriptor oneToOneMapping.
	newMapping attributeName: #attrDClassL.
	join := Join new.
	join
		from: (table fieldNamed: #attrDClassL asString asUppercase)
		to: ((self tableNamed: 'TBLM') fieldNamed: 'ATTRACLASSM').
	newMapping join: join.
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassM: aDescriptor [
	| table |
	table := self tableNamed: 'TBLM'.
	aDescriptor table: table.
	aDescriptor directMapping
		from: #attrAClassM
		to: (table fieldNamed: #attrAClassM asString asUppercase).
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassO: aDescriptor [
	| table newMapping |
	table := self tableNamed: 'TBLO'.
	aDescriptor table: table.
	self attrsOfClassO do:
		[:eachAttrName |
		newMapping := aDescriptor directMapping
			from: eachAttrName
			to: (table fieldNamed: eachAttrName asString asUppercase)].
]

{ #category : #descriptors }
AlphaDescriptorSystem >> descriptorForClassQ: aDescriptor [
	| table newMapping join |
	table := self tableNamed: 'TBLQ'.
	aDescriptor table: table.
	newMapping := aDescriptor directMapping
		from: #attrAClassQ
		to: (table fieldNamed: #attrAClassQ asString asUppercase).
	newMapping := aDescriptor oneToOneMapping.
	newMapping attributeName: #attrBClassQ.
	join := Join new.
	join
		from: (table fieldNamed: #attrBClassQ asString asUppercase)
		to: ((self tableNamed: 'TBLE') fieldNamed: 'ATTRACLASSE').
	newMapping join: join.
]

{ #category : #'initialize-release' }
AlphaDescriptorSystem >> initialize [
	"Earlier code for this descriptor system overrode getter #useDirectAccessForMapping to return false.  In this version, we set the instVar here instead, so that if anyone resets it then their exercise of the tests will be as they expect."

	super initialize.
	useDirectAccessForMapping := false.
]

{ #category : #accessing }
AlphaDescriptorSystem >> newBooleanConverter [
	^PluggableDatabaseConverter new
		dbToStConverter: [:dbVal | dbVal == 1];
		stToDbConverter: [:stVal | stVal == true ifTrue: [1] ifFalse: [0]];
		yourself
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForCLASS_EXAMPLE: aTable [
	(aTable createFieldNamed: 'id' type: platform serial) bePrimaryKey.
	((aTable createFieldNamed: 'trace' type: platform int4) imDefaultValue: 0)
		beNullable: false.
	aTable createFieldNamed: 'value' type: (platform varChar: 255).
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLA: aTable [
	(aTable createFieldNamed: 'ATTRACLASSA' type: (platform varChar: 20)) bePrimaryKey.
	aTable createFieldNamed: 'ATTRBCLASSA' type: (platform varChar: 70).
	aTable createFieldNamed: 'ATTRCCLASSA' type: platform integer.
	aTable createFieldNamed: 'ATTRDCLASSA' type: (platform number precision: 9; scale: 4; yourself).
	aTable createFieldNamed: 'ATTRECLASSA' type: platform integer.
	aTable createFieldNamed: 'ATTRHCLASSA' type: platform boolean.
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLB: aTable [
	| field |

	(aTable createFieldNamed: 'ATTRACLASSB' type: (platform varChar: 20)) bePrimaryKey.
	aTable createFieldNamed: 'ATTRCCLASSB' type: (platform varChar: 70).

	field := aTable createFieldNamed: 'ATTRBCLASSB' type: (platform varChar: 20).
	aTable addForeignKeyFrom: field to: ((self tableNamed: 'TBLA') fieldNamed: 'ATTRACLASSA').
	field bePrimaryKey.

	field := aTable createFieldNamed: 'ATTRDCLASSB' type: platform integer.
	aTable addForeignKeyFrom: field to: ((self tableNamed: 'TBLC') fieldNamed: 'ATTRACLASSC').
	field bePrimaryKey.
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLC: aTable [
	(aTable createFieldNamed: 'ATTRACLASSC' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'ATTRBCLASSC' type: (platform varChar: 20).
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLE: aTable [
	"The issues of test 07 and 07a relate to whether the filter field 'OBJECT_TYPE' is or is not a primaryKey."

	(aTable createFieldNamed: 'ATTRACLASSE' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'ATTRBCLASSE' type: (platform varChar: 20).
	aTable createFieldNamed: 'OBJECT_TYPE' type: (platform varChar: 2).
	aTable createFieldNamed: 'ATTRACLASSF' type: (platform varChar: 20).
	aTable createFieldNamed: 'ATTRACLASSG' type: (platform varChar: 20).
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLH1: aTable [
	(aTable createFieldNamed: 'ATTRACLASSH' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'ATTRCCLASSH' type: (platform varChar: 20).
	aTable createFieldNamed: 'ATTRDCLASSH' type: (platform varChar: 50).
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLH: aTable [
	(aTable createFieldNamed: 'ATTRACLASSH' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'ATTRBCLASSH' type: (platform varChar: 70).
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLI: aTable [
	| field |
	field := aTable createFieldNamed: 'ATTRACLASSI' type: (platform varChar: 20).
	aTable addForeignKeyFrom: field to: ((self tableNamed: 'TBLA') fieldNamed: 'ATTRACLASSA').
	field bePrimaryKey.
	field := aTable createFieldNamed: 'ATTRBCLASSI' type: platform integer.
	aTable addForeignKeyFrom: field to: ((self tableNamed: 'TBLC') fieldNamed: 'ATTRACLASSC').
	field bePrimaryKey.
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLJ: aTable [
	(aTable createFieldNamed: 'ATTRACLASSJ' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'ATTRBCLASSJ' type: (platform varChar: 70).
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLK: aTable [
	| field |

	(aTable createFieldNamed: 'ATTRACLASSK' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'ATTRBCLASSK' type: platform integer.

	field := aTable createFieldNamed: 'ATTRCCLASSK' type: platform integer.
	aTable addForeignKeyFrom: field to: ((self tableNamed: 'TBLJ') fieldNamed: 'ATTRACLASSJ').
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLL: aTable [
	| field |

	(aTable createFieldNamed: 'ATTRACLASSL' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'ATTRBCLASSL' type: (platform varChar: 20).
	aTable createFieldNamed: 'ATTRCCLASSL' type: platform integer.

	field := aTable createFieldNamed: 'ATTRDCLASSL' type: platform integer.
	aTable addForeignKeyFrom: field to: ((self tableNamed: 'TBLM') fieldNamed: 'ATTRACLASSM').
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLM: aTable [
	(aTable createFieldNamed: 'ATTRACLASSM' type: platform integer) bePrimaryKey.
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLO: aTable [
	(aTable createFieldNamed: 'ATTRACLASSO' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'ATTRBCLASSO' type: (platform varChar: 20).
	aTable createFieldNamed: 'ATTRCCLASSO' type: platform integer.
	aTable createFieldNamed: 'ATTRDCLASSO' type: platform integer.
]

{ #category : #tables }
AlphaDescriptorSystem >> tableForTBLQ: aTable [
	| field |

	(aTable createFieldNamed: 'ATTRACLASSQ' type: platform integer) bePrimaryKey.

	field := aTable createFieldNamed: 'ATTRBCLASSQ' type: platform integer.
	aTable addForeignKeyFrom: field to: ((self tableNamed: 'TBLE') fieldNamed: 'ATTRACLASSE').
]

{ #category : #descriptors }
AlphaDescriptorSystem >> typeResolverForClassE [
	^FilteredTypeResolver forRootClass: ClassE
]
