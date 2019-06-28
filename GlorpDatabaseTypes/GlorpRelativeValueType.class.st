"
I am an alternative to using a a lock field for optimistic lockinguses a delegation pattern, representing any database type that can support a 'relative update' like this:

	UPDATE aTable SET aColumn = aColumn + 10 WHERE ...

The SQL doesn't overwrite the target value directly, but changes it relative to what it was.  If noone else has updated aColumn between Glorp's reading and writing it, this will just be the value the instance already has.  Otherwise, to keep Glorp and the database in synch after commit, the full SQL resembles

	UPDATE aTable SET aColumn = aColumn + 10 WHERE ... RETURNING aColumn

so that the value of the returned type can be set on the image instance.  (Not all platforms support this:  a platform that returns false to #supportsReturningValuesForSession: will not set the new value back in the image and so must use relative values with caution, discarding written objects or explicitly refreshing them.)

Instance Variables:
	underlyingType	<GlorpDatabaseType>	The type my instance represents (typically, a subclass of GlorpAbstractNumericType).

"
Class {
	#name : #GlorpRelativeValueType,
	#superclass : #GlorpDatabaseType,
	#instVars : [
		'underlyingType'
	],
	#category : #'GlorpDatabaseTypes-Glorp'
}

{ #category : #'VisualWorks metadata' }
GlorpRelativeValueType class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #comparing }
GlorpRelativeValueType >> = aType [
	^underlyingType = aType
]

{ #category : #converting }
GlorpRelativeValueType >> converterForStType: aClass [
	^underlyingType converterForStType: aClass
]

{ #category : #'exdi specific' }
GlorpRelativeValueType >> exdiType [
	^underlyingType exdiType.
]

{ #category : #testing }
GlorpRelativeValueType >> hasParameters [
	^underlyingType hasParameters
]

{ #category : #comparing }
GlorpRelativeValueType >> hash [
	^underlyingType hash
]

{ #category : #converting }
GlorpRelativeValueType >> impliedSmalltalkType [
	^underlyingType impliedSmalltalkType
]

{ #category : #testing }
GlorpRelativeValueType >> isIntegerType [
	^underlyingType isInteger
]

{ #category : #accessing }
GlorpRelativeValueType >> isRelativeType [
	^true
]

{ #category : #accessing }
GlorpRelativeValueType >> nilOldValueEquivalent [
	"This choice of default matches our use of plus and minus as the operation connecting current value to fieldValue to oldValue;  if we generalise the operation, generalise this value."

	^0
]

{ #category : #accessing }
GlorpRelativeValueType >> precision [
	^underlyingType precision
]

{ #category : #accessing }
GlorpRelativeValueType >> precision: anInteger [
	underlyingType precision: anInteger
]

{ #category : #SQL }
GlorpRelativeValueType >> print: aValue on: aCommand [
	underlyingType print: aValue on: aCommand.
]

{ #category : #SQL }
GlorpRelativeValueType >> printValueForField: aField inRow: aRow on: aCommand [
	"Get the old and new values, then write the template with them.  If the old value was nil, make it zero (this choice of default matches our use of plus and minus as the operation connecting current value to fieldValue to oldValue;  if we generalise the operation, generalise this hardcoded default)."

	| oldValue fieldValue |
	oldValue := aRow
		oldVersionAt: aField
		ifAbsent: [self nilOldValueEquivalent].
	oldValue isNil ifTrue: [oldValue := self nilOldValueEquivalent].
	fieldValue := aRow at: aField ifAbsent:
		[^super printValueForField: aField inRow: aRow on: aCommand].
	aCommand
		nextPutAll: (self platform nameForColumn: aField name);
		nextPutAll: ' + '.
	(aCommand canBind: fieldValue to: self)
		ifTrue: [aCommand nextPutBindMarkerIn: nil]
		ifFalse: [underlyingType print: fieldValue on: aCommand].
	aCommand nextPutAll: ' - '.
	(aCommand canBind: fieldValue to: self)
		ifTrue: [aCommand nextPutBindMarkerIn: nil]
		ifFalse: [underlyingType print: oldValue on: aCommand].
]

{ #category : #accessing }
GlorpRelativeValueType >> scale [
	^underlyingType scale
]

{ #category : #accessing }
GlorpRelativeValueType >> scale: anInteger [
	underlyingType scale: anInteger
]

{ #category : #SQL }
GlorpRelativeValueType >> typeName [
	^underlyingType typeName.
]

{ #category : #SQL }
GlorpRelativeValueType >> typeString [
	^underlyingType typeString.
]

{ #category : #accessing }
GlorpRelativeValueType >> underlyingType [
	"I have no actual need to call this but since my super defines it to return self, this prevents infinite loops if a developer accidentally calls it."

	^underlyingType
]

{ #category : #accessing }
GlorpRelativeValueType >> underlyingType: aDatabaseType [
	underlyingType := aDatabaseType.
]
