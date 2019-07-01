"
After updating a relative field, return the value of that field and set it on the image object.  Here's an example query

	UPDATE table SET field = field + 100 - 20 WHERE id = 1 RETURNING field

In this example, the final value of the relative field is now 80 (the difference between its initial value of 20 read by Glorp and its changed value of 100 set in the image) plus whatever else may have been added or subtracted in other processes.  The updated final value is returned and set on the object by Glorp.
"
Class {
	#name : #ReturningUpdateCommand,
	#superclass : #RelativeUpdateCommand,
	#category : #'GlorpDatabase-GlorpCore'
}

{ #category : #'VisualWorks metadata' }
ReturningUpdateCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
ReturningUpdateCommand >> executeBoundInRoundTrip: anAccessor [
	"An updated row may have relative field columns; if so get their post-update DB values, which could differ from those we wrote."

	| result |
	result := anAccessor executeCommandBound: self.
	relativeFields isEmpty ifFalse:
		[self postWriteAssignReturnValuesUsing: result.
		result release].
	failed := self needsRowCount and: [rowCount ~= self expectedNumberOfModifiedRows].
]

{ #category : #executing }
ReturningUpdateCommand >> executeUnboundInRoundTrip: anAccessor [
	"An updated row may have relative field columns; if so get their post-update DB values, which could differ from those we wrote.  Batch updates require fetching one answer per updated row."

	| result |
	result := anAccessor executeCommandUnbound: self.
	relativeFields isEmpty ifFalse:
		[self postWriteAssignReturnValuesUsing: result.
		result release].
	failed := self needsRowCount and: [rowCount ~= self expectedNumberOfModifiedRows].
]

{ #category : #executing }
ReturningUpdateCommand >> postWriteAssignReturnValuesUsing: answerStream [
	"Ask the relative type how to assign returned value(s) to the target column(s) of my rows.  As result returns an array of arrays, we need the inner array.  If relative fields and values are not the same size, #with:do: will raise an error."

	allRows isNil
		ifTrue:
			[
				| upToEnd |
				upToEnd := answerStream upToEndOfReturningResultSet.
				upToEnd ifNotEmpty: [ 
					relativeFields with: answerStream upToEndOfReturningResultSet first do:
						[:field :value | row at: field forcePut: value ]]]
		ifFalse:
			[allRows do:
				[:aRow |	"A failed update due to a bad lock will return an empty collection, with rowCount = 0."
				| upToEnd |
				upToEnd := answerStream upToEndOfReturningResultSet.
				upToEnd ifNotEmpty: [ 
					relativeFields with: upToEnd first do:
						[:field :aValue | aRow at: field forcePut: aValue ]]]].
]

{ #category : #executing }
ReturningUpdateCommand >> printSQLForFirstRow: aRow [
	super printSQLForFirstRow: aRow.
	self relativeFields isEmpty ifFalse:
		[self platform printReturningFieldsOn: self].
]
