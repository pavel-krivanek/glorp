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
			package: 'GlorpCore';
			package: 'GlorpDatabase';
			package: 'GlorpDatabaseTypes';
			package: 'GlorpExpressions';
			package: 'GlorpExtensions';
			package: 'GlorpMappings';
			package: 'GlorpMisc';
			package: 'GlorpQueries';
			package: 'GlorpQueries-Pharo';
			package: 'GlorpUnitOfWork';

			package: 'GlorpPharoPort';

			package: 'GlorpCollectionTypeModels';
			package: 'GlorpDBTests';
			package: 'GlorpDBTypeTests';
			package: 'GlorpTestModels';
			package: 'GlorpTests';

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
