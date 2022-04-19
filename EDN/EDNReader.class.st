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

{ #category : #testing }
EDNReader class >> isSymbolCharacter: ch [
  "check if ch is a symbol character (other than the first)"
  ch ifNil: [ ^ false ].
  ^ ch isLetter | ch isDigit | 
	 (ch = $:) | (ch = $.) | (ch = $*) | (ch = $+) | 
	 (ch = $!) | (ch = $-) | (ch = $_) | (ch = $?) | 
	 (ch = $$) | (ch = $%) | (ch = $&) | (ch = $=) | 
	 (ch = $<) | (ch = $>) 
]

{ #category : #testing }
EDNReader class >> isSymbolFirstCharacter: ch [
  "check if ch is a symbol first character"
  ch ifNil: [ ^ false ].
  ^ ch isDigit not & (self isSymbolCharacter: ch)

]

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

{ #category : #accessing }
EDNReader >> lookingAt: aWord [
	"Check if we are looking at the given word, and the next character after that is not a symbol character.
	Answer with true if the looking at the word (stream position is after the word) or false 
	if not (stream position is unchanged)."
	| pos |
	pos := in position.
	aWord do: [ :c |
		c = in next ifFalse: [ 
			in position: pos.
			^ false ]
	].
	(self class isSymbolCharacter: in peek) ifTrue: [ 
		in position: pos.
		^ false ].
	^ true 
]

{ #category : #'meta-object-protocol' }
EDNReader >> read [
	"Read EDN data from input"
	| ch |
	self skipWhitespace.
	
	"Read constants true/false/nil"
	(self lookingAt: 'true') ifTrue: [ ^ true ].
	(self lookingAt: 'false') ifTrue: [ ^ false ].
	(self lookingAt: 'nil') ifTrue: [ ^ nil ].
	 
	"Not any of those, dispatch on the next character."
	ch := in peek.
	ch = $" ifTrue: [ ^ self readString ].
	
	"check -/+/. as first symbo char, then next one must not be a digit"
	(self class isSymbolFirstCharacter: ch) ifTrue: [ ^ self readSymbol ].
	
	"Can't determine what to dispatch, signal parse error"
  ^ Error signal: 'Unrecognized dispatch character: ',ch asString.
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

{ #category : #'write and read' }
EDNReader >> readString [
	"Read a string in double quotes"
	in next. "read the starting double quote" 
	^ String streamContents: [ :out |
		  | ch |
		  [ in peek = $" ] whileFalse: [ 
			  ch := in next.
			  ch = $\ 
			    ifTrue: [ out nextPut: self readEscapeSequence ] 
			    ifFalse: [ out nextPut: ch ] ].
		 in next. "read the end doublequote" ]
]

{ #category : #'as yet unclassified' }
EDNReader >> readSymbol [
	"Read a symbol (characters)"
	^ ByteSymbol streamContents: [ :out |
		 out nextPut: (in next). "1st character is the symbol start char"
		 [ self class isSymbolCharacter: in peek ] whileTrue: [ 
			out nextPut: (in next) ]. 
		]
]

{ #category : #'as yet unclassified' }
EDNReader >> readSymbolOrReserved [
	"Read a symbol (characters) or one of the constants: nil, true or false"
	| sym |
	sym := String streamContents: [ :out  ]
]

{ #category : #'private - reading' }
EDNReader >> skipWhitespace [ 
	"Skip any whitespace characters"
	| ws |
  ws := self class whitespaceCharacters.
	[ ws includes: in peek ] whileTrue: [ in next ]
]
