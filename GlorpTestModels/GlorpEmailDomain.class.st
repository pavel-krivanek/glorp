"
This represents an email domain, used for exercising substring matches versus email addresses. Because the email addresses already separate out the host, we try to exercise the matching on the top level domain, which is a little silly, but it's just a test example.

Instance Variables:
	addresses	<OrderedCollection of: GlorpEmailAddress>	The list of addresses
	id	<Integer>	
	topLevelDomain	<String>	

"
Class {
	#name : #GlorpEmailDomain,
	#superclass : #Object,
	#instVars : [
		'id',
		'topLevelDomain',
		'addresses'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpEmailDomain class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpEmailDomain >> addresses [
	^addresses
]

{ #category : #accessing }
GlorpEmailDomain >> addresses: anObject [
	addresses := anObject
]

{ #category : #accessing }
GlorpEmailDomain >> topLevelDomain [
	^topLevelDomain
]

{ #category : #accessing }
GlorpEmailDomain >> topLevelDomain: anObject [
	topLevelDomain := anObject
]
