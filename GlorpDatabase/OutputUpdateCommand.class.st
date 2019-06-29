"
I behave like my superclass, with a slight change in my query's syntax. Here's an example.

	UPDATE table SET field = field + ? - ? OUTPUT INSERTED.field WHERE id = ?

This form is needed by SQLServer.  Because it inserts the OUTPUT before the WHERE clause, i.e. in the middle of the update statement, it must be more invasive in its overriding of the super implementation.
"
Class {
	#name : #OutputUpdateCommand,
	#superclass : #ReturningUpdateCommand,
	#category : #'GlorpDatabase-GlorpCore'
}

{ #category : #'VisualWorks metadata' }
OutputUpdateCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
OutputUpdateCommand >> printSQLForFirstRow: aRow [
	| bodyFields |
	self nextPutAll: 'UPDATE '.
	aRow table printSQLOn: self withParameters: #().
	self nextPutAll: ' SET '.
	bodyFields := self fieldsNeedingUpdate: aRow.
	GlorpHelper
		do: [:field | aRow printEqualityTemplateForField: field on: self]
		for: bodyFields
		separatedBy: [self nextPut: $,].
	self relativeFields isEmpty ifFalse: [self platform printReturningFieldsOn: self].
	self nextPutAll: ' WHERE '.
	aRow printPrimaryKeyTemplateOn: self.
	self lockKeyFields do:
		[:field | self nextPutAll: ' AND '.
		aRow printLockEqualityForField: field on: self].
]
