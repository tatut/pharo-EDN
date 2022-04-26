Class {
	#name : #EDNReaderTest,
	#superclass : #TestCase,
	#category : #'EDN-Tests'
}

{ #category : #'meta-object-protocol' }
EDNReaderTest >> read: aString [ 
	^ EDNReader new in: (ReadStream on: aString); read 
]

{ #category : #'meta-object-protocol' }
EDNReaderTest >> reader: aString [ 
	^ EDNReader new in: (ReadStream on: aString); yourself
]

{ #category : #tests }
EDNReaderTest >> testBoolean [
	"Read true/false"
	self assert: (self read: 'true,,') equals: true.
	self assert: (self read: 'false"then a string"') equals: false.
	 

]

{ #category : #tests }
EDNReaderTest >> testKeyword [
	self assert: (self read: ':user/name') equals: #':user/name'.
	self assert: (self read: ':my-keyword') equals: #':my-keyword'.
]

{ #category : #tests }
EDNReaderTest >> testNil [
	"Read nil"
	self assert: (self read: 'nil{:then "a-map"}') equals: nil 
]

{ #category : #tests }
EDNReaderTest >> testRead [
  | user |
  user := (self read: '{
 :user/id #uuid "81592ec4-cf11-4eb1-bf04-27b28d1cced6"
 :user/name "Foo Barsky" 
 :user/roles #_"skip me" #{:admin}
 :user/config {:theme :dark} ; this is a comment
 :user/joined-at #inst "2022-04-25T16:15:19.315-00:00"
}').

  self assert: (user at: #':user/id') class equals: UUID.
  self assert: (user at: #':user/name') equals: 'Foo Barsky'.
  self assert: (user at: #':user/config') equals: (Dictionary with: #':theme' -> #':dark').
  self assert: (user at: #':user/roles') equals: (Set with: #':admin').
  self assert: (user at: #':user/joined-at') year equals: 2022.
]

{ #category : #tests }
EDNReaderTest >> testReadDispatch [
   self assert: (self read: '#uuid "81592ec4-cf11-4eb1-bf04-27b28d1cced6"') 
        equals: (UUID fromString: '81592ec4-cf11-4eb1-bf04-27b28d1cced6').
   self assert: (self read: '#inst "2022-04-25T11:15:19.315-00:00"') 
        equals: (DateAndTime fromString: '2022-04-25T11:15:19.315-00:00').
   self should: [ (self read: '#unknown "thing"') ] raise: Error 
        whoseDescriptionIncludes: 'Unregistered'
		  description: 'Unregistered custom tag, should throw exception.'.
	self assert: ((self reader: '#my "thing"') handle: 'my' with: [ :_tag :data | data asUppercase ]; read)
	     equals: 'THING'

]

{ #category : #tests }
EDNReaderTest >> testReadMap [
	self assert: (self read:'  { :price  42.5,
	   "quantity"  10}') equals: (Dictionary with: (#':price'->42.5) with: ('quantity'->10)).
	self assert: (self read:'{    }') equals: Dictionary empty.
	self assert: (self read:'{foo bar}') equals: (Dictionary with: #foo->#bar).
	self assert: (self read:'{:nest {:me {:harder true}}}')
	     equals: (Dictionary with: 
	               #':nest'->(Dictionary with: 
	                 #':me'->(Dictionary with: 
	                   #':harder'->true)))
]

{ #category : #tests }
EDNReaderTest >> testReadNumber [
	self assert: (self read: '-420.69') equals: -420.69.
	self assert: (self read: '+666') equals: 666.
	self assert: (self read: '12.456') equals: 12.456
]

{ #category : #tests }
EDNReaderTest >> testReadSet [
	self assert: (self read:' #{"foo" #_"bar" "baz"}') equals: (Set with: 'foo' with: 'baz').
	self assert: (self read: '#{    }') equals: Set empty

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
EDNReaderTest >> testReadVector [
	self assert: (self read:'  [ 1 2,  
		 -3.4 ]') equals: ({1 . 2 . -3.4 } asOrderedCollection).
	self assert: (self read:'[[[1]] :<-deep]')
	     equals: (OrderedCollection 
	              with: (OrderedCollection with: (OrderedCollection with: 1))
	              with: #':<-deep')

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
