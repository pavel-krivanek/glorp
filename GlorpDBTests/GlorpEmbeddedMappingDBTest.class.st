"
This exercises the EmbeddedValueOneToOneMapping in the case that it is being used as if it were a many-to-one mapping but does not have primary key(s) to fully support this.  Although each embeddedly-defined TravelAgency has many TravelAgents, each of its TravelAgents, when read, generates a separate equal-but-not-identical instance of the TravelAgency that they all belong to (see the comment in #descriptorForGlorpTravelAgency: for more detail).  These tests verify this behaviour (until such time as we might wish to alter it).
"
Class {
	#name : #GlorpEmbeddedMappingDBTest,
	#superclass : #GlorpMappingDBTest,
	#category : #GlorpDBTests
}

{ #category : #'VisualWorks metadata' }
GlorpEmbeddedMappingDBTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #support }
GlorpEmbeddedMappingDBTest >> setUp [
	super setUp.
	session beginTransaction.
	self writeAgents.
	session reset.
]

{ #category : #support }
GlorpEmbeddedMappingDBTest >> tearDown [
	session rollbackTransaction.
	super tearDown.
]

{ #category : #tests }
GlorpEmbeddedMappingDBTest >> testModifyAgents [
	"If the mapping from GlorpTravelAgent to GlorpTravelAgency does not proxy then this test never ends:  see the comment in #descriptorForGlorpTravelAgency:."

	| agents |
	agents := session read: GlorpTravelAgent orderBy: #id.
	session modify: agents in: [
		agents first name: 'Something Else'.
		(agents at: 2) name: 'something else again'].
	session reset.
	agents := session read: GlorpTravelAgent orderBy: #id.
	self assert: agents size = 3.
	self assert: agents first agency yourSelf = (agents at: 2) agency yourSelf.
	self deny: agents first agency yourSelf == (agents at: 2) agency yourSelf.
	self deny: agents first agency yourSelf = agents last agency yourSelf.
	self assert: agents first name = 'Something Else'.
	self assert: (agents at: 2) name = 'something else again'.
]

{ #category : #tests }
GlorpEmbeddedMappingDBTest >> testModifyAgentsReadOnlyAgency [
	"Test that if the agency mappings are all read-only, that we don't cause an error by trying to generate entries in the row map for its primary keys."

	(session system descriptorFor: GlorpTravelAgency) mappings do: [:each | each beReadOnly].
	[self testModifyAgents] ensure: [
		(session system descriptorFor: GlorpTravelAgency) mappings do: [:each | each canWrite: true]].
]

{ #category : #tests }
GlorpEmbeddedMappingDBTest >> testReadAgency [
	"See my class comment for why we are reading equal-but-not-identical agencies."

	| agencies agents agency |
	agencies := session read: GlorpTravelAgency orderBy: #name.
	agents := session read: GlorpTravelAgent orderBy: #id.
	self deny: agencies size = (agents collect: [:each | each agency name]) asSet size.
	self assert: agencies size = agents size.
	agency := agencies first.
	self assert: agency agents size = 2.
	self assert: agency agents first agency = agency.
	self deny: agency agents first agency == agency.
	self assert: agency agents last agency = agency.
	self deny: agency agents last agency == agency.
]

{ #category : #tests }
GlorpEmbeddedMappingDBTest >> testReadAgents [
	| agents |
	agents := session read: GlorpTravelAgent orderBy: #id.
	self assert: agents size = 3.
	self assert: agents first agency yourSelf = (agents at: 2) agency yourSelf.
	self deny: agents first agency yourSelf == (agents at: 2) agency yourSelf.
	self deny: agents first agency yourSelf = agents last agency yourSelf.
]

{ #category : #support }
GlorpEmbeddedMappingDBTest >> writeAgents [
	| agent1 agent2 agent3 |
	agent1 := GlorpTravelAgent new id: 1; name: 'Agent One'.
	agent1 agency: (GlorpTravelAgency new name: 'Agency One').
	agent2 := GlorpTravelAgent new id: 2; name: 'Agent Two'.
	agent2 agency: agent1 agency.
	agent3 := GlorpTravelAgent new id: 3; name: 'Agent Three'.
	agent3 agency: (GlorpTravelAgency new name: 'Agency Two').
	session modify: (Array with: agent1 with: agent2 with: agent3) in: [].
]
