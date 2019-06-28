"
This is a system designed to test the use of composite keys. Its model is an email message system, where we have users, folders, keyed by name and owning user, and messages, keyed by a message id, folder name, and owning user.  (A default message is keyed by user only, to test when no part of the key is local to the object being keyed.)
"
Class {
	#name : #GlorpCompositeKeyDescriptorSystem,
	#superclass : #GlorpTestDescriptorSystem,
	#category : #GlorpTestModels
}

{ #category : #'VisualWorks metadata' }
GlorpCompositeKeyDescriptorSystem class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpCompositeKeyDescriptorSystem >> allTableNames [
	^#('GR_USER' 'GR_FOLDER' 'GR_MESSAGE' 'GR_DEFAULT_MESSAGE' 'GR_DEFAULT_MESSAGE_LINK').
]

{ #category : #accessing }
GlorpCompositeKeyDescriptorSystem >> constructAllClasses [
	^(super constructAllClasses)
		add: GlorpUser;
		add: GlorpFolder;
		add: GlorpMessage;
		add: GlorpDefaultMessage;
		yourself
]

{ #category : #descriptors }
GlorpCompositeKeyDescriptorSystem >> descriptorForGlorpDefaultMessage: aDescriptor [
	"The (somewhat silly) default message is one-one with its pwning user (nominally a default message shown for that user or some such) and many-many with other users.  It tests having a table whose sole primaryKey is its one-one link to another table and (which is also important for the test) which has no other fields whatever."

	| table linkTable |
	table := self tableNamed: 'GR_DEFAULT_MESSAGE'.
	aDescriptor table: table.
	aDescriptor oneToOneMapping
		attributeName: #user;
		referenceClass: GlorpUser.
	linkTable := self tableNamed: 'GR_DEFAULT_MESSAGE_LINK'.
	aDescriptor toManyMapping
		attributeName: #userRestrictions;
		referenceClass: GlorpUser;
		useLinkTable;
		join: (Join from: (table fieldNamed: 'USER_ID')
				to: (linkTable fieldNamed: 'MESSAGE_ID')).
]

{ #category : #descriptors }
GlorpCompositeKeyDescriptorSystem >> descriptorForGlorpFolder: aDescriptor [

	| table userMapping messageMapping |
	table := self tableNamed: 'GR_FOLDER'.
	aDescriptor table: table.

	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).

	userMapping := OneToOneMapping new
		attributeName: #user;
		referenceClass: GlorpUser.
"		join: (Join from: (table fieldNamed: 'USER_ID') to: (userTable fieldNamed: 'ID'))."
	aDescriptor addMapping: userMapping.
	messageMapping := OneToManyMapping new
		attributeName: #messages;
		referenceClass: GlorpMessage.
"		join: (Join 
			from: (table fieldNamed: 'USER_ID')
			to: (messageTable fieldNamed: 'USER_ID') 	
			from: (table fieldNamed: 'NAME')
			to: (messageTable fieldNamed: 'FOLDER_NAME'))."
	messageMapping beExclusive.
	aDescriptor addMapping: messageMapping.
]

{ #category : #descriptors }
GlorpCompositeKeyDescriptorSystem >> descriptorForGlorpMessage: aDescriptor [

	| table userMapping folderMapping |
	table := self tableNamed: 'GR_MESSAGE'.
	aDescriptor table: table.
	self tableNamed: 'GR_USER'.
	self tableNamed: 'GR_FOLDER'.

	aDescriptor addMapping: (DirectMapping from: #subject to: (table fieldNamed: 'SUBJECT')).
	aDescriptor addMapping: (DirectMapping from: #contents to: (table fieldNamed: 'CONTENTS')).

	userMapping := OneToOneMapping new
		attributeName: #user;
		referenceClass: GlorpUser.
"		mappingCriteria: (Join from: (table fieldNamed: 'USER_ID') to: (userTable fieldNamed: 'ID'))."
	aDescriptor addMapping: userMapping.
	folderMapping := OneToOneMapping new
		attributeName: #folder;
		referenceClass: GlorpFolder.
	"Let it figure this out for itself"
"		mappingCriteria: (Join 
			from: (table fieldNamed: 'USER_ID')
			to: (userTable fieldNamed: 'ID') 	
			from: (table fieldNamed: 'NAME')
			to: (folderTable fieldNamed: 'FOLDER_NAME'))."
	aDescriptor addMapping: folderMapping.
]

{ #category : #descriptors }
GlorpCompositeKeyDescriptorSystem >> descriptorForGlorpUser: aDescriptor [

	| table folderMapping |
	table := self tableNamed: 'GR_USER'.
	aDescriptor table: table.

	aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
	aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).

	folderMapping := OneToManyMapping new
		attributeName: #folders;
		referenceClass: GlorpFolder.
"		mappingCriteria: 
						(Join
								from: (table fieldNamed: 'ID')
								to: (folderTable fieldNamed: 'USER_ID'))."
	folderMapping beExclusive.
	aDescriptor addMapping: folderMapping.
]

{ #category : #examples }
GlorpCompositeKeyDescriptorSystem >> example1 [
	| user1 user2 folder1 folder1a folder2 message1 message2 message3 |
	user1 := GlorpUser new id: 1; name: 'User One'.
	user2 := GlorpUser new id: 2; name: 'User Two'.
	folder1 := GlorpFolder new name: 'One'; user: user1.
	user1 folders add: folder1.
	folder1a := GlorpFolder new name: 'One-A'; user: user1.
	user1 folders add: folder1a.
	folder2 := GlorpFolder new name: 'Two'; user: user2.
	user2 folders add: folder2.
	
	message1 := GlorpMessage new subject: 'goes in folder 1'; user: user1; folder: folder1.
	folder1 messages add: message1.
	message2 := GlorpMessage new subject: 'also goes in folder 1'; user: user1; folder: folder1.
	folder1 messages add: message2.
	message3 := GlorpMessage new subject: 'goes in folder 2'; user: user2; folder: folder2.
	folder2 messages add: message3.
	^Array with: user1 with: user2.
]

{ #category : #tables }
GlorpCompositeKeyDescriptorSystem >> tableForGR_DEFAULT_MESSAGE: aTable [
	"To explore the case of a table whose sole primary key is also its link to another table, we create this table, supposedly for messages that are one-one with their users, being a default message template offered to the user or some such rationalisation."

	| userId |
	userId := aTable createFieldNamed: 'USER_ID' type: platform integer.
	userId bePrimaryKey.
	aTable
		addForeignKeyFrom: userId
		to: ((self tableNamed: 'GR_USER') fieldNamed: 'ID').
]

{ #category : #tables }
GlorpCompositeKeyDescriptorSystem >> tableForGR_DEFAULT_MESSAGE_LINK: aTable [
	"What users can see which defaults as templates."

	| userId messageId |
	messageId := aTable createFieldNamed: 'MESSAGE_ID' type: platform integer.
	userId := aTable createFieldNamed: 'USER_ID' type: platform integer.
	aTable
		addForeignKeyFrom: messageId
		to: ((self tableNamed: 'GR_DEFAULT_MESSAGE') fieldNamed: 'USER_ID').
	aTable
		addForeignKeyFrom: userId
		to: ((self tableNamed: 'GR_USER') fieldNamed: 'ID').
]

{ #category : #tables }
GlorpCompositeKeyDescriptorSystem >> tableForGR_FOLDER: aTable [ 
	| userId |
	userId := aTable createFieldNamed: 'USER_ID' type: platform integer.
	userId bePrimaryKey.
	aTable addForeignKeyFrom: userId
		to: ((self tableNamed: 'GR_USER') fieldNamed: 'ID').
	(aTable createFieldNamed: 'NAME' type: (platform varChar: 50)) bePrimaryKey.
]

{ #category : #tables }
GlorpCompositeKeyDescriptorSystem >> tableForGR_MESSAGE: aTable [ 
	| userId folderName |
	userId := aTable createFieldNamed: 'USER_ID' type: platform integer.
	userId bePrimaryKey.
	folderName := aTable createFieldNamed: 'FOLDER_NAME' type: (platform varChar: 50).
	folderName bePrimaryKey.
	aTable addForeignKeyFrom: userId
		to: ((self tableNamed: 'GR_USER') fieldNamed: 'ID').

	aTable addForeignKeyFrom: userId
		to: ((self tableNamed: 'GR_FOLDER') fieldNamed: 'USER_ID')
		from: folderName
		to: ((self tableNamed: 'GR_FOLDER') fieldNamed: 'NAME').


	(aTable createFieldNamed: 'SUBJECT' type: (platform varChar: 50)) bePrimaryKey.
	aTable createFieldNamed: 'CONTENTS' type: (platform varChar: 100).
]

{ #category : #tables }
GlorpCompositeKeyDescriptorSystem >> tableForGR_USER: aTable [
	(aTable createFieldNamed: 'ID' type: platform integer) bePrimaryKey.
	aTable createFieldNamed: 'NAME' type: (platform varChar: 50).
]
