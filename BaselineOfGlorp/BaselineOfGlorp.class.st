Class {
	#name : #BaselineOfGlorp,
	#superclass : #BaselineOf,
	#category : 'BaselineOfGlorp'
}

{ #category : #baselines }
BaselineOfGlorp >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		
		self p3: spec.
		
		spec 
			package: 'GlorpMisc';
			package: 'GlorpExtensions';
			package: 'GlorpExpressions';
			package: 'GlorpDatabaseTypes';
			package: 'GlorpQueries';
			package: 'GlorpQueries-Pharo';
			package: 'GlorpDatabase';
			package: 'GlorpCore';
			package: 'GlorpMappings';
			package: 'GlorpUnitOfWork';

			package: 'GlorpPharoPort';

			package: 'GlorpTestModels';
			package: 'GlorpDBTests';
			package: 'GlorpCollectionTypeModels';
			package: 'GlorpTests';
			package: 'GlorpDBTypeTests';
			package: 'Glorp-UDBCSQLite3Platform';

			package: 'P3-Glorp';

			yourself
		].
]

{ #category : #baselines }
BaselineOfGlorp >> neoJSON: spec [

	spec 
		baseline: 'NeoJSON' 
		with: [ spec repository: 'github://svenvc/NeoJSON/repository' ]

]

{ #category : #baselines }
BaselineOfGlorp >> p3: spec [

	self neoJSON: spec.
	self zTimestamp: spec.

	spec package: 'P3'.
	spec package: 'P3-Tests'.

]

{ #category : #baselines }
BaselineOfGlorp >> project [
	
	| aProject |
	
	aProject := super project.
	aProject loadType: #atomic.
	^ aProject.
	
]

{ #category : #baselines }
BaselineOfGlorp >> zTimestamp: spec [

	spec 
		baseline: 'ZTimestamp' 
		with: [ spec repository: 'github://svenvc/ztimestamp/repository' ]

]
