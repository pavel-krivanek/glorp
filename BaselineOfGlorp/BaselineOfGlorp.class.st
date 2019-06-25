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

			yourself
		].
]

{ #category : #baselines }
BaselineOfGlorp >> project [
	
	| aProject |
	
	aProject := super project.
	aProject loadType: #atomic.
	^ aProject.
	
]
