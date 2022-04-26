Class {
	#name : #EDNWriterTest,
	#superclass : #TestCase,
	#category : #'EDN-Tests'
}

{ #category : #writing }
EDNWriterTest >> testWriteCharacter [
  self assert: (self write: 160 asCharacter)
       equals: '\u00A0'.
  self assert: (self write: $G) equals: '\G'.
  self assert: (self write: Character tab) equals: '\tab'.
]

{ #category : #writing }
EDNWriterTest >> testWriteList [
  self assert: (self write: (LinkedList with: Character space with: 'testing'))
       equals: '(\space "testing")'
]

{ #category : #writing }
EDNWriterTest >> testWriteMap [
  self assert: (self write: (Dictionary with: #':foo' -> 42 with: #bar -> 'baz'))
       equals: '{:foo 42 bar "baz"}'
]

{ #category : #writing }
EDNWriterTest >> testWriteVector [
  self assert: (self write: (OrderedCollection with: 666 with: 0.25))
       equals: '[666 0.25]'
]

{ #category : #writing }
EDNWriterTest >> write: anObject [
	^ String streamContents: [ :out | EDNWriter new out: out; write: anObject ]
]
