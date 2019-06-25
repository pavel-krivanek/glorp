Extension { #name : #ByteArray }

{ #category : #'*GlorpExtensions-testing' }
ByteArray >> glorpIsCollection [
	"For our purposes, these aren't collections, but rather a simple database type"
	^false.
]

{ #category : #'*GlorpExtensions-glorp' }
ByteArray >> glorpPrintSQLOn: aCommand [
	|strm|
	strm := WriteStream on: String new.
	strm nextPutAll: '0x'.
	strm nextPutAll: self asHexString.
	aCommand nextPutAll: strm contents
]
