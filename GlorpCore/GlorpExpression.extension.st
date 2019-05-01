Extension { #name : #GlorpExpression }

{ #category : #'*GlorpCore' }
GlorpExpression >> sqlString [
	| command |
	command := QuerySelectCommand new
		useBinding: false;
		session: self ultimateBaseExpression descriptor session.
	self printSQLOn: command withParameters: #().
	^command contents.
]
