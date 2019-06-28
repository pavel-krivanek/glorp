"
This is an attempt to allow a cast to be used on constants, as e.g.
   CAST value: '1-2-3' as: platform date
It doesn't work yet, since printing of constants doesn't like having functions in the way - it conflicts with type conversion, and looks like it'll take a bit of work to fix.
"
Class {
	#name : #Cast,
	#superclass : #PrefixFunction,
	#category : #GlorpExpressions
}

{ #category : #'instance creation' }
Cast class >> value: anObject as: aDatabaseType [
	self error: 'this is work in progress, you probably shouldn''t use it yet'.
	(anObject isNil or: [anObject isGlorpExpression and: [anObject isConstantExpression and: [anObject value isNil]]])
		ifTrue: [^anObject].
	^self new base: anObject asGlorpExpression; arguments: (Array with: aDatabaseType asGlorpExpression).
]

{ #category : #'VisualWorks metadata' }
Cast class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #recursion }
Cast >> createMappingToFieldInRecursionTable: aDatabaseTable [
	"If we have cast our base to a type, that is the type we want for its field in the recursion table.  Glorp fails to generate brackets around an aliased constant value when printing SQL. e.g. in
	CAST('(1)' AS path AS character varying(75))
is invalid SQL as the distinct uses of AS are not parsable - it should probably be
	CAST(('(1)' AS path) AS character varying(75))
Until this is fixed, we cannot proceed to SQL generation with an aliased constant base.  We therefore nil it after using it."

	| impliedGlorpType newMapping |
	impliedGlorpType := arguments last value.
	newMapping := DirectMapping new.
	newMapping field:
		(aDatabaseTable createFieldNamed: base alias type: impliedGlorpType).
	base isConstantExpression
		ifTrue: [base alias: nil].
	^newMapping
]

{ #category : #'initialize-release' }
Cast >> initialize [
	super initialize.
	function := 'CAST'.
	separator := ' AS '.
]

{ #category : #preparing }
Cast >> rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression [
	^super rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression.
"	| rebuilt |
	self == anExpression ifTrue: [^aBaseExpression].
	rebuilt := (base rebuildOn: aBaseExpression startingFrom: anExpression withOuterScopeBase: ultimateBaseExpression).
	rebuilt := self class value: base as: arguments first.
	rebuilt alias: self alias.
	^rebuilt."
]

{ #category : #accessing }
Cast >> type [
	^arguments last value.
]
