Class {
	#name : #Timestamp,
	#superclass : #DateAndTime,
	#category : #GlorpPharoPort
}

{ #category : #adding }
Timestamp >> addMilliseconds: aNumber [

	^ self + aNumber milliSeconds 
]
