Class {
	#name : #EDNReaderTest,
	#superclass : #TestCase,
	#category : #'EDN-Tests'
}

{ #category : #'meta-object-protocol' }
EDNReaderTest >> read: aString [ 
	^ EDNReader new in: (ReadStream on: aString); read 
]

{ #category : #tests }
EDNReaderTest >> testBoolean [
	"Read true/false"
	self assert: (self read: 'true,,') equals: true.
	self assert: (self read: 'false"then a string"') equals: false.
	 

]

{ #category : #tests }
EDNReaderTest >> testNil [
	"Read nil"
	self assert: (self read: 'nil{:then "a-map"}') equals: nil 
]

{ #category : #tests }
EDNReaderTest >> testReadString [
  | in s |
  in := ReadStream on: '"hello \n and \"goodbye\""'.
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

{ #category : #tests }
EDNReaderTest >> testSymbol [
	self assert: (self read: 'hello"world') equals: #hello.
	self assert: (self read: '<a:foobar-baz&friends   ') 
	     equals: #'<a:foobar-baz&friends'.
	self assert: (self read: 'a123') equals: #a123.  
]
