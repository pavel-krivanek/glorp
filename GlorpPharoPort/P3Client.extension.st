Extension { #name : #P3Client }

{ #category : #'*GlorpPharoPort' }
P3Client >> suggestedDefaultTimeZone [

	^ 'CET'
]

{ #category : #'*GlorpPharoPort' }
P3Client >> timezone [

	^ properties at: 'TimeZone'
]

{ #category : #'*GlorpPharoPort' }
P3Client >> timezone: aTimeZone [

	^ properties at: 'TimeZone' put: aTimeZone
]
