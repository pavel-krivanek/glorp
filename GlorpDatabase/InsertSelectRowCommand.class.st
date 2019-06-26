"
I refuse to group-write;  all my rows are written singly.  After each INSERT, I SELECT to get the server-generated value of the row's identity column in the same round-trip, e.g.
	INSERT INTO mytable(firstname, lastname, address)
		VALUES (?, ?, ?);
	SELECT SCOPE_IDENTITY()
or
	INSERT INTO mytable(firstname, lastname, address)
		VALUES ('John', 'Smith', 'CA');
	SELECT SCOPE_IDENTITY()
		
SELECT SCOPE_IDENTITY() is more robust than SELECT @@IDENTITY but needs to be sent in the same round trip as the insert that generated the id.

In SELECT @@IDENTITY, SQLServer returned the value as a FixedPoint (bizarre! - perhaps the SELECT @@IDENTITY mechanism can return Fixed Points in another usage scenario and so used this as its generic return type).  Thus the value comes back as a FixedPoint but is of course an integer.  This did not cause problems until we began binding arrays of columns for insert. Without a call of #asInteger, it would be possible for an array from Store to have FixedPoint values mingled with Integer values, which violates the ODBC api's expected type.  As this command runs singly, we can ignore this.

(At present, only SQLServer uses me and my subclass, so the pre- and post-insertion SQL we generate is SQLServer-specific.  When another platform needs the same INSERT...SELECT...-in-same-round-trip behaviour, we can be generalised to get those SQL strings from our session's platform.)
"
Class {
	#name : #InsertSelectRowCommand,
	#superclass : #InsertIdentityColumnCommand,
	#category : #GlorpDatabase
}

{ #category : #'VisualWorks metadata' }
InsertSelectRowCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
InsertSelectRowCommand >> executeBoundInRoundTrip: anAccessor [
	"Send one or more rows to the database in a single round trip, bound to an array of values.  The array will be  two-dimensional (arrayBindings) or one-dimensional (batchStatementBindings)."

	| result |
	result := anAccessor executeCommandBound: self.
	self postWriteAssignSequenceInRoundTrip: result.
	result release.
	failed := false.	"This should be  failed := failed & false  but that's needless until it could ever be true.  Only update commands, not insert comands, need to check that the number of rows reported by the DB is the number expected, so this can just be false - unless we wish to set the number of rows returned by the select as rowCount and make these subclasses return true to #needsRowCount."
]

{ #category : #executing }
InsertSelectRowCommand >> executeUnboundInRoundTrip: anAccessor [
	"We have multiple rows unbound, which we will write as a single row with many values."

	| result |
	result := anAccessor executeCommandUnbound: self.
	self postWriteAssignSequenceInRoundTrip: result.
	result release.
	failed := false.	"This should be  failed := failed & false  but that's needless until it could ever be true.  Only UpdateCommands with lock fields, never InsertCommands, need to check that the number of rows that the DB reports affected is the number expected."
]

{ #category : #executing }
InsertSelectRowCommand >> postWriteAssignSequenceInRoundTrip: result [
	"Just the one row to get.  Using atIndex: instead of #first avoids needless isEmpty check."

	| id |
	id := result upToEnd.
	self row
		at: identityColumn
		put: (id first atIndex: 1) asInteger.
]

{ #category : #executing }
InsertSelectRowCommand >> printSQL [
	"Adjust the SQL to get the identity column value in the same round trip."

	super printSQL.
	self nextPutAll: self selectAddedIdentityColumnValues.
]

{ #category : #'private-accessing' }
InsertSelectRowCommand >> selectAddedIdentityColumnValues [
	"This select must be run in the same round trip as the insert that added the values.  It reads the table defined in #declareTableOfIdentitiesStatement, which was populated by the OUTPUT ... expression added in #outputAddedIdentityColumValuesIntoTable:."

	^'; SELECT SCOPE_IDENTITY()'
]

{ #category : #testing }
InsertSelectRowCommand >> supportsGroupWriting [
	^false
]
