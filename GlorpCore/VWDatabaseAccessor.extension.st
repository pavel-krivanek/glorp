Extension { #name : #VWDatabaseAccessor }

{ #category : #'*GlorpCore' }
VWDatabaseAccessor >> initializePreparedStatementCache [
	"The preparedStatements cache holds only GlorpPreparedStatement instances.  As there is no descriptor-system-related collection of classes to be managed, and no session, we have no need of a CacheManager to contain this class, so use an UnmanagedCache."

	| policy |
	policy := CachePolicy default.
	policy numberOfElements: 20.
	policy expiryAction: #notifyAndRemove.
	preparedStatements := UnmanagedCache new.
	preparedStatements cachePolicy: policy.
]
