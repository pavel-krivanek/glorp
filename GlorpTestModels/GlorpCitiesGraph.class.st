"
CitiesGraph models a link table of cities and neighbor cities, and their distances. Using this class, we can build a recursive query which determines the shortest path between two cities.

Instance Variables:
	city	<GlorpCity> The city where we are.
	nextCity	<GlorpCity>	Another city.
	distance	<Float>	The distance between the cities.

What follows is some preliminary data, and a SQL-only query example, which we would like to accommodate using Glorp. Note that special care is needed when developing recursive queries to ensure that the database server doesn't go into an endless loop--you need to ensure a terminating condition.

conn := PostgresSocketConnection new.
conn username: 'tester';
	password: 'tester';
	environment: 'testing'.
conn connect.

results := OrderedCollection new.

ansBlock := [[(ans:= sess answer) = #noMoreAnswers]
	whileFalse:
		[(ans = #noAnswerStream) ifFalse: [results addAll: ans upToEnd]]].
sess := conn getSession.
sess prepare:  'CREATE TABLE cities
				(id INTEGER PRIMARY KEY, name VARCHAR(25))'.
sess execute.
ansBlock value.

sess prepareWithoutBinding:
	'INSERT INTO cities VALUES(1, ''Boston'');
	INSERT INTO cities VALUES(2, ''New York'');
	INSERT INTO cities VALUES(3, ''Cinncinati'');
	INSERT INTO cities VALUES(4, ''Chicago'');
	INSERT INTO cities VALUES(5, ''St. Louis'');
	INSERT INTO cities VALUES(6, ''Kansas City'');
	INSERT INTO cities VALUES(7, ''Denver'');
	INSERT INTO cities VALUES(8, ''Houston'');
	INSERT INTO cities VALUES(9, ''Dallas'');
	INSERT INTO cities VALUES(10, ''Phoenix'');
	INSERT INTO cities VALUES(11, ''New Orleans'');
	INSERT INTO cities VALUES(12, ''Atlanta'');
	INSERT INTO cities VALUES(13, ''Seattle'');
	INSERT INTO cities VALUES(14, ''Portland'');
	INSERT INTO cities VALUES(15, ''Miami'');
	INSERT INTO cities VALUES(16, ''Baltimore'');
	INSERT INTO cities VALUES(17, ''Nashville'');
	INSERT INTO cities VALUES(18, ''Salt Lake City'');
	INSERT INTO cities VALUES(19, ''Reno'');
	INSERT INTO cities VALUES(20, ''San Francisco'');
	INSERT INTO cities VALUES(21, ''Los Angeles'')'.
sess execute.
ansBlock value.

sess prepare:  'CREATE TABLE cities_graph
				(id INTEGER, link INTEGER, distance FLOAT)'.
sess execute.
ansBlock value.

sess prepareWithoutBinding:
	'INSERT INTO cities_graph VALUES(1, 2, 200);
	INSERT INTO cities_graph VALUES(1, 3, 420);
	INSERT INTO cities_graph VALUES(2, 3, 350);
	INSERT INTO cities_graph VALUES(3, 4, 400);
	INSERT INTO cities_graph VALUES(4, 5,  300);
	INSERT INTO cities_graph VALUES(5, 6, 300);
	INSERT INTO cities_graph VALUES(6, 7, 500);
	INSERT INTO cities_graph VALUES(7, 8, 1000);
	INSERT INTO cities_graph VALUES(7, 10, 300)
	INSERT INTO cities_graph VALUES(7, 18, 360)
	INSERT INTO cities_graph VALUES(8, 9, 400);
	INSERT INTO cities_graph VALUES(9, 10, 600);
	INSERT INTO cities_graph VALUES(10, 11, 2000);
	INSERT INTO cities_graph VALUES(11, 12, 400);
	INSERT INTO cities_graph VALUES(12, 13, 3800);
	INSERT INTO cities_graph VALUES(13, 14, 220);
	INSERT INTO cities_graph VALUES(14, 15, 4000);
	INSERT INTO cities_graph VALUES(15, 16, 1100);
	INSERT INTO cities_graph VALUES(16, 17, 400);
	INSERT INTO cities_graph VALUES(17, 18, 2000);
	INSERT INTO cities_graph VALUES(18, 19, 400);
	INSERT INTO cities_graph VALUES(19, 20, 220);
	INSERT INTO cities_graph VALUES(20, 21, 400);
	INSERT INTO cities_graph VALUES(21, 14, 1200)'.
sess execute.
anssBlock value.

conn disconnect.
conn connect.
sess := conn getSession.
results := OrderedCollection new.
sess prepare:
	'WITH RECURSIVE search_graph(id, link, distance, depth, path, cycle) AS
	(
		SELECT g.id, g.link, g.distance, 1, ARRAY[g.id], false
		FROM cities_graph g
		WHERE g.id = 1
	UNION ALL
		SELECT g.id, g.link, g.distance+sg.distance, sg.depth + 1, path || g.id, g.id = ANY(path)
		FROM cities_graph g, search_graph sg
		WHERE g.id = sg.link AND (NOT cycle) AND (not g.id = 20)
	)
	SELECT * FROM search_graph sg WHERE sg.link = 20'.
sess execute.
ansBlock value.
results.
conn disconnect.



"
Class {
	#name : #GlorpCitiesGraph,
	#superclass : #Object,
	#instVars : [
		'city',
		'nextCity',
		'distance'
	],
	#category : #GlorpTestModels
}

{ #category : #accessing }
GlorpCitiesGraph >> city [

	^city
]

{ #category : #accessing }
GlorpCitiesGraph >> city: anObject [

	city := anObject
]

{ #category : #accessing }
GlorpCitiesGraph >> distance [

	^distance
]

{ #category : #accessing }
GlorpCitiesGraph >> distance: anObject [

	distance := anObject
]

{ #category : #accessing }
GlorpCitiesGraph >> nextCity [

	^nextCity
]

{ #category : #accessing }
GlorpCitiesGraph >> nextCity: anObject [

	nextCity := anObject
]
