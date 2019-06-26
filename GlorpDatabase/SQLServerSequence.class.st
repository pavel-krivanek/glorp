"
This implements SQL Server sequences, which aren't really sequences at all, but identity columns. That means we can't do more than one at a time, and we have to do an extra select to get the value back.
"
Class {
	#name : #SQLServerSequence,
	#superclass : #NamedSequence,
	#category : #'GlorpDatabase-Glorp'
}

{ #category : #'VisualWorks metadata' }
SQLServerSequence class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #sequencing }
SQLServerSequence >> getSequenceValueFromDatabaseFor: aField in: aRow using: aSession [
]

{ #category : #testing }
SQLServerSequence >> isIdentityColumn [
	^true.
]

{ #category : #sequencing }
SQLServerSequence >> postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: anAccessor [
	"SELECT SCOPE_IDENTITY() is more robust so is now used instead whenever a group of rows are written to an SQLServer database version 9 or earlier (i.e. one that does not support value sequences).  This method will only be called when a single row is written.  Later, use SELECT SCOPE_IDENTITY() in that case too."

	aDatabaseRow
		at: aDatabaseField
		put: ((anAccessor executeSQLString: 'SELECT @@IDENTITY') first atIndex: 1) asInteger

"SQLServer returned the value as a FixedPoint (bizarre! - perhaps the SELECT @@IDENTITY mechanism can return Fixed Points in another usage scenario and so used this as its generic return type).  Thus the value comes back as a FixedPoint but is of course an integer.  This did not cause problems until we began binding arrays of columns for insert. Without the >>asInteger, it is possible for an array from Store to have FixedPoint values mingled with Integer values, which violates the ODBC api's expected type."
]

{ #category : #sequencing }
SQLServerSequence >> reserveSequenceNumbers: anInteger in: aSession for: aTable [
	"No real sequences here, just identity columns, which we can't pre-allocate"
]
