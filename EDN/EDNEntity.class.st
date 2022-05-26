Class {
	#name : #EDNEntity,
	#superclass : #ZnStringEntity,
	#category : #EDN
}

{ #category : #accessing }
EDNEntity >> contentType [ 
  ^ ZnMimeType fromString: 'application/edn'

]
