constants
sqlTextCurrentServerUTCTimestamp

	^'SELECT SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) FROM DUAL'