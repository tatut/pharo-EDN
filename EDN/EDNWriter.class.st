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
