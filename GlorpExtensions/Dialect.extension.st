Extension { #name : #Dialect }

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> addSeconds: seconds to: aTime [

	self isVisualWorks ifTrue: [^ Time fromSeconds: aTime asSeconds + seconds].
	self isDolphin ifTrue: [^ self addTimeForDolphin: aTime seconds: seconds].
	self isGNU ifTrue: [^ aTime addSeconds: seconds].
	self isVisualAge ifTrue: [^Time fromSeconds: aTime asSeconds + seconds].
	self isPharo ifTrue: [^aTime addSeconds: seconds].
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> addTimeForDolphin: aTime seconds: seconds [

	"Dolphin's time/date arithmetic is pretty weak, especially for timestamps. Hack around it. This is likely only to work for seconds <24 hours"

	| result |

	^ aTime class == Time
		ifTrue: [Time fromMilliseconds: (aTime asMilliseconds + (seconds * 1000)) \\ 86400000.]
		ifFalse: [
			result := self timestampClass date: aTime date
				time: (self addTimeForDolphin: aTime time seconds: seconds).
			(seconds > 0 and: [result time < aTime time.])
				ifTrue: [result date: (result date addDays: 1).].
			(seconds < 0 and: [result time > aTime time.])
				ifTrue: [result date: (result date addDays: -1).].
			^ result
		]
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> argumentCountFor: aBlock [
	Dialect isVisualWorks ifTrue: [^aBlock numArgs].
	Dialect isObjectStudio ifTrue: [^aBlock numArgs].
	Dialect isVisualAge ifTrue: [^aBlock argumentCount].
	Dialect isDolphin ifTrue: [^aBlock argumentCount].
	Dialect isSqueak ifTrue: [^aBlock numArgs].	"argumentCount would also work"
	Dialect isGNU ifTrue: [^ self error: 'not implemented yet'].
	Dialect isPharo ifTrue: [^aBlock argumentCount].
	self error: 'not implemented yet'.
	^ self
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> basicIsDolphin [
	^Smalltalk includesKey: #DolphinSplash.
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> basicIsGNU [
	^Smalltalk includesKey: #BindingDictionary.
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> basicIsObjectStudio [
	^Smalltalk class name == #SmalltalkClass.
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> basicIsSqueak [

	^ (Smalltalk respondsTo: #vmVersion) and: [(Smalltalk vmVersion copyFrom: 1 to: 6) = 'Squeak'.]
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> basicIsVisualAge [

	^ Smalltalk class name == #EsSmalltalkNamespace
	"	| sys |
	sys := Smalltalk at: #System ifAbsent: [^false].
	(sys respondsTo: #vmType) ifFalse: [^false].
	^sys vmType = 'ES'"
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> basicIsVisualWorks [
	^Smalltalk class name == #NameSpace
"We've decided to trust that no other Smalltalk dialect uses NameSpace (e.g. in VASmalltalk, Smalltalk class name returns #EsSmalltalkNamespace).  However if we ever need a better check, one option is to add (or replace with) the following:
	Smalltalk selectors do:
		[:s | (s == #version and:
			[(Smalltalk version copyFrom: 1 to: 11) = 'VisualWorks']) 
		    	ifTrue: [^true]].
	^false"
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> basicIsVisualWorksWithoutNamespaces [
	^Smalltalk class name == #SystemDictionary
]

{ #category : #'*GlorpExtensions-numbers' }
Dialect class >> coerceToDoublePrecisionFloat: aNumber [

	self isVisualWorks ifTrue: [^ aNumber asDouble].
	self isVisualAge ifTrue: [^ aNumber asFloat].
	self isSqueak ifTrue: [^aNumber asFloat].
	self isGNU ifTrue: [^ aNumber asFloatD].
	^ aNumber
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> determineDialect [
	self basicIsDolphin ifTrue: [^ dialectName := #Dolphin].
	self basicIsGNU ifTrue: [^ dialectName := #GNU].
	self basicIsVisualAge ifTrue: [^ dialectName := #VisualAge].
	self basicIsVisualWorks ifTrue: [^ dialectName := #VisualWorks].
	self basicIsSqueak ifTrue: [^ dialectName := #Squeak].
	self basicIsObjectStudio ifTrue: [^dialectName := #ObjectStudio].
	self basicIsVisualWorksWithoutNamespaces ifTrue: [^dialectName := #VisualWorks].
	self error: 'I don''t know what dialect this is'.
	^ self
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> dialectName [

	dialectName isNil ifTrue: [self determineDialect.].
	^ dialectName
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> dialectVersion [
	"Glorp does not need to consult dialect versions at the moment.  This method is currently made available purely as a precaution, in case Glorp experimenters should wish to add a dialect-version-requiring feature."

	self isVisualWorks ifTrue: [^self dialectName, ' ' , (self smalltalkAt: #'Kernel.SystemUtils') systemVersion].
	self isDolphin ifTrue: [^self dialectName, ' ' , (self smalltalkAt: #SessionManager) current versionString].
	self isObjectStudio ifTrue: [^self dialectName , ' ' , (self smalltalkAt: #'ObjectStudio.Globals.System') version].
	self isSqueak ifTrue: [^(self smalltalkAt: #SystemVersion) current version].
	self isVisualAge ifTrue:
		[(self	"This only works if VAAssist is loaded;  find a more robust way"
			smalltalkAt: #VisualAgeAssistApp
			ifAbsent: [^self dialectName, ' Unknown Version']) releaseName].
	^self dialectName, ' Unknown Version'
]

{ #category : #'*GlorpExtensions-numbers' }
Dialect class >> doublePrecisionFloatClass [

	self isVisualWorks ifTrue: [^ self smalltalkAt: #Double].
	self isGNU ifTrue: [^ self smalltalkAt: #FloatD].
	^ Float
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> error [
	"If VASmalltalk 8 has switched entirely to ANSI exceptions, perhaps we can retire this.
Meanwhile, it is used in some Glorp on:do: calls."

	^Dialect isVisualAge
		ifTrue: [Error, (Dialect smalltalkAt: #ExError)]
		ifFalse: [Error]
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> fitHashIntoSmallInteger: aNumber [
	"Truncate the number to fit into smallinteger range. Mostly useful for ObjectStudio where hashes have to be 16 bits or less"
	^Dialect isObjectStudio ifTrue: [aNumber hash] ifFalse: [aNumber].
]

{ #category : #'*GlorpExtensions-numbers' }
Dialect class >> fixedPointClass [
	Dialect isVisualWorks ifTrue: [^self smalltalkAt: #FixedPoint].
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> garbageCollect [
	Dialect isVisualWorks ifTrue: [^ ObjectMemory quickGC].
	Dialect isObjectStudio ifTrue: [^(self smalltalkAt: #System) garbageCollect].
	Dialect isGNU ifTrue: [^ ObjectMemory globalGarbageCollect].
	Dialect isVisualAge ifTrue: [^ (self smalltalkAt: #System) globalGarbageCollect].
	Dialect isSqueak ifTrue: [^Smalltalk garbageCollect].
	Dialect isPharo ifTrue: [^Smalltalk garbageCollect].
	self error: 'not implemented yet'.
	^ self
]

{ #category : #'*GlorpExtensions-forward references' }
Dialect class >> glorpConstantExpressionClass [
	^ConstantExpression.
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> instVarNameFor: aName [

	Dialect isGNU ifTrue: [^ aName asSymbol].
	^ aName asString
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> isBlock: anObject [
	"Return true if this is a block"
	self isVisualAge ifTrue: [^anObject isKindOf: (self smalltalkAt: #Block)].
	^anObject class == [] class.
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> isDolphin [

	^ self dialectName = #Dolphin
]

{ #category : #'*GlorpExtensions-numbers' }
Dialect class >> isFloatingPoint: aNumber [
	^aNumber class == self doublePrecisionFloatClass or: [aNumber class == Float or: [aNumber class == self smallDoublePrecisionFloatClass]].
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> isGNU [

	^ self dialectName = #GNU
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> isHeadless [
	"Dialect isHeadless"
	Dialect isVisualWorks ifTrue: [^ (Smalltalk at: 'WindowingSystem' ifAbsent: [^true]) isHeadless].
	self error: 'not implemented yet'.
	^ self
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> isNamespaceAware [
	isNamespaceAware isNil ifTrue: [isNamespaceAware := self basicIsVisualWorks].
	^isNamespaceAware
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> isObjectStudio [

	^ self dialectName = #ObjectStudio
]

{ #category : #'*GlorpExtensions-numbers' }
Dialect class >> isScaleOf: aNumber lessThanOrEqualTo: aScale [
	^aNumber class == self fixedPointClass and: [aNumber scale <= aScale].
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> isSqueak [

	^ self dialectName = #Squeak
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> isVWWithNameSpaces [
	"For cases where our hacked backports of asQualifiedReference and etc. to VW3 are not sufficient."

	^self isVisualWorks and: [self isNamespaceAware]
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> isVisualAge [

	^ self dialectName = #VisualAge
]

{ #category : #'*GlorpExtensions-identifying' }
Dialect class >> isVisualWorks [

	^ self dialectName = #VisualWorks
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> lookedUpNames [
	lookedUpNames isNil ifTrue: [lookedUpNames := IdentityDictionary new].
	^lookedUpNames.
]

{ #category : #'*GlorpExtensions-class lookup' }
Dialect class >> lookupClassNamed: aString inContextOf: aClass [
	"Look up the class by name, but use the namespace of the class. Mostly useful if we're trying to guess from unqualified names in dialects with namespaces."
	^self lookupClassNamed: aString inContextOf: aClass ifAbsent: [nil].
]

{ #category : #'*GlorpExtensions-class lookup' }
Dialect class >> lookupClassNamed: aString inContextOf: aClass ifAbsent: aBlock [
	"Look up the class by name, but use the namespace of the class. Mostly useful if we're trying to guess from unqualified names in dialects with namespaces."

	self isVisualWorks ifFalse: [^self smalltalkAt: aString ifAbsent: aBlock].
	^aClass environment at: aString ifAbsent:
		[aClass namesAndBindingsDo:
			[:varName :variable | aString asSymbol == varName ifTrue: [^variable value]].
			aBlock value]
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> newDateWithYears: years months: months days: days [

	(self isVisualWorks or: [self isSqueak]) ifTrue: [^ Date newDay: days monthNumber: months year: years].
	self isGNU ifTrue: [^ Date newDay: days monthIndex: months year: years].
	self isVisualAge ifTrue: [^Date newDay: days monthIndex: months year: years].
	self isObjectStudio ifTrue: [^Date newDay: days imonth: months year: years].
	self isPharo ifTrue: [^Date newDay: days month: months year: years].
	self error: 'not implemented'.
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> newTimeWithHours: hours minutes: minutes seconds: seconds milliseconds: milliseconds [

	self isGNU ifTrue: [^ Time fromSeconds: hours * 60 * 60 + (minutes * 60) + seconds].
	(self isVisualWorks or: [self isSqueak]) ifTrue: [^ Time fromSeconds: hours * 60 * 60 + (minutes * 60) + seconds].
	self isVisualAge
		ifTrue: [
			^ Time fromMilliseconds: ((hours * 60 * 60) + (minutes * 60) + seconds) * 1000 + milliseconds
		].
	self isObjectStudio ifTrue: [^Time hour: hours minute: minutes second: seconds millisecond: milliseconds].
	self isPharo ifTrue: [^ Time fromSeconds: hours * 60 * 60 + (minutes * 60) + (milliseconds / 10000)].
	self error: 'Not implemented yet'.
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> newTimestampFromDate: aDate time: aTime [

	self isVisualWorks ifTrue: [^self timestampClass fromDate: aDate andTime: aTime].
	self error: 'Not yet implemented'.
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> newTimestampWithYears: years
	months: months
	days: days
	hours: hours
	minutes: minutes
	seconds: seconds
	milliseconds: millis
	offset: offset [

	| date time ts |

	self isGNU
		ifTrue: [
			^ self timestampClass year: years
				month: months
				day: days
				hour: hours
				minute: minutes
				second: seconds
				offset: ((Dialect smalltalkAt: #Duration) fromSeconds: offset)
		].
	date := self newDateWithYears: years months: months days: days.
	time := self newTimeWithHours: hours minutes: minutes seconds: seconds milliseconds: millis.
	self isVisualWorks
		ifTrue: [^ (self timestampClass fromDate: date andTime: time) addMilliseconds: millis].
	self isSqueak
		ifTrue: [ts := self timestampClass date: date time: time.
			ts time addSeconds: (millis / 1000) asInteger.
				^ts]. 
	self isVisualAge
		ifTrue: [^(Dialect smalltalkAt: #AbtTimestamp) date: date time: time].
	self isObjectStudio ifTrue: [^self timestampClass newDate: date time: time].
	self isPharo ifTrue: [^self timestampClass 
			year: years
			month: months
			day: days
			hour: hours
			minute: minutes
			second: seconds
			nanoSecond: millis * 1000000
			offset: (Duration seconds: offset)].
	self error: 'not implemented'.
	^ self
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> quitTheImage [
	"Quit the entire image"

	self isVisualWorks ifTrue: [^(self smalltalkAt: #ObjectMemory) quit].
	self isSqueak ifTrue: [^(self smalltalkAt: #SmalltalkImage) current snapshot: false andQuit: true].
	self isDolphin ifTrue: [^(self smalltalkAt: #SessionManager) current quit].
	self isVisualAge ifTrue: [^  self error: 'Not implemented yet'.].
	self isObjectStudio ifTrue: [^ self error: 'Not implemented yet'.].
	self isGNU ifTrue: [^ self error: 'Not implemented yet'.].
	self error: 'not implemented yet'.
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> readFixedPointFrom: aString [

	self isVisualWorks ifTrue: [^ (self smalltalkAt: #FixedPoint) readFrom: (ReadStream on: aString)].
	(self isDolphin or: [self isSqueak]) ifTrue: [^ Number readFrom: (ReadStream on: aString , 's')].
	self isGNU
		ifTrue: [
			^ (Number readFrom: (ReadStream on: aString)) asScaledDecimal:
				aString size - (aString indexOf: $. ifAbsent: [aString size.])
		].
	self isVisualAge ifTrue: [ ^(self smalltalkAt: #Decimal) fromString: aString].
	self isObjectStudio ifTrue: [^(self smalltalkAt: #Decimal) newString: aString].
	self isPharo ifTrue: [^ Number readFrom: (ReadStream on: aString , 's')].
	self error: 'not implemented'.
	^ self
]

{ #category : #'*GlorpExtensions-class lookup' }
Dialect class >> removeObsolete [

	| workingNames |
	self isVisualWorks ifFalse: [^self].
	(workingNames := self lookedUpNames) copy keysAndValuesDo: 
		[:key :value |
		value isObsolete ifTrue: [workingNames removeKey: key ifAbsent: nil]]
]

{ #category : #'*GlorpExtensions-private' }
Dialect class >> reset [
	"self reset"
	lookedUpNames := nil.
	timestampClass := nil.
	dialectName := nil.
]

{ #category : #'*GlorpExtensions-numbers' }
Dialect class >> singlePrecisionFloatClass [
	^ Float
]

{ #category : #'*GlorpExtensions-numbers' }
Dialect class >> smallDoublePrecisionFloatClass [
	self isVisualWorks
		ifTrue: 
			[^self smalltalkAt: #SmallDouble ifAbsent: [self doublePrecisionFloatClass]].
	^self doublePrecisionFloatClass
]

{ #category : #'*GlorpExtensions-class lookup' }
Dialect class >> smalltalkAssociationAt: aName [

	^ self smalltalkAssociationAt: aName ifAbsent: [self error: 'element not found'.]
]

{ #category : #'*GlorpExtensions-class lookup' }
Dialect class >> smalltalkAssociationAt: aName ifAbsent: aBlock [

	self isVisualWorks ifTrue: [^ aName asQualifiedReference].
	^ Smalltalk associationAt: aName asSymbol ifAbsent: aBlock
]

{ #category : #'*GlorpExtensions-class lookup' }
Dialect class >> smalltalkAt: aName [

	^ self smalltalkAt: aName ifAbsent: [self error: 'element not found'].
]

{ #category : #'*GlorpExtensions-class lookup' }
Dialect class >> smalltalkAt: aName ifAbsent: aBlock [
	"We may look these names up a lot, so cache them in a small, local dictionary.  In VisualWorks (only, at the moment), we check isObsolete on cached NmeSpaces and Classes."

	| cached value symbol |
	symbol := aName asSymbol.
	cached := self lookedUpNames at: symbol ifAbsent: [nil].
	cached isNil ifFalse: 
		[self isVisualWorks
			ifTrue:
				[((cached isBehavior or: [cached isNameSpace]) and: [cached isObsolete]) 
					ifTrue: [self removeObsolete]
					ifFalse: [^cached]]
			ifFalse: [^cached]].
	value := self isVisualWorks
		ifTrue: 
			[((symbol includes: $.)
				ifTrue: [symbol asStrictReference]
				ifFalse: [symbol asQualifiedReference]) valueOrDo: 
					[^aBlock value]]
		ifFalse: [Smalltalk at: symbol ifAbsent: aBlock].
	self lookedUpNames at: symbol put: value.
	^value
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> supportsMillisecondsInTimeStamps [

	self isGNU ifTrue: [^ false].
	self isVisualWorks ifTrue: [^ true].
	self isDolphin ifTrue: [^ true].
	self isVisualAge ifTrue: [^ true].
	self isObjectStudio ifTrue: [^true].
	self error: 'not yet implemented'.
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> supportsMillisecondsInTimes [

	self isGNU ifTrue: [^ false].
	self isVisualWorks ifTrue: [^ false].
	self isSqueak ifTrue: [^false].
	self isDolphin ifTrue: [^ true].
	self isVisualAge ifTrue: [^ true].
	self isObjectStudio ifTrue: [^true]. "Sort of. Supports hundredths of a second"
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> timeOffsetFromGMT [

	self isVisualWorks ifTrue: [^(self smalltalkAt: #TimeZone) default secondsFromGMT / (60 * 60)].
	self isGNU ifTrue: [Time timezoneBias / (60 * 60)].
	^ 0
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> timestampClass [

	timestampClass == nil ifFalse: [^ timestampClass].
	Dialect isVisualWorks ifTrue: [^ timestampClass := self smalltalkAt: #Timestamp].
	Dialect isObjectStudio ifTrue: [^timestampClass := self smalltalkAt: #Timestamp].
	Dialect isGNU ifTrue: [^ timestampClass := self smalltalkAt: #DateTime].
	(Dialect isSqueak or: [Dialect isDolphin.])
		ifTrue: [^ timestampClass := self smalltalkAt: #TimeStamp].
	Dialect isVisualAge ifTrue: [^ timestampClass := self smalltalkAt: #Timestamp].
	Dialect isPharo ifTrue: [^ timestampClass := self smalltalkAt: #Timestamp].
	self error: 'Not yet implemented'.
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> timestampNow [

	Dialect isGNU ifTrue: [^ self timestampClass dateAndTimeNow].
	Dialect isSqueak ifTrue: [^ self timestampClass current].
	Dialect isVisualWorks ifTrue: [^ self timestampClass now].
	Dialect isDolphin ifTrue: [^ self timestampClass current].
	Dialect isVisualAge ifTrue: [^ self timestampClass now].
	Dialect isObjectStudio ifTrue: [^self timestampClass now].
	Dialect isPharo ifTrue: [^self timestampClass current].
	self error: 'Not yet implemented'.
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> timestampNowUTC [

	Dialect isVisualWorks ifTrue: [^ (self smalltalkAt: #Timestamp) fromSeconds: Time secondClock].
	Dialect isDolphin ifTrue: [self error: 'not supported'].
	Dialect isGNU ifTrue: [^ self timestampClass utcDateAndTimeNow].
	self error: 'Not yet implemented'.
	^ self
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> tokensBasedOn: aString in: stringToTokenize [

	self isVisualWorks ifTrue: [^ stringToTokenize tokensBasedOn: aString first].
	self isSqueak ifTrue: [^ stringToTokenize findTokens: aString].
	self isDolphin ifTrue: [^ stringToTokenize subStrings: aString].
	self isVisualAge ifTrue: [^ (stringToTokenize subStrings: aString first)].
	self isObjectStudio ifTrue: [^(stringToTokenize asArrayOfSubstringsDelimiter: aString first)].
	self isGNU ifTrue: [^ stringToTokenize subStrings: aString first].
	self error: 'not implemented yet'.
	^ self
]

{ #category : #'*GlorpExtensions-dates' }
Dialect class >> totalSeconds [

	self isGNU ifTrue: [^ Time utcSecondClock].
	self isVisualAge ifTrue: [^ (self smalltalkAt: #AbtTimestamp) now totalSeconds].
	^ Time totalSeconds
]

{ #category : #'*GlorpExtensions-general portability' }
Dialect class >> weakValueDictionaryClass [

	Dialect isVisualWorks ifTrue: [^self smalltalkAt: #EphemeralValueDictionary].
	Dialect isSqueak ifTrue: [^self smalltalkAt: #WeakValueDictionary].
	Dialect isPharo ifTrue: [^self smalltalkAt: #WeakValueDictionary].
	self error: 'Not yet implemented for this dialect'.
]
