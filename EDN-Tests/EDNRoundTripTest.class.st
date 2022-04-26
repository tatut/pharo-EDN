Class {
	#name : #EDNRoundTripTest,
	#superclass : #TestCase,
	#category : #'EDN-Tests'
}

{ #category : #'as yet unclassified' }
EDNRoundTripTest >> roundtrip: anObject [
	| serialized readObject |
	serialized := String streamContents: [ :out |
		EDNWriter new out: out; write: anObject ].
	Transcript show: serialized.
	readObject := EDNReader new in: serialized readStream; read.
	self assert: anObject equals: readObject.
]

{ #category : #tests }
EDNRoundTripTest >> testRoundtrip [ 
  self roundtrip: (Dictionary 
   with: #':foo' -> (Set with: #':bar' with: #':baz')
	with: 'string key' -> (LinkedList with: 42 with: 666.1)
	with: #symbol -> (OrderedCollection with: true with: false with: nil))
]
