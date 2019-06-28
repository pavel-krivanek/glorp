Extension { #name : #Object }

{ #category : #'*GlorpExtensions-glorp' }
Object >> asGlorpExpression [
	^GlorpHelper glorpConstantExpressionClass for: self.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> asGlorpExpressionOn: anExpression [

	^self asGlorpExpression.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> asGlorpExpressionOn: anExpression basedOn: aMessageArchiver withUltimateBase: aBaseExpression [

	^self asGlorpExpression.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpBasicSize [
	^self basicSize.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpCanHaveDescriptorDirectly [
	"This should be called just #glorpCanHaveDescriptor.  I suspect the calling code was originally receiver isBehavior or: [receiver #glorpCanHaveDescriptorDirectly] and then it was simplified to be this, with subclasses overriding as needed, but the method was not renamed.  Allowing non-classes to have descriptors means that we can have several different class models for e.g. Association (in DictionaryMappings) or String (in DirectTo*Mappings), each specific to their owning mapping."

	^self isBehavior
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpIsCollection [

	^false.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpPostFetch: aSession [
	"This is a selector that objects can implement in order to receive notification when Glorp has read them."
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpPostFetchValidate: aSession [
	"This allows us to do post-read notification of the objects. Note that if this method explicitly returns a false, then we will treat that as meaning that the object is invalid and should not be read. Yes, this is kind of a hack."
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpPostWrite: aSession [
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpPreWrite: aSession [
	"This is a selector that objects can implement in order to receive notification when Glorp is about to write them. Only objects that have pending modifications will receive this notice. However, note that because of that, the data to be written will have already been calculated before this method is called, which makes it difficult to use this to update the method. If you want to put in audit information (e.g. the time at which the object was written, the associated username) then you probably want to use a generator associated with the field instead. See, for example GlorpRecordWithUpdate in the test suite."
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpPrintSQLOn: aCommand [

	self printOn: aCommand.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpPrintSelectSQLOn: aCommand [

	self glorpPrintSQLOn: aCommand.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpRealObject [
	"Return self.  Ensure instantiation of a proxy:  use #glorpRealObjectIfNone: to avoid forced instantiation.  (On compilers which inline #yourself, that method will not force instantiation despite having the same Smalltalk implementation as this method;  see also #yourSelf.)"

	^self
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> glorpRealObjectIfNone: aBlock [
	"Return the real object but do NOT force instantiation of a proxy; instead, evaluate the block on the uninstantiated proxy, returning the result (use #glorpRealObject to force instantiation)."

	^self
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> isGlorpExpression [
	^false.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> isGlorpProxy [
	^false.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> needsWork: aString [

	^self.
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> todo [
	"marker"
]

{ #category : #'*GlorpExtensions-glorp' }
Object >> yourSelf [
	"See #glorpRealObject's comment for this method's purpose.
	To be deprecated due to
		- ease of misreading/mistyping it as #yourself;
		- imposes #perform:with: overhead that glorpRealObject avoids;
		- duplication with #glorpRealObject (and related realObject* methods).
	self deprecated: #(#version '8.3.1' #sunset '10' #use #glorpRealObject)."

	^self
]
