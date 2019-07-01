"
My #nameLength mapping uses a GlorpBlockModel.  My #nameChunks mapping uses a GlorpSubsequenceModel.

"
Class {
	#name : #GlorpAttributeSubclassSystem,
	#superclass : #GlorpTestDescriptorSystem,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpAttributeSubclassSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpAttributeSubclassSystem >> allTableNames [
	"Return a list of all the table names that this system uses."

	^#('NAMED_FILES' 'TEXT_CHUNKS')
]

{ #category : #classes }
GlorpAttributeSubclassSystem >> classModelForGlorpTravelFile: aClassModel [
	aClassModel newAttributeNamed: #id.
	aClassModel newAttributeNamed: #name.
	"Make the overflow attribute any collection of String; the descriptor will reclassify it."
	aClassModel newAttributeNamed: #nameChunks collection: Array of: String.
]

{ #category : #'initialize-release' }
GlorpAttributeSubclassSystem >> constructAllClasses [
	^super constructAllClasses
		add: GlorpTravelFile;
		yourself
]

{ #category : #descriptors }
GlorpAttributeSubclassSystem >> descriptorForGlorpTravelFile: aDescriptor [
	"In this test, we choose code 2 for 'name' because 2 is the instvarIndex of 'name' in class GlorpTravelFolder.  Obviously, that correspondence is not robust:  a shape-change to GlorpTravelFolder could alter it;  it is just a trivial way of getting a code integer for the instvar.  We could make the field a varChar and use 'name' directly, but a rename of the instvar, though less frequent than a shape-change, is also quite possible.  We therefore use an integer code that we chose and will never change."

	| table chunkTable inlineTextFieldLength extendedTextFieldLength |
	table := aDescriptor table: 'NAMED_FILES'.
	chunkTable := aDescriptor table: 'TEXT_CHUNKS'.
	aDescriptor directMapping from: #id to: (table fieldNamed: 'ID').
	aDescriptor directMapping
		from: #name to: (table fieldNamed: 'name');
		converter: (self platform converterNamed: #stringToTrimmedString).
	inlineTextFieldLength := (table fieldNamed: 'name') type width.	"50"
	aDescriptor directMapping
		from: #nameLength to: (table fieldNamed: 'nameLength');
		getValueBlock: [ :object | object name size ];
		setValueBlock: [ :object :length | 
			| name allocatedName |
			name := object name.
			inlineTextFieldLength < length
				ifTrue: [ TestCase basicNew
						assert: name size = inlineTextFieldLength
						description: 'DB and image encode to different lengths?'.	"VW_TRANSLATION:XProgramming.SUnit.TestCase:TestCase"	"bit clunky this"
					allocatedName := name class new: length.
					allocatedName
						replaceElementsFrom: 1
						to: name size
						withSequenceableCollection: name
						startingAt: 1.
					object name: allocatedName ].
			length ].
	extendedTextFieldLength := (chunkTable fieldNamed: 'textChunk') type
		width.	"100"
	(aDescriptor newMapping: DirectToManyMapping)
		attributeName: #nameChunks;
		overflowAfter: inlineTextFieldLength
			intoMany: extendedTextFieldLength;
		resultField: (chunkTable fieldNamed: 'textChunk');
		writeTheOrderField;
		orderBy: [ :each | (each getTable: chunkTable) getField: 'sequenceNumber' ];
		join:
			(Join
				from: (table fieldNamed: 'id')
				to: (chunkTable fieldNamed: 'objectRef')
				from: 2
				to: (chunkTable fieldNamed: 'instvarCode'));
		constructRowMapKeyAs:
				[ :file :substring :index | "use whole name, not substring, for identity key in RowMap" "put target first, source second, in key, to detect mismatch fast" MultipleRowMapKey with: file name with: file with: index ];
		beExclusive;
		"or we could rely on a multiTableJoin for deletion?"
			shouldProxy: false	"2 is the instvarIndex of 'name' in class GlorpTravelFolder"	"maybe DirectTo*Mapping>>initialize should make shouldProxy false by default"
]

{ #category : #tables }
GlorpAttributeSubclassSystem >> tableForNAMED_FILES: aTable [
	(aTable createFieldNamed: 'ID' type: platform sequence) bePrimaryKey.
	aTable createFieldNamed: 'name' type: (platform varChar: 50).
	aTable createFieldNamed: 'nameLength' type: platform integer.
]

{ #category : #tables }
GlorpAttributeSubclassSystem >> tableForTEXT_CHUNKS: aTable [
	"I store the overflow text of inline varchar fields if their content is larger than the length of their field in the database.  I am keyed by my owning object's id, by my sequence number (which records the order of the overflow chunks) and by the code of the instvar holding the overflowing text.  The instvar code indicates which instvar this extended text belongs to.  This is needed because the owner's class could have two such instvars.  Using the instvar name would be problematic if that name were changed, so we use a faster-to-match SmallInteger key (trivially chosen in this test descriptor system to be the instvar's index in its class, but of course that can change too, so it's just a way to get a code number initially)."

	| fileIdField |
	(fileIdField := aTable createFieldNamed: 'objectRef' type: platform int) bePrimaryKey.
	aTable addForeignKeyFrom: fileIdField to: ((self tableNamed: 'NAMED_FILES') fieldNamed: 'ID').
	(aTable createFieldNamed: 'instvarCode' type: platform smallint) bePrimaryKey.
	(aTable createFieldNamed: 'sequenceNumber' type: platform smallint) bePrimaryKey.
	(aTable createFieldNamed: 'textChunk' type: (platform varChar: 100)) beNullable: false.
]
