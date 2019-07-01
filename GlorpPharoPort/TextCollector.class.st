Class {
	#name : #TextCollector,
	#superclass : #Object,
	#instVars : [
		'strings',
		'currentString'
	],
	#category : #GlorpPharoPort
}

{ #category : #initialization }
TextCollector >> cr [ 

	strings add: currentString.
	currentString := String new.
]

{ #category : #initialization }
TextCollector >> initialize [ 

	super initialize.
	strings := OrderedCollection new.
	currentString := String new.
]

{ #category : #initialization }
TextCollector >> show: aString [

	currentString := currentString, aString.
]

{ #category : #initialization }
TextCollector >> value [ 
	
	^ (strings joinUsing: String cr), currentString
]
