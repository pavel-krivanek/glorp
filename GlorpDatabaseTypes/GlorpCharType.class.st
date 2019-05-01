"
Character type
"
Class {
	#name : #GlorpCharType,
	#superclass : #GlorpAbstractStringType,
	#category : #GlorpDatabaseTypes
}

{ #category : #initialize }
GlorpCharType >> initialize [
	super initialize.
	typeString := 'char'.
]

{ #category : #testing }
GlorpCharType >> isVariableWidth [
	^false.
]

{ #category : #accessing }
GlorpCharType >> typeString [

	^self typeName, '(', width printString, ')'.
]
