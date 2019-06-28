"
I hold tests for some user-observed issues.  These tests use the AlphaARsDescriptorSystem (so named because it is a schematic model of alphabetised class and instVar names created to illustrate these issues).  They use the standard GlorpTest resources to create the tables but connect via their own accessor and session.  The tests have names but also numbers to connect them to the original issues.

Instance Variables:
	glorpDBAccessor	<DatabaseAccessor>	accessor for test, created from DefaultLogin
	glorpSession		<GlorpSession>	session for test, created from DefaultLogin


"
Class {
	#name : #GlorpAlphaSystemTest,
	#superclass : #TestCase,
	#instVars : [
		'glorpDBAccessor',
		'glorpSession'
	],
	#category : #GlorpDBTests
}

{ #category : #'test data' }
GlorpAlphaSystemTest class >> createDataForClassA: session [
	| newObj |
	1 to: 10 do:
		[:idx || pkVal |
		pkVal := 'recA' , idx printString.
		newObj := session readOneOf: ClassA where: [:classA | classA attrAClassA = pkVal].
		newObj ifNil:
			[newObj := ClassA new.
			newObj
				attrAClassA: pkVal;
				attrBClassA: 'some text for ' , idx printString;
				attrCClassA: idx * 10;
				attrDClassA: idx * 2.55;
				attrEClassA: true;
				attrHClassA: false.
			session register: newObj]].
	^newObj
]

{ #category : #'test data' }
GlorpAlphaSystemTest class >> createDataForClassB: session [
	| pkVal classAObj classCObj |
	classAObj := self createDataForClassA: session.
	classCObj := self createDataForClassC: session.
	1 to: 5 do:
		[:idx |
		pkVal := 'recB' , idx printString.
		(classAObj hasClassBWithPK: pkVal) ifFalse:
			[classAObj newClassB
				attrAClassB: pkVal;
				attrCClassB: 'some text' , idx printString;
				attrDClassB: classCObj]].
]

{ #category : #'test data' }
GlorpAlphaSystemTest class >> createDataForClassC: session [
	| newObj |
	1 to: 10 do:
		[:idx |
		newObj := session readOneOf: ClassC where: [:classC | classC attrAClassC = idx].
		newObj ifNil:
			[newObj := ClassC new.
			newObj
				attrAClassC: idx;
				attrBClassC: 'descr for ' , idx printString.
			session register: newObj]].
	^newObj
]

{ #category : #'test data' }
GlorpAlphaSystemTest class >> createDataForClassFAndG: session [
	| newObj objClass |
	1 to: 10 do:
		[:idx |
		objClass := idx > 5 ifTrue: [ClassG] ifFalse: [ClassF].
		newObj := session readOneOf: objClass where: [:obj | obj attrAClassE = idx].
		newObj ifNil:
			[newObj := objClass new.
			newObj
				attrAClassE: idx;
				attrBClassE: 'common descr ' , idx printString.
			(newObj isKindOf: ClassF)
				ifTrue: [newObj attrAClassF: 'concrete descr ' , idx printString]
				ifFalse: [newObj attrAClassG: 'concrete descr ' , idx printString].
		session register: newObj]].
	^newObj
]

{ #category : #'test data' }
GlorpAlphaSystemTest class >> createDataForClassH: session [
	| newObj |
	1 to: 10 do:
		[:idx |
		newObj := session readOneOf: ClassH where: [:classH | classH attrAClassH = idx].
		newObj ifNil:
			[newObj := ClassH new.
			newObj
				attrAClassH: idx;
				attrBClassH: 'descr for ' , idx printString;
				attrCClassH: 'secondary table ' , idx printString;
				attrDClassH: 'secondary table ' , idx printString.
			session register: newObj]].
	^newObj
]

{ #category : #'test data' }
GlorpAlphaSystemTest class >> createDataForClassI: session [
	| classAObj classCObj |
	classAObj := self createDataForClassA: session.
	classCObj := self createDataForClassC: session.
	(classAObj hasClassIWithClassC: classCObj) ifFalse:
		[classAObj newClassI attrBClassI: classCObj].
]

{ #category : #'test data' }
GlorpAlphaSystemTest class >> createDataForClassJAndK: session [
	|  jObjects |
	jObjects := (1 to: 10) collect:
		[:idx || jObj |
		jObj := session readOneOf: ClassJ where: [:obj | obj attrAClassJ = idx].
		jObj ifNil:
			[jObj := ClassJ new.
			jObj
				attrAClassJ: idx;
				attrBClassJ: 'descr ' , idx printString.
			session register: jObj].
		jObj].
	1 to: 10 do:
		[:idx || kObj |
		kObj := session readOneOf: ClassK where: [:obj | obj attrAClassK = idx].
		kObj ifNil:
			[kObj := ClassK new.
			kObj
				attrAClassK: idx;
				attrBClassK: idx + 10].
		jObjects last addK: kObj].
	^jObjects
]

{ #category : #'test data' }
GlorpAlphaSystemTest class >> createDataForClassQ: session [
	| newObj classFObj |
	1 to: 10 do:
		[:idx |
		classFObj := session readOneOf: ClassF where: [:obj | obj attrAClassE = 1].
		newObj := session readOneOf: ClassQ where: [:obj | obj attrAClassQ = idx].
		newObj ifNil:
			[newObj := ClassQ new.
			newObj
				attrAClassQ: idx;
				attrBClassQ: classFObj.
			session register: newObj]].
	^newObj
]

{ #category : #accessing }
GlorpAlphaSystemTest class >> resources [
	^Array with: GlorpDemoTablePopulatorResource.
]

{ #category : #'VisualWorks metadata' }
GlorpAlphaSystemTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'XProgramming.SUnit'
	)

]

{ #category : #accessing }
GlorpAlphaSystemTest >> glorpDBAccessor [
	^glorpDBAccessor
]

{ #category : #accessing }
GlorpAlphaSystemTest >> glorpDBAccessor: aDatabaseAccessor [
	glorpDBAccessor := aDatabaseAccessor.
]

{ #category : #accessing }
GlorpAlphaSystemTest >> glorpSession [
	^glorpSession
]

{ #category : #accessing }
GlorpAlphaSystemTest >> glorpSession: aGlorpSession [
	glorpSession := aGlorpSession.
]

{ #category : #utilities }
GlorpAlphaSystemTest >> newGlorpSession [
	| cache descrSystem |
	cache := CachePolicy default.
	cache numberOfElements: 5.
	descrSystem := AlphaDescriptorSystem forPlatform:
		self glorpDBAccessor currentLogin database.
	descrSystem cachePolicy: cache.
	^GlorpSession new
		system: descrSystem;
		accessor: self glorpDBAccessor;
		yourself
]

{ #category : #running }
GlorpAlphaSystemTest >> setUp [
	| login dbAccessor |
	login := GlorpDatabaseLoginResource defaultLogin copy.	"use the same database as GlorpTest"
	dbAccessor := DatabaseAccessor forLogin: login.
	dbAccessor login.
	self glorpDBAccessor: dbAccessor.
	self glorpSession: self newGlorpSession.
]

{ #category : #running }
GlorpAlphaSystemTest >> tearDown [
	self glorpDBAccessor ifNotNil: [:dbAccessor | dbAccessor logout].
	self glorpDBAccessor: nil.
	self glorpSession: nil.
]

{ #category : #running }
GlorpAlphaSystemTest >> testAlsoFetchCollection09a [
	"If we #readOneOf: some class and #alsoFetch: a collection attribute of that class then only the first value in the collection attribute is obtained.  In this test, the code produced is

SELECT t1.ATTRACLASSJ, t1.ATTRBCLASSJ, t2.ATTRACLASSK, t2.ATTRBCLASSK, t2.ATTRCCLASSK
 FROM (TBLJ t1 INNER JOIN TBLK t2 ON (t1.ATTRACLASSJ = t2.ATTRCCLASSK))
 WHERE (t1.ATTRACLASSJ = 10) ORDER BY t1.ATTRACLASSJ LIMIT 1

when in fact we would need the last characters to be LIMIT 10, not LIMIT 1 since there are 10 TBLK rows linked to the sole TBLJ row we are reading.  To fix this, Glorp must recognise the situation and rewrite to an outer query that alsoFetches and an inner query that is limited but does not alsoFetch.  This is now fixed for the readOneOf: (i.e. LIMIT 1) case."

	| query myClassJ |
	self glorpSession inUnitOfWorkDo: [:session | self class createDataForClassJAndK: session].
	self tearDown; setUp.
	"Read a classJ but do not fetch its classK collection in the same query."
	query := Query readOneOf: ClassJ where: [:classJ | classJ attrAClassJ = 10].
	myClassJ := self glorpSession execute: query.
	self assert: myClassJ attrCClassJ size = 10.
	self tearDown; setUp.	"clear the cache, ensuring we do not get an already-read object"
	"Read a classJ again;  this time, _do_ fetch its classK collection in the same query."
	query := Query readOneOf: ClassJ where: [:classJ | classJ attrAClassJ = 10].
	query alsoFetch: #attrCClassJ.
	self glorpDBAccessor logging: true.
	myClassJ := self glorpSession execute: query.
	self assert: myClassJ attrCClassJ size = 10.	"#readOneOf test fails here"
]

{ #category : #running }
GlorpAlphaSystemTest >> testAlsoFetchOrderedMapping09 [
	"Problem/Question: In TestDescriptorSystem>>descriptorForClassJ: we define attrCClassJ of ClassJ  to return its collection in descending order.  The ordering was not working when the attribute was alsoFetch:ed in a query for ClassJs instead of by instantiating the proxy later.  The SQL being issued by Glorp (and written to the Transcript by this test) was:

SELECT t1.ATTRACLASSJ, t1.ATTRBCLASSJ, t2.ATTRACLASSK, t2.ATTRBCLASSK, t2.ATTRCCLASSK
 FROM (TBLJ t1 INNER JOIN TBLK t2 ON (t1.ATTRACLASSJ = t2.ATTRCCLASSK))
 WHERE (t1.ATTRACLASSJ = 10) ORDER BY t1.ATTRACLASSJ

It should instead have been:

SELECT t1.ATTRACLASSJ, t1.ATTRBCLASSJ, t2.ATTRACLASSK, t2.ATTRBCLASSK, t2.ATTRCCLASSK
 FROM (TBLJ t1 INNER JOIN TBLK t2 ON (t1.ATTRACLASSJ = t2.ATTRCCLASSK))
 WHERE (t1.ATTRACLASSJ = 10) ORDER BY t1.ATTRACLASSJ, t2.ATTRBCLASSK DESC

since we are recovering ClassJ objects and its oneToMany mapping to ClassK has an order.  The fix in AR 64830 remedies this."

	| query myClassJ |
	self glorpSession inUnitOfWorkDo: [:session | self class createDataForClassJAndK: session].
	self tearDown; setUp.
	"Read a ClassJ but do not fetch its ClassK collection in the same query;  instantiate the proxy lazily."
	query := Query read: ClassJ where: [:classJ | classJ attrAClassJ = 10].
	myClassJ := (self glorpSession execute: query) first.
	self assert: myClassJ attrCClassJ size = 10.
	self assert: (myClassJ attrCClassJ collect: [:each | each attrBClassK]) =
		((myClassJ attrCClassJ collect: [:each | each attrBClassK])
			asSortedCollection: [:a :b | a > b]) asOrderedCollection
		description: 'Proxy of ordered relationship did not instantiate contents in order'.
	self tearDown; setUp.	"clear the cache, ensuring we do not get an already-read object"
	"Read a classJ again;  this time, _do_ fetch its classK collection in the same query."
	query := Query read: ClassJ where: [:classJ | classJ attrAClassJ = 10].
	query alsoFetch: #attrCClassJ.
	self glorpDBAccessor logging: true.
	myClassJ := (self glorpSession execute: query) first.
	self assert: myClassJ attrCClassJ size = 10.
	self assert: (myClassJ attrCClassJ collect: [:each | each attrBClassK]) =
		((myClassJ attrCClassJ collect: [:each | each attrBClassK])
			asSortedCollection: [:a :b | a > b]) asOrderedCollection
		description: 'Fetch of ordered relationship did not retrieve contents in order'.
]

{ #category : #running }
GlorpAlphaSystemTest >> testCachePurgeReread05 [
	"Problem/Question: Is there a way to clear all the objects in cache?  No code was provided with this - just a question to us.  The test constructed illustrates approaches to cache issues.  The first, using refresh: preserves object identity and is generally safe.  The others require the user to clean up references (and note that they do not combine well with refresh, which assumes that object identity in the cache remains the same)."

	| query readClassA cachedClassA |
	self glorpSession inUnitOfWorkDo:
		[:session | self class createDataForClassA: session].
	self tearDown; setUp.

	"SCENARIO 1:  refresh - safe because object identity does not change"
	query:= Query readOneOf: ClassA where: [:each | each attrAClassA = 'recA1'].
	query session: self glorpSession.
	cachedClassA := query checkCacheWithParameters: #() ifPresent: [:hit | hit].
	self assert: cachedClassA isNil.	"nothing in the cache yet"
	readClassA := self glorpSession execute: query.
	cachedClassA := query checkCacheWithParameters: #() ifPresent: [:hit | hit].
	self assert: cachedClassA == readClassA.	"cache was populated by read"
	self deny: cachedClassA attrHClassA.
	readClassA attrHClassA: true.
	self assert: cachedClassA attrHClassA.
	self deny: cachedClassA attrFClassA isInstantiated.
	self assert: cachedClassA attrFClassA size = 0.
	self assert: cachedClassA attrFClassA isInstantiated.
	query shouldRefresh: true.	"force the query to ignore the cache"
	readClassA := self glorpSession execute: query.
	self deny: readClassA attrHClassA.	"Our _value_, re-read from the DB, is false again"
	self deny: readClassA attrFClassA isInstantiated.	"and our proxy is uninstantiated"
	self assert: cachedClassA == readClassA.	"BUT we're still the same object, still in cache"
	self deny: cachedClassA attrHClassA.		"just with our values updated there."

	"SCENARIO 2:  purge from cache - unsafe if you do not discard or update all references to the purged object"
	query shouldRefresh: false.	"revert the query to normal state"
	readClassA attrHClassA: true.
	self assert: readClassA attrFClassA size = 0.
	self assert: readClassA attrFClassA isInstantiated.
	self glorpSession cacheRemoveObject: readClassA.
	self assert: cachedClassA == readClassA.
	readClassA := self glorpSession execute: query.
	self deny: readClassA attrFClassA isInstantiated.
	self deny: readClassA attrHClassA.	"We have been re-read from the DB - we're"
	self deny: cachedClassA == readClassA.	"not the same object.  The old object is"
	self assert: cachedClassA attrHClassA.	"unchanged, but no longer in the cache"
	self deny: cachedClassA == (query checkCacheWithParameters: #() ifPresent: [:hit | hit])
		description: 'Object purged from cache is still in cache'.
	self assert: readClassA == (query checkCacheWithParameters: #() ifPresent: [:hit | hit])
		description: 'Newly-read object not in cache'.

	"SCENARIO 3:  reset the session, and so the cache - unsafe if you do not discard or update all references to all previously-cached objects"
	cachedClassA := query checkCacheWithParameters: #() ifPresent: [:hit | hit].
	readClassA attrHClassA: true.
	self assert: readClassA attrFClassA size = 0.
	self assert: readClassA attrFClassA isInstantiated.
	self assert: cachedClassA == readClassA.
	self glorpSession reset.
	readClassA := self glorpSession execute: query.
	self deny: readClassA attrFClassA isInstantiated.
	self deny: readClassA attrHClassA.	"We have been re-read from the DB - we're"
	self deny: cachedClassA == readClassA.	"not the same object.  The old object is"
	self assert: cachedClassA attrHClassA.	"unchanged, but no longer in the cache"
	self deny: cachedClassA == (query checkCacheWithParameters: #() ifPresent: [:hit | hit])
		description: 'Object purged from cache is still in cache'.
	self assert: readClassA == (query checkCacheWithParameters: #() ifPresent: [:hit | hit])
		description: 'Newly-read object not in cache'.
]

{ #category : #running }
GlorpAlphaSystemTest >> testCompositeCacheHit04 [
	"Problem/Question: In AlphaDescriptorSystem>>tableForTBLB:, the table TBLB has composite primary key: ATTRACLASSB, ATTRBCLASSB and ATTRDCLASSB.  This test ensures Glorp looks in the cache (like e.g. ClassA which has single primary key) before issuing the sql statement to the database, which was not the case prior to the fix."

	| query myClassB |
	self glorpSession inUnitOfWorkDo:
		[:session | self class createDataForClassB: session].
	self tearDown; setUp.
	self glorpDBAccessor logging: true.
	query := Query
		readOneOf: ClassB
		where: [:classB | classB attrAClassB = 'recB1'
					& (classB attrBClassB attrAClassA = 'recA10')
					& (classB attrDClassB attrAClassC = 10)].
	myClassB := glorpSession execute: query.
	self assert: (query
				checkCacheWithParameters: #()
				ifPresent: [:hit | hit]) == myClassB
		description: 'I read a multi-field primaryKey object whose cache key was then not found'.
]

{ #category : #running }
GlorpAlphaSystemTest >> testDateArithmetic14 [
	"Problem/Question: We want to form the following sql:

SELECT * FROM EMP t1 WHERE (t1.JOINEDON + t1.BONUSDAYS) >= TO_DATE ('2012-4-3', 'YYYY-MM-DD');

For this we write query in smalltalk:

SimpleQuery read: Employee where: [:emp | (emp joinedOn + emp bonusDays) >= Date today].
         
Unfortunately this does not work. Does Glorp support this kind of query? If yes could you show us how. If it does not, is it possible to have this feature in Glorp?"

	| myClassA |
	self glorpSession inUnitOfWorkDo:
		[:session | self class createDataForClassA: session].
	self tearDown; setUp.
	myClassA := self glorpSession
		readOneOf: ClassA
		where: [:classA | classA attrCClassA + classA attrDClassA >= 25].
	self assert: myClassA attrCClassA + myClassA attrDClassA >= 25.
	self assert: myClassA attrCClassA days + myClassA attrDClassA days >= 25 days.	"either or both of the attributes could be of type date instead of using #days"
]

{ #category : #running }
GlorpAlphaSystemTest >> testDeleteReAddSameKey12 [
	"Problem/Question: UHE: link table entry requiring update is only partially populated.  Fixed in 65120."

	| kObj |
	self glorpSession inUnitOfWorkDo:
		[:sess | self class createDataForClassJAndK: sess].
	self tearDown; setUp.
	self glorpSession beginUnitOfWork.
	kObj := self glorpSession readOneOf: ClassK where: [:obj | obj attrAClassK = 1].
	self glorpSession delete: kObj.
	kObj := ClassK new.
	kObj
		attrAClassK: 1;
		attrBClassK: 11.
	self glorpSession register: kObj.
	self glorpSession commitUnitOfWork.
]

{ #category : #running }
GlorpAlphaSystemTest >> testDeleteReAddSameKey12a [
	"Problem/Question: UHE: link table entry requiring update is only partially populated."

	| lObj mObj |
	self glorpSession inUnitOfWorkDo:
		[:sess |
		mObj := sess readOneOf: ClassM where: [:obj | obj attrAClassM = 100].
		mObj ifNil:
			[mObj := ClassM new.
			mObj attrAClassM: 100.
			sess register: mObj].
		lObj := sess readOneOf: ClassL where: [:obj | obj attrAClassL = 10].
		lObj ifNil:
			[lObj := ClassL new.
			lObj
				attrAClassL: 10;
				attrBClassL: 'test';
				attrCClassL: 125;
				attrDClassL: mObj.
		sess register: lObj]].
	self tearDown; setUp.
	self glorpSession beginUnitOfWork.
	lObj := self glorpSession
			readOneOf: ClassL
			where: [:obj | obj attrAClassL = 10].
	self glorpSession delete: lObj.
	lObj := ClassL new.
	lObj
		attrAClassL: 10;
		attrBClassL: 'test'.
	self glorpSession register: lObj.
	self glorpSession commitUnitOfWork.
]

{ #category : #running }
GlorpAlphaSystemTest >> testDeleteReAddSameKey12b [
	"Problem/Question: UHE: link table entry requiring update is only partially populated."

	| oObj |
	self glorpSession inUnitOfWorkDo:
		[:sess |
		oObj := sess readOneOf: ClassO where: [:obj | obj attrAClassO = 10].
		oObj ifNil:
			[oObj := ClassO new.
			oObj
				attrAClassO: 10;
				attrBClassO: 'test';
				attrCClassO: 125;
				attrDClassO: 100.
			sess register: oObj]].
	self tearDown; setUp.
	self glorpSession beginUnitOfWork.
	oObj := self glorpSession
		readOneOf: ClassO
		where: [:obj | obj attrAClassO = 10].
	self glorpSession delete: oObj.
	oObj := ClassO new.
	oObj
		attrAClassO: 10;
		attrBClassO: 'test'.
	self glorpSession register: oObj.
	self glorpSession commitUnitOfWork.
]

{ #category : #running }
GlorpAlphaSystemTest >> testFilteredInheritanceCacheHit07 [
	"Problem/Question: ClassE has two concrete sub classes ClassF and ClassG, mapped by filtered inheritance to a single TableE where the filter field is not part of the primary key. When fetching instances of ClassF, Glorp adds the filer field to the primary key and then fails ti recognise this when looking in the cache, thus does not find the object in cache.  It will find it if the filter field is made part of the primaryKey (and the issue tested in 07a is fixed, as has now been done).  To avoid it maing this mistake when the filter field is not part of the primary key (e.g. when we do not want allow a ClassF to have the same key value as a ClassG), we must label the glorp-generated filter field expression and treat it as neutral when constructing the key."

	| query myClassF |
	self glorpSession inUnitOfWorkDo: [:session | self class createDataForClassFAndG: session].
	self tearDown; setUp.
	self glorpDBAccessor logging: true.
	query := Query readOneOf: ClassF where: [:classF | classF attrAClassE = 1].
	myClassF := self glorpSession execute: query.
	self assert: (query
				checkCacheWithParameters: #()
				ifPresent: [:hit | hit]) == myClassF
		description: 'I read a horizontal-filtered object whose cache key was then not found'.
	"Running the line below will cause a second print of the SQL to the Transcript if the cached object was not found, i.e. it should either run without printing to the Transcript or it should not be run because the assert above failed (but may be run in debug to verify)."
	self glorpSession readOneOf: ClassF where: [:classF | classF attrAClassE = 1].
]

{ #category : #running }
GlorpAlphaSystemTest >> testFilteredInheritancePrimaryKey07a [
	"Problem/Question: ClassE has two concrete sub classes ClassF and ClassG, all using the same table via a FilteredTypeResolver.  If we made the type resolver's field part of the primaryKey (to show that workaround for the problem of test 07), we at first saw a DNU when ClassQ had a foreign-key reference to ClassF;  this test was added to show it.  The fix was to Implement the method
	FilteredTypeMapping>>valueOfField:fromObject:
which had been accidentally omitted from the Glorp framework."

	| query myClassQ |
	self glorpSession inUnitOfWorkDo: [:session | self class createDataForClassFAndG: session].
	self glorpSession inUnitOfWorkDo: [:session | self class createDataForClassQ: session].
	self tearDown; setUp.
	self glorpDBAccessor logging: true.
	query := Query readOneOf: ClassQ where: [:classQ | classQ attrAClassQ = 1].
	myClassQ := self glorpSession execute: query.
	self assert: myClassQ attrBClassQ yourSelf class == ClassF
		description: 'This test was just to see if an error was raised;  for this assert to fail instead of erroring is odd'.
]

{ #category : #running }
GlorpAlphaSystemTest >> testManyCursors10 [
	"Problem/Question: Database cursors are not closed when executing direct sql's. Depending on the number of allowed open cursors on the database, you would get an oracle database exception: ORA-01000 maximum open cursors exceeded

To view number of open cursors, execute the following statement in an Oracle sql executor tool (login using SYSTEM):

select a.value, s.username, s.sid, s.serial#
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic#  and s.sid=a.sid
and b.name = 'opened cursors current'
"

	
	10000 timesRepeat:
		[1 to: 10 do:
			[:idx || pkVal | pkVal := 'recA' , idx printString.
			self glorpSession
				readOneOf: ClassA
				where: [:classA | classA attrAClassA = pkVal].
			self glorpDBAccessor executeSQLString: 'select * from TBLA where ATTRACLASSA = '
					, (Time now asNanoseconds / 10000000) asInteger printString printString]].
]

{ #category : #running }
GlorpAlphaSystemTest >> testOSMethods02 [
	"Problem/Question: In the method, RelationExpression>>operationFor:, ObjectStudio methods like os_comma:, os_Equal: etc. were missing.  These have been added, after which this was still failing with a base expression that does not understand sytem in a default type, due to incorrect bracketting of the expression in the where clause.  This test-code-caused failure has been fixed;  this now passes."

	self glorpSession inUnitOfWorkDo:
		[:session | self class createDataForClassA: session].
	self tearDown; setUp.
	self glorpSession inUnitOfWorkDo:
		[:session || classAs |
		classAs := session read: ClassA where:
			[:classA | classA attrAClassA = ('rec' , 'A1')].
		self assert: classAs size = 1].
]

{ #category : #running }
GlorpAlphaSystemTest >> testOSTable01 [
	"Problem/Question: Why does ObjectStudio.Table exists in descriptor system allClasses instance variable? Would it cause troubles?"

	self deny: ((self glorpSession system allClasses collect: [:each | each name asString]) includes: 'Table')
		description: 'Why is ObjectStudio.Table in system allClasses'.
]

{ #category : #running }
GlorpAlphaSystemTest >> testProxiedBoolean03 [
	"Problem/Question: When an attribute of boolean type is defined as proxy, you get an UHE: 'NonBoolean receiver--proceed for truth.', when #and: is sent to it, because and: is inlined and so bypasses the Glorp proxy DNU mechanism to get the value.  This is a known feature of Glorp, hence the use of AND:/OR: instead of and:/or: in where clauses, etc. - one can also use & and | to avoid the problem whenever the lazy-evaluation of and: is not required.  The test passes as we check for the raise of MustBeBoolean in the final line that demonstrates the issue.  The default workarounds is simply never to set any boolean attribute as shouldProxy: true (there seems no reason why one ever should), or to send #yourSelf to the value in the getter or in callers as shown below."

	| loadedObj |
	self glorpSession inUnitOfWorkDo:
		[:session | self class createDataForClassA: session].
	self tearDown; setUp.
	loadedObj := self glorpSession
		readOneOf: ClassA
		where: [:classA | classA attrAClassA = 'recA1'].
	self deny: (loadedObj attrHClassA and: [true])
		description: 'What''s this? Unproxied false and: [true] not false!'.
	self assert: loadedObj attrEClassA & true
		description: 'What''s this?  Proxy true & true not true!'.
	self assert: (loadedObj attrEClassA yourSelf and: [true])
		description: 'What''s this?  Proxy yourSelf true and: [true] not true!'.
	self should: [loadedObj attrEClassA and: [true]]
		raise: MustBeBoolean	"comment out this line to see the failure that prompted this test"
		description: 'Proxy of boolean survived being sent #and: and should not have, since #and: is optimised!'.
]

{ #category : #running }
GlorpAlphaSystemTest >> testRefreshCompositeObject11 [
	"Problem/Question: When doing a refresh: on an object with complex primary key, you get UHE: Wrong type of object.  Now fixed."

	| classIObj |
	self glorpSession inUnitOfWorkDo:
		[:session | self class createDataForClassI: session].
	self tearDown; setUp.
	classIObj := self glorpSession readOneOf: ClassI.
	self glorpSession refresh: classIObj.
]

{ #category : #running }
GlorpAlphaSystemTest >> testRepeatSQLUpdate08 [
	"Problem/Question: UHE: bad argument 4 when executing direct sql update statement more than once."

	2 timesRepeat:
		[self glorpDBAccessor
			beginTransaction;
			executeSQLString: 'update TBLA set ATTRECLASSA = 0';
			commitTransaction].
	2 timesRepeat:	"Test 3 expects ATTRECLASSA to be true."
		[self glorpDBAccessor
			beginTransaction;
			executeSQLString: 'update TBLA set ATTRECLASSA = 1';
			commitTransaction].
]

{ #category : #running }
GlorpAlphaSystemTest >> testTraceUpdate [
	"the test will trigger a bug in Glorp in 8.1.1 and earlier, where a foreign key is set to <nil> in Smalltalk and it should be written as 0 on the database (because the column has that default value).  The bug writes the value as NULL to the database.  If the column has the constraint to be NON NULL, this will fail.  Upon insert the 0 is correctly written (first #transact:). Upon update, it is NOT (third #transact:) which shows the bug."

	| version1 version2 |
	version1 := ClassExample withValue: '1'.
	self glorpSession transact: [version1].
	version2 := ClassExample withValue: '2'.
	version2 trace: version1.
	self glorpSession transact: [version2].
	self glorpSession transact:
		[self glorpSession register: version2.
		version2 trace: nil].
]
