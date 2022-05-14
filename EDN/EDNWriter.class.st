"
I write EDN to a WriteStream.

Main methods: 

- out:     sets the write stream to use
- write:   writes the given object

"
Class {
	#name : #EDNWriter,
	#superclass : #Object,
	#instVars : [
		'out'
	],
	#category : #EDN
}

{ #category : #'as yet unclassified' }
EDNWriter class >> toEDNString: aValue [
	^ String streamContents: [ :o | self new out: o; write: aValue ]
]

{ #category : #accessing }
EDNWriter >> out [

	^ out
]

{ #category : #accessing }
EDNWriter >> out: anObject [

	out := anObject
]

{ #category : #writing }
EDNWriter >> write: anObject [
	anObject writeEDNTo: out
]
