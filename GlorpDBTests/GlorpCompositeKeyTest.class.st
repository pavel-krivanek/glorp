Class {
	#name : #GlorpCompositeKeyTest,
	#superclass : #GlorpSessionBasedTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpCompositeKeyTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #setup }
GlorpCompositeKeyTest >> setUp [
	super setUp.
	system := (GlorpCompositeKeyDescriptorSystem forPlatform: session platform).
	session system: system.
	session beginTransaction.
	session transact: [session register: system example1].
	session reset.
]

{ #category : #setup }
GlorpCompositeKeyTest >> tearDown [
	session rollbackTransaction.
	session resetPermissions.
	super tearDown.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testAlsoFetchToManyRead [
	| users query |
	query := Query read: GlorpUser where: [:each | each folders sqlCount = 2].
	query alsoFetch: #folders.
	users := session execute: query.
	self deny: users isEmpty.
	self deny: (users anySatisfy: [:each | each folders isGlorpProxy])
		description: 'retrieve of alsoFetched folders got proxies'.
	self assert: (users allSatisfy: [:each | each folders size = 2])
		description: 'retrieve of alsoFetched folders did not get them all'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testAlsoFetchToManyReadOne [
	"If a query reads only one object, but also fetches a to-many relationship joined to it, then it needs to retrieve more than one row and so cannot simply set LIMIT 1 on the overall query.  This test would fail in 8.0 and earlier, but passes in 8.1 and later since Glorp rewrites a query like
	query := Query readOneOf: MyClass where: .... .
	query alsoFetch: #myToManyRelationship.
into an outer query whose limit is reset to nil, joined to a limit-1 inner query that does not alsoFetch (see #testAlsoFetchToManyReadOneCompositeKey for limitations on this approach)
	query := Query readOneOf: MyClass where:
		[:each | each = (Query readOneOf: MyClass where: ....)].
	query alsoFetch: #myToManyRelationship.
	query limit: nil.
If the outer limit is not 1, but readsOneObject is true, Glorp assumes the user has already rewritten the query and so does not rewrite it again."

	| userWithMultipleFolders query |
	query := Query readOneOf: GlorpUser where: [:each | each folders sqlCount = 2].
	query alsoFetch: #folders.
	userWithMultipleFolders := session execute: query.
	self deny: userWithMultipleFolders folders isGlorpProxy
		description: 'folders were not alsoFetch:ed'.
	self assert: userWithMultipleFolders folders size = 2
		description: 'Reading user alsoFetch:ed only one folder'.
]

{ #category : #'tests - composite keys' }
GlorpCompositeKeyTest >> testAlsoFetchToManyReadOneCompositeKey [
	"The 'Glorp rewrites query to e = query' approach is exercised for simple primaryKey in testAlsoFetchToManyReadOne.  Here we test when the base has two primary key fields.  If session platform supportsLimit is false, we don't rewrite: the platform is inefficient when retrieving a single object in a query whose where clause matches many, but it is functionally correct in fetching toMany-related objects.  If the platform does support limit, we rewrite to avoid the risk of limiting #alsoFetch: across toMany-relations.  Where the base object has a composite key, the platform's value for supportsCompositeKeyArgsForOperand: determines whether we aggregate the LHS to a row-comparison like
	(t1.ID, t1.NAME) = SELECT t1.ID, t1.NAME ... LIMIT 1
or split the RHS thus
	(t1.ID = SELECT t1.ID ... LIMIT 1)
AND
	(t1.NAME = SELECT t1.NAME ... LIMIT 1)"

	| userWithMultipleFolders query |
	query := Query readOneOf: GlorpFolder where: [:each | each user id = 1 AND: [each name = 'One']].
	query alsoFetch: #messages.
	userWithMultipleFolders := session execute: query.
	self deny: userWithMultipleFolders messages isGlorpProxy
		description: 'Folders were not alsoFetch:ed'.
	self assert: userWithMultipleFolders messages size = 2
		description: 'Reading one user alsoFetch:ed only one folder'.
]

{ #category : #'tests - composite keys' }
GlorpCompositeKeyTest >> testAlsoFetchToManyReadOneCompositeKeyUserRewrite [
	"The 'e = Query ... limit 1' approach of #testAlsoFetchToManyReadOneCompositeKey is in principle equivalent to 'e in: Query ... limit 1'.  In practice, different database platforms have different edge case issues with rowCompare/=/in:/compositeKey/limit/.  Here we express the query in the form that Glorp will rewrite it to in #testAlsoFetchToManyReadOneCompositeKey but using #in:, not #=.  For simple primaryKey, this is tested in #testAlsoFetchToManyReadOneUserRewrite.  Here, we test it for composite key.
	MySQL does not tolerate ... IN limited subquery ...  When 'session system platform isMySQLPlatform' returns true, this test will raise a Glorp error (or, if that is resumed/omitted, a database error).  A later version of MySQL may correct this."

	| userWithMultipleFolders query |
	query := Query readOneOf: GlorpFolder where:
		[:e | e in: ((Query read: GlorpFolder where:  [:each | each user id = 1 AND: [each name = 'One']]) limit: 1)].
	query alsoFetch: #messages.
	query limit: nil.	"limit was set to 1 in readOneOf: call"
	session system platform isMySQLPlatform ifTrue:
		[self should: [userWithMultipleFolders := session execute: query]
			raise: GlorpDatabaseReadError
			description: 'Did not see error;  has MySQL fixed its LIMIT & IN problem?'.
		^self].
	userWithMultipleFolders := session execute: query.
	self deny: userWithMultipleFolders messages isGlorpProxy
		description: 'Folders were not alsoFetch:ed'.
	self assert: userWithMultipleFolders messages size = 2
		description: 'Reading one user alsoFetch:ed only one folder'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testAlsoFetchToManyReadOneUserLimit [
	"If the user sets the limit to a number other than 1 when alsoFetching a toMany, no rewriting the query occurs:  instead that number of rows will be returned."

	| userWithMultipleFolders query |
	query := Query readOneOf: GlorpUser where: [:each | each folders sqlCount = 2].
	query alsoFetch: #folders.
	query limit: 2.
	userWithMultipleFolders := session execute: query.
	self deny: userWithMultipleFolders folders isGlorpProxy
		description: 'folders were not alsoFetch:ed'.
	self assert: userWithMultipleFolders folders size > 1
		description: 'Reading user alsoFetch:ed only one folder'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testAlsoFetchToManyReadOneUserRewrite [
	"This test shows how a user who wants to read only one object, but who also wants to fetch a to-many relationship joined to it, can do by hand the rewriting that Glorp's internals apply in 8.1 and after.  If the original query were
	query := Query readOneOf: GlorpUser where: [:each | each folders sqlCount = 2].
	query alsoFetch: #folders.
then (before 8.1) it would not get more than one of to-many-joined folder rows, since it would get a single user by setting LIMIT 1 and this limit would apply to the whole query.  Recasting this to an outer query whose limit is reset to nil, joined to a limit-1 inner query that does not alsoFetch, is how the user can do in 8.0 and earlier what Glorp will do for them in 8.1 and after.  Glorp 8.1 uses the fact that the outer limit is not 1, although its readOneObject is true, to deduce when the user has already rewritten the query (so Glorp need not rewrite it again).
	This test checks that such user-handled queries return the results a user will expect.  In 8.1 and after, the user need not bother, but older Glorp-using code may have had such workarounds.
	To broaden the scope of the test suite, this test uses #in: instead of #=.  When the limit is 1, the two are semantically equivalent, but different platforms have different issues that can let one pass where the other fails."

	| userWithMultipleFolders query |
	query := Query readOneOf: GlorpUser where:
		[:e | e in: (Query readOneOf: GlorpUser where:  [:each | each folders sqlCount = 2])].
	query alsoFetch: #folders.
	query limit: nil.	"limit was set to 1 in readOneOf: call"
	session system platform isMySQLPlatform ifTrue: 
		[self should: [userWithMultipleFolders := session execute: query]
			raise: GlorpDatabaseReadError
			description: 'Did not see error;  has MySQL fixed its LIMIT & IN problem?'.
		^self].
	userWithMultipleFolders := session execute: query.
	self deny: userWithMultipleFolders folders isGlorpProxy
		description: 'Folders were not alsoFetch:ed'.
	self assert: userWithMultipleFolders folders size = 2
		description: 'Reading one user alsoFetch:ed only one folder'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testBasicReadFolder [
	| folders |
	folders := (session read: GlorpFolder) asSortedCollection: [:a :b | a name <= b name].
	self assert: folders size = 3.
	self assert: folders first name = 'One'.
	self assert: folders last name = 'Two'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testBasicReadMessage [
	| messages |
	messages := (session read: GlorpMessage) asSortedCollection: [:a :b | a subject <= b subject].
	self assert: messages size = 3.
	self assert: messages first subject = 'also goes in folder 1'.
	self assert: (messages at: 2) subject = 'goes in folder 1'.
	self assert: messages last subject = 'goes in folder 2'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testBasicReadUser [
	| users |
	users := (session read: GlorpUser) asSortedCollection: [:a :b | a id <= b id].
	self assert: users size = 2.
	self assert: users first name = 'User One'.
	self assert: users last name = 'User Two'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testFaulting [
	| users user1 sortedFolders user2 |
	users := session read: GlorpUser.
	user1 := users detect: [:each | each id = 1].
	self assert: user1 folders size = 2.
	sortedFolders := user1 folders asSortedCollection: [:a :b | a name < b name].
	self assert: sortedFolders first name = 'One'.
	user2 := users detect: [:each | each id = 2].
	self assert: user2 folders first messages first subject = 'goes in folder 2'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testFolderIdentity [
	| folders |
	folders := session read: GlorpFolder.
	folders do: [:each | | individualFolders individualFolder otherIndividualFolder|
		individualFolders := session read: GlorpFolder where: [:eachFolder | eachFolder = each].
		self assert: individualFolders size = 1.
		individualFolder := individualFolders first.
		otherIndividualFolder := session readOneOf: GlorpFolder where: [:eachFolder | eachFolder = each].
		self assert: individualFolder == each.
		self assert: otherIndividualFolder == individualFolder].
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testMessageCacheHit [
	| messages |
	messages := session read: GlorpMessage.
	messages do: [:each | | individualMessages individualMessage otherIndividualMessage|
		individualMessages := session read: GlorpMessage where: [:eachMessage | eachMessage = each].
		self assert: individualMessages size = 1.
		individualMessage := individualMessages first.
		session accessor denyReads.
		otherIndividualMessage := session readOneOf: GlorpMessage where: [:eachMessage | eachMessage = each].
		session accessor resetPermissions.
		self assert: individualMessage == each.
		self assert: otherIndividualMessage == individualMessage].
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testMessageIdentity [
	| messages |
	messages := session read: GlorpMessage.
	messages do: [:each | | individualMessages individualMessage otherIndividualMessage|
		individualMessages := session read: GlorpMessage where: [:eachMessage | eachMessage = each].
		self assert: individualMessages size = 1.
		individualMessage := individualMessages first.
		otherIndividualMessage := session readOneOf: GlorpMessage where: [:eachMessage | eachMessage = each].
		self assert: individualMessage == each.
		self assert: otherIndividualMessage == individualMessage].
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testReadWithCacheHitFromExpression [
	| message |
	session reset.
	message := session readOneOf: GlorpMessage where: [:each | each subject = 'goes in folder 1'].
	self assert: message folder name = 'One'.
	session accessor permitNothing.
	session readOneOf: GlorpFolder where: [:each | each user id = 1 & (each name = 'One')].
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testReadWithCacheHitFromJoin [
	| message |
	session reset.
	message := session readOneOf: GlorpMessage where: [:each | each subject = 'goes in folder 1'].
	session readOneOf: GlorpFolder where: [:each | each user id = 1 & (each name = 'One')].
	session accessor permitNothing.
	self assert: message folder name = 'One'.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testReadWithCacheHitFromParameterizedExpression [
	| message query |
	session reset.
	message := session readOneOf: GlorpMessage where: [:each | each subject = 'goes in folder 1'].
	self assert: message folder name = 'One'.
	session accessor permitNothing.
	query := Query readOneOf: GlorpFolder where: [:each | each user id = (each parameter: 1)  & (each name = (each parameter: 2))].
	query executeWithParameters: #(1 'One') in: session.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testReadWithJoins [
	| users |
	users := session read: GlorpUser where: [:each | each folders anySatisfyJoin: [:eachFolder |
		eachFolder messages anySatisfyJoin: [:eachMessage | eachMessage subject = 'goes in folder 1']]].
	self assert: users size = 1.
	self assert: users first id = 1.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testReadWithSubselect [
	| users |
	users := session read: GlorpUser where: [:each | each folders anySatisfyExists: [:eachFolder |
		eachFolder messages anySatisfyExists: [:eachMessage | eachMessage subject = 'goes in folder 1']]].
	self assert: users size = 1.
	self assert: users first id = 1.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testReadWithSubselectAndINClause [
	| users |
	users := session read: GlorpUser where:
		[:each |
		each folders anySatisfyExists:
			[:eachFolder || q |
			q := Query read: GlorpFolder.
			eachFolder in: q]].
	self deny: (users anySatisfy: [:each | each folders isEmpty])
		description: 'We asked only for users with some folders but got a user with none'.
]

{ #category : #'tests - composite keys' }
GlorpCompositeKeyTest >> testUserConstructedComposite [
	"Check a user-constructed composite key where the nominal composite has in fact only one mapping."

	| query users userNames assertQuery allNamedUsers mappingsToRetrieve |
	mappingsToRetrieve := #(name id).
	query := Query read: GlorpUser where:
		[:each || q |
		q := Query read: GlorpUser where: [:e | e folders sqlCount > 0].
		q retrieveAll: mappingsToRetrieve.
		(each getMappings: mappingsToRetrieve) in: q].
	users := session execute: query.
	self assert: users notEmpty.
	"the code above completes the exercise of getMappings: - what follows checks the results"
	userNames := users collect: [:each | each name].
	assertQuery := Query read: GlorpUser where:
		[:each | each name in: userNames].
	allNamedUsers := (session execute: assertQuery) groupedBy: [:each | each name].
	allNamedUsers do:
		[:each | self assert: (each anySatisfy: [:folder | folder folders size > 0])].
]

{ #category : #'tests - composite keys' }
GlorpCompositeKeyTest >> testUserConstructedCompositeBlock [
	"Check a user-constructed composite key where the nominal composite has in fact only one mapping."

	| query users userNames assertQuery allNamedUsers mappingsToRetrieve |
	mappingsToRetrieve := Array with: [:each | each name] with: [:each | each id].
	query := Query read: GlorpUser where:
		[:each || q |
		q := Query read: GlorpUser where: [:e | e folders sqlCount > 0].
		q retrieveAll: mappingsToRetrieve.
		(each getMappings: mappingsToRetrieve) in: q].
	users := session execute: query.
	self assert: users notEmpty.
	"the code above completes the exercise of getMappings: - what follows checks the results"
	userNames := users collect: [:each | each name].
	assertQuery := Query read: GlorpUser where:
		[:each | each name in: userNames].
	allNamedUsers := (session execute: assertQuery) groupedBy: [:each | each name].
	allNamedUsers do:
		[:each | self assert: (each anySatisfy: [:folder | folder folders size > 0])].
]

{ #category : #'tests - composite keys' }
GlorpCompositeKeyTest >> testUserConstructedCompositeBlockSingleton [
	"Exercise a user-constructed composite key where the nominal composite has in fact only one mapping.  As there is only one, we can check what is returned by comparing it with the results of a conventional query."

	| testQuery folders assertQuery assertFolders |
	testQuery := Query read: GlorpFolder where:
		[:each || q |
		q := Query read: GlorpFolder where: [:e | e messages sqlCount > 0].
		q retrieve: [:e | e name].
		(each getMappings: (Array with: [:ea | ea name])) in: q].
	testQuery orderBy: [:each | each name].		"order just to make assert comparison easier"
	folders := session execute: testQuery.
	self assert: folders notEmpty.
	assertQuery := Query read: GlorpFolder where:
		[:each || q |
		q := Query read: GlorpFolder where: [:e | e messages sqlCount > 0].
		q retrieve: #name.
		each name in: q].
	assertQuery orderBy: [:each | each name].	"order just to make assert comparison easier"
	assertFolders := session execute: assertQuery.
	self assert: folders = assertFolders.
]

{ #category : #'tests - composite keys' }
GlorpCompositeKeyTest >> testUserConstructedCompositeSingleton [
	"Exercise a user-constructed composite key where the nominal composite has in fact only one mapping.  As there is only one, we can check what is returned by comparing it with the results of a conventional query."

	| testQuery folders assertQuery assertFolders |
	testQuery := Query read: GlorpFolder where:
		[:each || q |
		q := Query read: GlorpFolder where: [:e | e messages sqlCount > 0].
		q retrieve: #name.
		(each getMappings: #(name)) in: q].
	testQuery orderBy: [:each | each name].		"order just to make assert comparison easier"
	folders := session execute: testQuery.
	self assert: folders notEmpty.
	assertQuery := Query read: GlorpFolder where:
		[:each || q |
		q := Query read: GlorpFolder where: [:e | e messages sqlCount > 0].
		q retrieve: #name.
		each name in: q].
	assertQuery orderBy: [:each | each name].	"order just to make assert comparison easier"
	assertFolders := session execute: assertQuery.
	self assert: folders = assertFolders.
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testUserIdentity [
	| users |
	users := session read: GlorpUser.
	users
		do:
			[:each | 
			| individualUser otherIndividualUser individualUsers |
			individualUsers := session
				read: GlorpUser
				where: [:eachIndividual | eachIndividual id = each id].
			self assert: individualUsers size = 1.
			individualUser := individualUsers first.
			otherIndividualUser := session
				readOneOf: GlorpUser
				where: [:eachIndividual | eachIndividual id = each id].
			self assert: individualUser == each.
			self assert: otherIndividualUser == individualUser].
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testUserIdentityViaMessage [
	| users |
	users := session read: GlorpUser.
	users
		do:
			[:each | 
			each folders
				do:
					[:eachFolder | 
					eachFolder messages
						do: [:eachMessage | 
							self assert: eachMessage folder yourSelf == eachFolder.
							self assert: eachMessage user yourSelf == each]]].
]

{ #category : #'tests- basic reading' }
GlorpCompositeKeyTest >> testUserIdentityViaMessageInUnitOfWork [
	session beginUnitOfWork.
	[self testUserIdentityViaMessage] ensure: [session rollbackUnitOfWork].
]
