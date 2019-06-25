Extension { #name : #Object }

{ #category : #'*GlorpExtensions' }
Object >> asGlorpExpression [
	^GlorpHelper glorpConstantExpressionClass for: self.
]

{ #category : #'*GlorpExtensions' }
Object >> asGlorpExpressionOn: anExpression [

	^self asGlorpExpression.
]

{ #category : #'*GlorpExtensions' }
Object >> asGlorpExpressionOn: anExpression basedOn: aMessageArchiver withUltimateBase: aBaseExpression [

	^self asGlorpExpression.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpBasicSize [
	^self basicSize.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpCanHaveDescriptorDirectly [
	^self isBehavior.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpCopyIn: aDictionary [
	"For non-storeForGlorp objects, just copy normally"
	^self copy.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpEndOfIndexedInstVars [
	"Return the index at which indexed instance variables start. The same as basicSize for most dialects, but funny for ObjectStudio"

	^self basicSize.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpIsBlock [
	^false.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpIsCollection [

	^false.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpPostFetch: aSession [
	"This is a selector that objects can implement in order to receive notification when Glorp has read them."
]

{ #category : #'*GlorpExtensions' }
Object >> glorpPostFetchValidate: aSession [
	"This allows us to do post-read notification of the objects. Note that if this method explicitly returns a false, then we will treat that as meaning that the object is invalid and should not be read. Yes, this is kind of a hack."
]

{ #category : #'*GlorpExtensions' }
Object >> glorpPostWrite: aSession [
]

{ #category : #'*GlorpExtensions' }
Object >> glorpPreWrite: aSession [
	"This is a selector that objects can implement in order to receive notification when Glorp is about to write them. Only objects that have pending modifications will receive this notice. However, note that because of that, the data to be written will have already been calculated before this method is called, which makes it difficult to use this to update the method. If you want to put in audit information (e.g. the time at which the object was written, the associated username) then you probably want to use a generator associated with the field instead. See, for example GlorpRecordWithUpdate in the test suite."
]

{ #category : #'*GlorpExtensions' }
Object >> glorpPrintSQLOn: aCommand [

	self printOn: aCommand.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpPrintSelectSQLOn: aCommand [

	self glorpPrintSQLOn: aCommand.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpRealObject [
	"Return the real object. Will force instantiation of a proxy, even on compilers which inline yourself"
	^self.
]

{ #category : #'*GlorpExtensions' }
Object >> glorpStartOfIndexedInstVars [
	"Return the index at which indexed instance variables start. 1 for most dialects, but funny for ObjectStudio"
	^1.
]

{ #category : #'*GlorpExtensions' }
Object >> isGlorpExpression [
	^false.
]

{ #category : #'*GlorpExtensions' }
Object >> isGlorpProxy [
	^false.
]

{ #category : #'*GlorpExtensions' }
Object >> needsWork: aString [

	^self.
]

{ #category : #'*GlorpExtensions' }
Object >> todo [
	"marker"
]

{ #category : #'*GlorpExtensions' }
Object >> yourSelf [
	"Return the real object. Will force instantiation of a proxy, even on compilers which inline yourself"
	^self.
]