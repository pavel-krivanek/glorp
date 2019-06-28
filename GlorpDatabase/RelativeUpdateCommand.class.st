"
One or more of my fields' types isRelativeType, which means that instead of reading a value of 20 and writing a value of 100 as in 
	UPDATE AUTHOR SET BALANCE = 120 WHERE ID = 2
we write, for such a field,
	UPDATE AUTHOR SET BALANCE = BALANCE + 100 WHERE ID = 2
Thus, as an alternative to optimistic locking (i.e. using one or more lock fields to abort update if the row has been updated by someone else between our reading and updating it), Glorp can compute the read-to-update difference, write a relative update statement and so be sure the increment is correct whatever other changes have been made in the interim.

Instance Variables:
	relativeFields	<SequenceableCollection>	fields to be updated whose type isRelativeType.
	normalFields		<SequenceableCollection>	fields to be updated whose type is neither Lock Key nor Relative.
"
Class {
	#name : #RelativeUpdateCommand,
	#superclass : #UpdateCommand,
	#instVars : [
		'relativeFields',
		'lockKeyFields'
	],
	#category : #'GlorpDatabase-GlorpCore'
}

{ #category : #'VisualWorks metadata' }
RelativeUpdateCommand class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #executing }
RelativeUpdateCommand >> allRowsGrouped: maxSizeInteger evaluate: aBlock [
	"If we have no lock keys, there is nothing to do here.  If we do then - since we must have some relative type fields- we sort into the two groups of those whose relative fields only are updated and those with at least one absiolute field updated.  If there are lock key fields, they will have been incremented for every row by this point. If there are no changed normal fields in that row, then we return only the changed relative fields. EVEN IF WE WERE writing all fields, not just changed ones, i.e. not shouldUpdateOnlyChangedFields, we would still want to suppress lockField update if only relative field values had changed. See further comments in >>row:."

	| theRows nonRelativeFields absolutelyUpdatedRows relativelyUpdatedRows |
	"We ask our row, not our cache, because if our row's table has lockKeyfields, other rows might need them or not whether this one does or not"
	row lockKeyFields isEmpty ifTrue:
		[^super allRowsGrouped: maxSizeInteger evaluate: aBlock].
	nonRelativeFields := OrderedCollection new.	"We cache lockkeyFields and relativefields - should we cache these too?"
	row fieldsDo: [:each | (each isPrimaryKey or: [each isLockKey or: [each type isRelativeType]]) ifFalse: [nonRelativeFields add: each]].
	nonRelativeFields isEmpty ifTrue:
		[^super allRowsGrouped: maxSizeInteger evaluate: aBlock].
	"Sort the rows into compatible groups.  Collect the keys as well as the groups, instead of just using #groupedBy:, to preserve order as much as possible."
	absolutelyUpdatedRows := OrderedCollection new: allRows size.
	relativelyUpdatedRows := OrderedCollection new: allRows size.
	allRows do:
		[:eachRow |
		(nonRelativeFields allSatisfy:
			[:eachField | (eachRow oldVersionAt: eachField ifAbsent: [self class missingFieldIndicator]) = (eachRow at: eachField)])
			ifTrue: [relativelyUpdatedRows add: eachRow revertLockKeyFields]
			ifFalse: [absolutelyUpdatedRows add: eachRow]].
	theRows := allRows.
	absolutelyUpdatedRows isEmpty ifFalse:
		[allRows := absolutelyUpdatedRows.
		self row: allRows first.
		super allRowsGrouped: maxSizeInteger evaluate: aBlock].
	"Now handle rows where the lockkey fields do not matter."
	relativelyUpdatedRows isEmpty ifFalse:
		[allRows := relativelyUpdatedRows.
		self row: allRows first.
		"lockKeyFields := #().	setting row will do that"
		super allRowsGrouped: maxSizeInteger evaluate: aBlock].
	"We're finished;  reset me back to my start state."
	allRows := theRows.
	self row: allRows first.
]

{ #category : #'bound values' }
RelativeUpdateCommand >> arrayBindings [
	"We must handle the special case of relative fields.  A relative field appears twice in the UPDATE command:  with its (current) to-write value and with its (prior) was-read value (or non-nil default if the old value was nil).  The SQL template has two bind markers for each relative field, with the operation (usually a minus sign) between them, and the new and old values are written to these two markers."

	| basicBindings relativeFieldBindings arrayBoundFields relativeFieldIndex allBindings |
	basicBindings := super arrayBindings.
	relativeFields isEmpty ifTrue: [^basicBindings].
	relativeFieldBindings := (1 to: relativeFields size) collect: [:each | Array new: allRows size].
	1 to: allRows size do:
		[:rowNumber || inputRow |
		inputRow := allRows at: rowNumber.
		1 to: relativeFields size do:
			[:columnNumber || relativeField |
			relativeField := relativeFields at: columnNumber.
			(relativeFieldBindings at: columnNumber)
				at: rowNumber
				put: (inputRow
						oldVersionAt: relativeField
						ifAbsent: [relativeField type nilOldValueEquivalent])]].
	"Now sort the basicBindings and relativeFieldBindings into their proper orders."
	arrayBoundFields := self arrayBoundFields.
	relativeFieldIndex := 0.
	"If we will not be using the where clause lock keys already in the basic bindings, reduce our array size."
	allBindings := Array new: basicBindings size + relativeFieldBindings size.
	1 to: arrayBoundFields size do: 
		[:boundFieldIndex || boundField |
		boundField := arrayBoundFields at: boundFieldIndex.
		allBindings
			at: boundFieldIndex + relativeFieldIndex
			put: (basicBindings at: boundFieldIndex).
		boundField type isRelativeType ifTrue:
			[relativeFieldIndex := relativeFieldIndex + 1.
			allBindings
				at: boundFieldIndex + relativeFieldIndex
				put: (relativeFieldBindings at: relativeFieldIndex)]].
	"The lock field where-clause values, if any, belong at the end of our array and are the trailing basicBindings values.
	However, if there are ONLY relative field updates, don't include the lock fields in the where clause. They have
	already been excluded from the singleRowBindings, via >>fieldsNeedingUpdate."
	self lockKeyFields isEmpty ifFalse:
		[0 to: basicBindings size - arrayBoundFields size - 1 do:
			[:i || index |
			index := allBindings size - i.
			allBindings at: index put: (basicBindings at: basicBindings size - i)]].
	^allBindings
]

{ #category : #'bound values' }
RelativeUpdateCommand >> batchStatementBindings [
	"As the super implementation but we add the relative fields' old values, and the where clause bindings for any lock fields.  If we are using this command we must have at least one relative field, so we never call super."

	| bound fields  |
	fields := self arrayBoundFields.
	bound := OrderedCollection new: allRows size * (fields size + relativeFields size+ lockKeyFields size).
	allRows do:
		[:eachRow |
		fields do:
			[:each || fieldValue | fieldValue := eachRow at: each ifAbsent: [nil].
			(self canBind: fieldValue to: each type) ifTrue: 
				[bound add: fieldValue.
				"the statement below is the only real change from the super implementation"
				each type isRelativeType ifTrue:	"fieldValue was bindable so old value must also be bindable"
					[bound add: (eachRow oldVersionAt: each ifAbsent: [each type nilOldValueEquivalent])]]].
		lockKeyFields do:
			[:each || fieldValue | fieldValue := eachRow oldVersionAt: each ifAbsent: [nil].
			(fieldValue notNil and: [self canBind: fieldValue to: each type]) ifTrue: [bound add: fieldValue]]].
	^bound asArray
]

{ #category : #'bound values' }
RelativeUpdateCommand >> bindingTypes [
	"Each relative type is doubly represented, once for the new and once for the old value."

	| result |
	result := OrderedCollection new.
	super bindingTypes do:
		[:each |
		result add: each.
		each isRelativeType ifTrue: [result add: each]].
	^result
]

{ #category : #accessing }
RelativeUpdateCommand >> lockKeyFields [
	"Am I updating non-relative (and non-lock key) fields.  If not, this will be empty though my rows may have such fields."
	
	^lockKeyFields
]

{ #category : #accessing }
RelativeUpdateCommand >> relativeFields [
	^relativeFields
]

{ #category : #accessing }
RelativeUpdateCommand >> row: aDatabaseRow [
	"Find the relative fields whose new and old values we will write for this row.  A primary key field cannot be a relative field so we need only check the #fieldsNeedingUpdate: fields.  If we are not changing a relative field, we are not writing either its new value or its old value.
	We only write lock fields if we are writing at least one non-relative field.  We do not check whether all lockKey fields generate or not but assume the user does not want lock key fields written when there are no non-relative fields being updated, even if they supplied a new lockKey field value.
	Here alone we cannot use lockkeyFields being emty if we only update relatrive fields because here is where we see if we doing that or not"

	| updatesOnlyRelativeFields |
	relativeFields := OrderedCollection new.
	lockKeyFields := OrderedCollection new.
	updatesOnlyRelativeFields := true.
	super row: aDatabaseRow.
	(self fieldsNeedingUpdate: row) do:
		[:each | each type isRelativeType
				ifTrue: [relativeFields add: each]
				ifFalse: [each isLockKey ifFalse:
						[updatesOnlyRelativeFields := false]]].
	updatesOnlyRelativeFields
		ifTrue: [aDatabaseRow revertLockKeyFields]
		ifFalse: [lockKeyFields := aDatabaseRow lockKeyFields].
	"If there are lock key fields, they will always be incremented from the retrieved row. We need to exclude them
	if there are no changed normal fields in the row, then we return only the changed relative fields."
	"EVEN IF WE WERE writing all fields, not just changed ones, i.e. not shouldUpdateOnlyChangedFields, we would still want to suppress lockField update if only relative field values had changed.  Also the computation of normal fields from calling this and vice versa creates issues of circularity -  we call super in other methods and so on"
]

{ #category : #'bound values' }
RelativeUpdateCommand >> singleRowBindings [
	"Insert a binding for the relative field's old value after each relative field's (new value) binding."

	| basicBindings relativeFieldBindings relativeFieldIndex rowBindings boundFields |
	basicBindings := super singleRowBindings.	"This includes trailing lock keys, which we will remove if unused."
	relativeFields isEmpty ifTrue: [^basicBindings].
	relativeFieldBindings := Array new: relativeFields size.
	"Put relative fields' corresponding oldValues into the relativeFieldBindings array."
	1 to: relativeFields size do:
		[:columnNumber || relativeField |
		relativeField := relativeFields at: columnNumber.
		relativeFieldBindings
			at: columnNumber
			put: (row
					oldVersionAt: relativeField
					ifAbsent: [relativeField type nilOldValueEquivalent])].
	"Now merge the basicBindings and relativeFieldBindings into their proper orders."
	boundFields := self singleRowBoundFields.	"(or, does >>arrayBoundFields work better?)"
	relativeFieldIndex := 0.
	"If we will not be using the where clause lock keys already in the basic bindings, reduce our array size."
	rowBindings := Array new: basicBindings size + relativeFieldBindings size.
	1 to: boundFields size do:
		[:boundFieldIndex || boundField |
		boundField := boundFields at: boundFieldIndex.
		rowBindings
			at: boundFieldIndex + relativeFieldIndex
			put: (basicBindings at: boundFieldIndex).
		boundField type isRelativeType ifTrue:
			[relativeFieldIndex := relativeFieldIndex + 1.
			rowBindings
				at: boundFieldIndex + relativeFieldIndex
				put: (relativeFieldBindings at: relativeFieldIndex)]].
	"The lock field where-clause values, if any, belong at the end of our array and are the trailing basicBindings values.
	However, if there are ONLY relative field updates, don't include the lock fields in the where clause. They have
	already been excluded from the singleRowBindings, via >>fieldsNeedingUpdate."
	self lockKeyFields isEmpty ifFalse:
		[0 to: basicBindings size - boundFields size - 1 do:
			[:i || index |
			index := rowBindings size - i.
			rowBindings at: index put: (basicBindings at: basicBindings size - i)]].
	^rowBindings
]
