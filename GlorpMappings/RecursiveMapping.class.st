"
I exist to let knitting behaviour be partitioned between me and RecursiveBuilder in the development of Glorp recursion.
"
Class {
	#name : #RecursiveMapping,
	#superclass : #ToManyMapping,
	#category : #GlorpMappings
}

{ #category : #'VisualWorks metadata' }
RecursiveMapping class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
		'superclassNamespace' 'Glorp'
	)

]

{ #category : #mapping }
RecursiveMapping >> knitFromBuilder: sourceBuilder toBuilder: targetBuilder [
	"We assume we are being alsoFetched and are otherwise ignored, marked as non-readable, so we ignore canRead (TO BE REVIEWED).  My rows more immediately knit to each other than to the related builder instance, it being an ancestor of the recursion.  We assume we are either a simple collection being read from a chain or that the immediately preceeding row or ancestral row is known to the ancestor of recursion and we will be assigned to it.  Either way, the source builder holds the structure we are building up and must know how to assign us to it."

	sourceBuilder instance perform: self attribute setSelector with: targetBuilder instance.
]
