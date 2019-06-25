Class {
	#name : #GlorpDatabaseLoginTest,
	#superclass : #GlorpTestCase,
	#instVars : [
		'login',
		'accessor'
	],
	#category : #'GlorpDBTests-GlorpTest'
}

{ #category : #resources }
GlorpDatabaseLoginTest class >> resources [

	^Array with: GlorpDatabaseLoginResource.
]

{ #category : #'VisualWorks metadata' }
GlorpDatabaseLoginTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpDatabaseLoginTest >> accessor [

	^accessor.
]

{ #category : #support }
GlorpDatabaseLoginTest >> setUp [
	super setUp.
	login := GlorpDatabaseLoginResource defaultLogin copy.
	accessor := DatabaseAccessor forLogin: login.
]

{ #category : #tests }
GlorpDatabaseLoginTest >> testLogin [
	self assert: self accessor isLoggedIn not.
	self accessor login.
	self assert: self accessor isLoggedIn.
	self accessor logout.
	self assert: self accessor isLoggedIn not
]

{ #category : #tests }
GlorpDatabaseLoginTest >> testSecureLoginDiscardsPassword [
	| oldValue |
	self assert: self accessor isLoggedIn not.
	oldValue := self accessor currentLogin secure.
	[self accessor currentLogin secure: true.
	self accessor login.
	self assert: accessor currentLogin password isNil.
	self accessor logout]
		ensure: [self accessor currentLogin secure: oldValue].
]

{ #category : #tests }
GlorpDatabaseLoginTest >> testUnsecureLoginDoesNotDiscardPassword [
	| oldValue |
	self assert: self accessor isLoggedIn not.
	oldValue := self accessor currentLogin secure.
	[self accessor currentLogin secure: false.
	self accessor login.
	self assert: accessor currentLogin password notNil.
	self accessor logout]
		ensure: [self accessor currentLogin secure: oldValue].
]

{ #category : #tests }
GlorpDatabaseLoginTest >> testUnsuccessfulLogin [

	| anotherAccessor invalidLogin |
	"Some databases can't fail to log in."
	login database supportsAuthentication ifFalse: [^self].

	invalidLogin := GlorpDatabaseLoginResource defaultLogin copy.
	invalidLogin
		password: 'you will never ever guess this password';
		username: 'not a valid user name'.
	anotherAccessor := DatabaseAccessor forLogin: invalidLogin.

	self assert: anotherAccessor isLoggedIn not.
	anotherAccessor loginIfError: [:ex | ].
	Dialect isVisualAge		"The isLoggedIn is unreliable under VA, can return false positive"
		ifFalse: [self assert: anotherAccessor isLoggedIn not]
		ifTrue: [Transcript cr; show: self class name, '>>testUnsuccessfulLogin skips a trivial isLoggedIn check, saying it was unreliable under VA55, could return false positive, later versions not yet verified'].
	anotherAccessor logout.
]
