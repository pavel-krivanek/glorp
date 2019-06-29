"
GlorpItemWithQty works with a table having a ""relative field"", that is a field whose true value is irrelevant to the client, who only needs to add or subtract from whatever that column holds. A relatvie field allows for blind incrementing and decrementing, where even optimistic locking is unecessary, eliminating the need for round trips (if the lock were to detect a stale cache).

Instance Variables:
	id	<Integer>	The item id (pkey).
	name <String>	The item name.
	qty	<Integer>	The number of items currently presumed in stock.
	totalSales <Double> The total revenue from sales (perhaps renamed to #totalRevenue).


"
Class {
	#name : #GlorpItemWithQty,
	#superclass : #Object,
	#instVars : [
		'id',
		'name',
		'qty',
		'totalSales'
	],
	#category : #'GlorpTestModels-GlorpTest-Domain Models'
}

{ #category : #'VisualWorks metadata' }
GlorpItemWithQty class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
GlorpItemWithQty >> id [
	^id
]

{ #category : #accessing }
GlorpItemWithQty >> id: anInteger [
	id := anInteger.
]

{ #category : #accessing }
GlorpItemWithQty >> name [
	^name
]

{ #category : #accessing }
GlorpItemWithQty >> name: aString [
	name := aString.
]

{ #category : #printing }
GlorpItemWithQty >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: id printString.
	aStream nextPut: $,.
	aStream nextPutAll: name printString.
	aStream nextPut: $,.
	aStream nextPutAll: qty printString.
	aStream nextPut: $,.
	aStream nextPutAll: totalSales printString.
	aStream nextPut: $).
]

{ #category : #accessing }
GlorpItemWithQty >> qty [
	^qty
]

{ #category : #accessing }
GlorpItemWithQty >> qty: anInteger [
	qty := anInteger.
]

{ #category : #accessing }
GlorpItemWithQty >> totalSales [
	^totalSales
]

{ #category : #accessing }
GlorpItemWithQty >> totalSales: aDouble [
	totalSales := aDouble.
]
