Extension { #name : #Login }

{ #category : #'*GlorpPharoPort' }
Login >> databaseName [
	"connect string looks like hostname:portNumber_db-name.
	:portNumber is optional"
	
	| str portIndex index dbIndex |
	
	databaseName == nil
		ifFalse: [^ databaseName].
	databaseName == nil
		ifTrue: [str := self connectString.
			portIndex := index := str indexOf: $:.
			dbIndex := str indexOf: $_.
			index = 0
				ifTrue: [index := dbIndex].
			databaseName := str copyFrom: dbIndex + 1 to: str size.
			^ databaseName]
]

{ #category : #'*GlorpPharoPort' }
Login >> databaseName: aDatabaseName [
	databaseName := aDatabaseName
]

{ #category : #'*GlorpPharoPort' }
Login >> discardPassword [

	password := nil
]

{ #category : #'*GlorpPharoPort' }
Login >> encodingStrategy [
	^encodingStrategy
]

{ #category : #'*GlorpPharoPort' }
Login >> encodingStrategy: anEncodingStrategy [
	encodingStrategy := anEncodingStrategy.
]

{ #category : #'*GlorpPharoPort' }
Login >> host [
	"connect string looks like hostname:portNumber_db-name.
	:portNumber is optional"
	| str portIndex index dbIndex |
	host == nil
		ifFalse: [^ host].
	host == nil
		ifTrue: [str := self connectString.
			portIndex := index := str indexOf: $:.
			dbIndex := str indexOf: $_.
			index = 0 ifTrue: [index := dbIndex].
			host := index > 0
				ifTrue: [ str copyFrom: 1 to: index - 1 ].
			^ host]
]

{ #category : #'*GlorpPharoPort' }
Login >> host: aHost [
	host := aHost.
]

{ #category : #'*GlorpPharoPort' }
Login >> port [
	"connect string looks like hostname:portNumber_db-name.
	:portNumber is optional"
	| str portIndex index dbIndex |
	port == nil
		ifFalse: [^ port].
	port == nil
		ifTrue: [str := self connectString.
			portIndex := index := str indexOf: $:.
			dbIndex := str indexOf: $_.
			index = 0
				ifTrue: [index := dbIndex].
			port := portIndex = 0
						ifTrue: [self platform defaultPort asString]
						ifFalse: [(str copyFrom: portIndex + 1 to: dbIndex - 1) asString].
			^ port]
]

{ #category : #'*GlorpPharoPort' }
Login >> port: aPort [
	port := aPort.
]
