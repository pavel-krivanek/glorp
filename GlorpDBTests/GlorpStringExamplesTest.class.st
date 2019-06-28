"
Test the trimming, writing and reading of encoded strings.
"
Class {
	#name : #GlorpStringExamplesTest,
	#superclass : #GlorpMappingDBTest,
	#category : #'GlorpDBTests-GlorpTest'
}

{ #category : #'VisualWorks metadata' }
GlorpStringExamplesTest class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #tests }
GlorpStringExamplesTest >> checkTrimString: aTwoByteString ForEncoding: connectionEncoding [
	"For platforms that support nvarchars, both the connection and the server have two encodings, one for VARCHAR and one for NVARCHAR.  All can in principle be different and the parameter encoding can differ from all four."

	| byteStr example allRows query encodedOriginal encodedResult asciiResult |
	"Ideally, this clearing code would be in setUp not run repeatedly within tests and we would assign ids in a sensible way (e.g. we could just have an ordinary serial type), not make our example always id 1 and therefore risk clashes if we do not run this just before registering.  We'd have to read specific rows by id, not just read (all) and check there's only one, but it would be cleaner."
	[session accessor executeSQLString: 'DELETE FROM STRING_EXAMPLES']
		on: Error do: [:ex |Transcript show: ex printString; cr].
	"Set the connection encoding."
	self setEncodingTo: connectionEncoding.
	encodedOriginal := aTwoByteString.
	byteStr := 'o123456789o123456789o123456789'.
	example := (GlorpStringExamples new)
		id: 1;
		byteString: byteStr;
		encodedString: encodedOriginal;
		yourself.
	session inUnitOfWorkDo: [session register: example].

	"Clear the cache, otherwise Glorp will use cached version of the written row, which has the full length string."
	session initializeCache.
	session releaseReaper.
	query := Query read: GlorpStringExamples.
	allRows := session execute: query.
	self assert: allRows size = 1.
	asciiResult := allRows first byteString.
	self assert: asciiResult size = 20.
	
	session system platformSupportsNVarcharColumns ifFalse: [^self].
	"National varchar (NVARCHAR) encoding."
	encodedResult := allRows first encodedString.
	self assert: encodedResult notNil.
	((session system tableNamed: 'STRING_EXAMPLES') fieldNamed: 'encodedString') type measuresStringFieldWidthsInBytes
		ifTrue: [self assert: false description: 'Our assumption all supporting servers use utf16 is false?']
		ifFalse:
			[self assert: encodedResult size = 20.
			self assert: encodedResult = (encodedOriginal first: 20)].
]

{ #category : #utility }
GlorpStringExamplesTest >> setDB2Encoding: anEncoding [
	"NOTE: StreamEncoder>>encodingUsesWideChars: expects the encoding to Uppercase.
	If the encoding is in lowercase, error and status messages, which use this, will fail to decode."

	| anAccessor |
	anAccessor := session accessor.
	anAccessor connection disconnect.
	"Set encoding before connecting."
	anAccessor encoding: anEncoding.
	anAccessor connection encoding: anEncoding.
	anAccessor connection connect.
]

{ #category : #utility }
GlorpStringExamplesTest >> setEncodingTo: anEncoding [

	session accessor platform isOraclePlatform
		ifTrue: 
			[anEncoding asUppercase asSymbol =  #UTF16
				ifTrue: [^self setOracleEncodingUTF16]
				ifFalse: [^self setOracleEncodingUTF8]].
	session accessor platform isPostgreSQLPlatform
		ifTrue: [^self setPostgresEncoding: anEncoding].
	"The rest should work for SQL Server, DB2 and MySQL."
	session accessor platform isMySQLPlatform
		ifTrue: [^self setMySQLEncoding: anEncoding].
	session accessor platform isDB2Platform
		ifTrue: 
			[anEncoding asUppercase asSymbol =  #UTF16
				ifTrue: [^self setDB2Encoding: #UCS_2].
			anEncoding asUppercase asSymbol =  #UTF8
				ifTrue: [^self setDB2Encoding: #UTF_8]].
	^self setServerEncoding: anEncoding
]

{ #category : #utility }
GlorpStringExamplesTest >> setMySQLEncoding: anEncoding [
	"NOTE: StreamEncoder>>encodingUsesWideChars: expects the encoding to Uppercase.
	If the encoding is in lowercase, error and status messages, which use this, will fail to decode."

	| anAccessor enc |
	anAccessor := session accessor.
	"Set encoding before connecting."
	enc := (anEncoding asString copyReplaceAll: 'utf' with: 'utf_') asSymbol.
	enc := (enc = #utf_16) ifTrue: [#ucs_2] ifFalse: [enc].
	anAccessor encoding: enc.
	anAccessor connection encoding: enc.
]

{ #category : #utility }
GlorpStringExamplesTest >> setOracleEncodingUTF16 [
	| anAccessor |
	anAccessor := session accessor.
	anAccessor connection oracleEncodingId: 1000.
	anAccessor encoding: #utf_16.
	"Set UTF16 as unicode encoding (applies to specifically unicode-designated columns)."
	anAccessor connection oracleUnicodeEncodingId: 1000.
	anAccessor connection disconnect.
	anAccessor connection unicodeEncoding: nil.		"Force this to be reset."
	anAccessor connection connect.
]

{ #category : #utility }
GlorpStringExamplesTest >> setOracleEncodingUTF8 [
	| anAccessor |
	anAccessor := session accessor.
	anAccessor connection oracleEncodingId: 871.
	anAccessor encoding: #utf_8.
	"Set UTF8 as unicode encoding (applies to specifically unicode-designated columns)."
	anAccessor connection oracleUnicodeEncodingId: 871.
	anAccessor connection disconnect.
	anAccessor connection unicodeEncoding: nil.		"Force this to be reset."
	anAccessor connection connect.
]

{ #category : #utility }
GlorpStringExamplesTest >> setPostgresEncoding: anEncoding [

	| anAccessor |
	anAccessor := session accessor.
	anAccessor encoding: anEncoding.
	"anAccessor connection disconnect."
	"Set encoding before connecting.
	anAccessor connection clientEncoding: anEncoding.
	anAccessor connection encoding: anEncoding."
	"anAccessor connection connect."
]

{ #category : #utility }
GlorpStringExamplesTest >> setServerEncoding: anEncoding [
	"NOTE: StreamEncoder>>encodingUsesWideChars: expects the encoding to be in Uppercase.  If the encoding is in lowercase, error and status messages, which use this, will fail to decode."

	| anAccessor |
	anAccessor := session accessor.
	anAccessor connection disconnect.
	"Set encoding before connecting."
	anAccessor encoding: anEncoding.
	anAccessor connection encoding: anEncoding.
	anAccessor connection connect.
]

{ #category : #running }
GlorpStringExamplesTest >> testTrimStringForAscii [
	"NOTE: StreamEncoder>>encodingUsesWideChars: expects the encoding symbol to be in uppercase."

	session accessor platform isPostgreSQLPlatform ifTrue: [^self].
	#('ABCDEFGHIJKLMNOPQRSTUVWXYZ ABCDEFGHIJKLMNOPQRSTUVWXYZ') do:
		[:aByteString | self checkTrimString: aByteString ForEncoding: #ascii]
]

{ #category : #running }
GlorpStringExamplesTest >> testTrimStringForUtf16 [
	"NOTE: StreamEncoder>>encodingUsesWideChars: expects the encoding to be in uppercase.
	Note 2: Oracle NCHAR and NVARCHAR2 are character-oriented, meaning that NVARCHAR(20) stores 20 characters, even though Oracle varchar is byte oriented."

	session accessor platform isPostgreSQLPlatform ifTrue: [^self].
	session accessor platform isDB2Platform ifTrue: [^self].
	session accessor platform isMySQLPlatform ifTrue: [^self].
	#('Jane € Cuvée. Jane € Cuvée. Jane € Cuvée. Jane € Cuvée. Jane € Cuvée. Jane € Cuvée.' 	'€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é' 
	'ABCDEFGHIJKLMNOPQRSTUVWXYZ ABCDEFGHIJKLMNOPQRSTUVWXYZ') do:
		[:aTwoByteString |
		self checkTrimString: aTwoByteString ForEncoding: #UTF16.
		session reset].
]

{ #category : #running }
GlorpStringExamplesTest >> testTrimStringForUtf8 [

	session accessor platform isSQLServerPlatform ifTrue: [^self].
	session accessor platform isDB2Platform ifTrue: [^self].
	
	#('Jane € Cuvée. Jane € Cuvée. Jane € Cuvée. Jane € Cuvée. Jane € Cuvée. Jane € Cuvée.' 	'€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é€é' 
	'ABCDEFGHIJKLMNOPQRSTUVWXYZ ABCDEFGHIJKLMNOPQRSTUVWXYZ')
		do: [:aTwoByteString | self checkTrimString: aTwoByteString ForEncoding: #utf8.
				session reset]
]
