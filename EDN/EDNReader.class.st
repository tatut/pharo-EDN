"
I read Extensible Data Notation from an input stream.

- in:    
- read 
 
>>> EDNReader new in: aReadStream; read 
  

"
Class {
	#name : #EDNReader,
	#superclass : #Object,
	#instVars : [
		'in'
	],
	#classVars : [
		'WhitespaceCharacterSet'
	],
	#category : #EDN
}

{ #category : #'as yet unclassified' }
EDNReader class >> whitespaceCharacters [ 
	"Return the set of whitespace characters in EDN"
	WhitespaceCharacterSet ifNotNil: [ ^ WhitespaceCharacterSet  ].
	WhitespaceCharacterSet := Set new.
	WhitespaceCharacterSet 
		add: Character space;
		add: Character cr;
		add: Character lf;
		add: Character tab;
		add: $,.
	^ WhitespaceCharacterSet 
]

{ #category : #accessing }
EDNReader >> in: aReadStream [
  in := aReadStream 
]

{ #category : #reading }
EDNReader >> read [
	"Read EDN data from input"
	self skipWhitespace.
	
]

{ #category : #'private - reading' }
EDNReader >> readEscapeSequence [
  | ch |
  ch := in next.
  ch = $\ ifTrue: [ ^ $\ ].
  ch = $n ifTrue: [ ^ Character cr ].
  ch = $t ifTrue: [ ^ Character tab ].
  ch = $" ifTrue: [ ^ $" ].
  "FIXME: support them all"
  Error signal: 'Unrecognized escape sequence'.
		
]

{ #category : #'private - reading' }
EDNReader >> readString [
	"Read a string in double quotes"
	^ String streamContents: [ :out |
		  | ch |
		  [ in peek = $" ] whileFalse: [ 
			  ch := in next.
			  ch = $\ 
			    ifTrue: [ out nextPut: self readEscapeSequence ] 
			    ifFalse: [ out nextPut: ch ] ].
		 in next. "read the end doublequote" ]
]

{ #category : #'private - reading' }
EDNReader >> skipWhitespace [ 
	"Skip any whitespace characters"
	| ws |
  ws := self class whitespaceCharacters.
	[ ws includes: in peek ] whileTrue: [ in next ]
]
