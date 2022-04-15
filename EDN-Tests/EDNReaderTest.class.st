Class {
	#name : #EDNReaderTest,
	#superclass : #TestCase,
	#category : #'EDN-Tests'
}

{ #category : #tests }
EDNReaderTest >> testReadString [
  | in s |
  in := ReadStream on: 'hello \n and \"goodbye\""'.
  s := EDNReader new in: in; readString.
  self assert: s equals: 'hello 
 and "goodbye"'
]

{ #category : #tests }
EDNReaderTest >> testSkipWhitespace [
	| in |	
	in := ReadStream on: '  , 
	 hello'.
  EDNReader new in: in; skipWhitespace.
  self assert: in next equals: $h.

]
