"
Boolean type for MySQL platform. MySQL stores boolean as tinyint(1)
"
Class {
	#name : #GlorpMySQLBooleanType,
	#superclass : #GlorpBooleanType,
	#category : #GlorpDatabaseTypes
}

{ #category : #converting }
GlorpMySQLBooleanType >> converterForStType: aClass [
	(aClass includesBehavior: Boolean) ifTrue: [^self platform converterNamed: #booleanToInteger].
	^self platform nullConverter.
]
