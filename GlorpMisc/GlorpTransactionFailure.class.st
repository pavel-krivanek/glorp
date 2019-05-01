"
This is the exception we raise if we encounter a database error trying to commit a transaction.

"
Class {
	#name : #GlorpTransactionFailure,
	#superclass : #GlorpError,
	#category : #GlorpMisc
}

{ #category : #accessing }
GlorpTransactionFailure >> defaultMessageText [
	^'Optimistic Lock Conflict'.
]
