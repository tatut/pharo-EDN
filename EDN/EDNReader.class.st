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
		'in',
		'tagHandlers',
		'applyTagHandlers'
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

{ #category : #'as yet unclassified' }
EDNReader >> handle: aTagName with: aBlock [ 
  "Register block to handle tag. Block is invoked with 2 arguments: the tag and the data."
 	tagHandlers at: aTagName put: aBlock
]

{ #category : #accessing }
EDNReader >> in: aReadStream [
  in := aReadStream 
]

{ #category : #'private - reading' }
EDNReader >> initialize [ 
	super initialize.
	applyTagHandlers := true.
	tagHandlers := Dictionary new.
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

{ #category : #'private - reading' }
EDNReader >> lookingAtDigit [
	| ch | 
	ch := in peek.
	ch ifNil: [ ^ false ].
	^ ch isDigit
]

{ #category : #'private - reading' }
EDNReader >> lookingAtLetter [
	| ch | 
	ch := in peek.
	ch ifNil: [ ^ false ].
	^ ch isLetter
]

{ #category : #accessing }
EDNReader >> lookingAtNumber [
	"Check if we are looking at a number.	
	 Answer with boolean. Stream position is unchanged."
	| pos ch |
	pos := in position.
	
	self lookingAtDigit ifTrue: [ ^ true ].
	
	ch := in peek.
	(ch = $-) | (ch = $+) 
	  ifTrue: [ 
		 in next. "consume +/- character"
		 in peek isDigit ifTrue: [ 
			in position: pos. 
			^ true ]].
	^ false

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
	ch = $# ifTrue: [ ^ self readDispatch ].
	ch = $" ifTrue: [ ^ self readString ].
	ch = $: ifTrue: [ ^ self readKeyword ].
	ch = ${ ifTrue: [ ^ self readMap ].
	ch = $[ ifTrue: [ ^ self readVector ].
   ch = $( ifTrue: [ ^ self readList ].
	ch = $\ ifTrue: [ ^ self readCharacter ].
		
	"Read number, starting with +/- or digit"
	self lookingAtNumber ifTrue: [ ^ self readNumber ].
	
	(self class isSymbolFirstCharacter: ch) ifTrue: [ ^ self readSymbol ].
	
	"Can't determine what to dispatch, signal parse error"
  ^ Error signal: 'Unrecognized dispatch character: ',ch asString.
]

{ #category : #'as yet unclassified' }
EDNReader >> readCharacter [
  "Read a named character or unicode"
  | ch1 ch2 name |
  in next. "consume \ char"
  ch1 := in next.
  ch2 := in peek.

  "next character is not digit or letter, this is a single character like: \c"
  ch2 ifNil: [ ^ ch1 ].
  (ch2 isLetter | ch2 isDigit) ifFalse: [ ^ ch1 ].
 
  "First character is u and next is letter or digit, read a unicode escape"
  in position: in position - 1.
  (ch1 = $u & (ch2 isLetter | ch2 isDigit)) ifTrue: [ ^ self readUnicodeCharacter ].

  
  "this is a named character"  
  name := self readWord.
  name = 'tab' ifTrue: [ ^ Character tab ].
  name = 'newline' ifTrue: [ ^ Character lf ].
  name = 'return' ifTrue: [ ^ Character cr ].
  name = 'space' ifTrue: [ ^ Character space ].
  Error signal: 'Unrecognized character name: ', name.
]

{ #category : #'as yet unclassified' }
EDNReader >> readCustomTaggedElement: tag [
	applyTagHandlers 
	ifTrue: [ 
		| handler |
		handler := tagHandlers at: tag ifAbsent: [ Error signal: 'Unregistered custom tag: ', tag asString ].
		^ handler value: tag value: self read ]
	ifFalse: [ ^ EDNTagged new tag: tag; data: self read; yourself ]
]

{ #category : #'private - reading' }
EDNReader >> readDispatch [ 
  "Read something starting with # dispatch character."
  | dispatch tag |
  in next.
  dispatch := in peek.
  dispatch = $_ ifTrue: [ ^ self readIgnore ].
  dispatch = ${ ifTrue: [ ^ self readSet ].

  "a tagged element"
  in position: in position - 1.
  tag := self readKeyword allButFirst. "read keyword and remove colon"
  tag = 'uuid' ifTrue: [ ^ UUID fromString: self read ].
  tag = 'inst' ifTrue: [ ^ DateAndTime readFrom: self read readStream ].
  ^ self readCustomTaggedElement: tag
]

{ #category : #'private - reading' }
EDNReader >> readEscapeSequence [
  | ch |
  ch := in next.
  "PENDING: should turn this into dictionary lookup?"
  ch = $\ ifTrue: [ ^ $\ ].
  ch = $n ifTrue: [ ^ Character lf ].
  ch = $r ifTrue: [ ^ Character cr ].
  ch = $t ifTrue: [ ^ Character tab ].
  ch = $f ifTrue: [ ^ Character newPage ].
  ch = $b ifTrue: [ ^ Character backspace ].
  ch = $" ifTrue: [ ^ $" ].
  ch = $' ifTrue: [ ^ $' ].
  ch = $\ ifTrue: [ ^ $\ ].
  "FIXME: support them all"
  Error signal: 'Unrecognized escape sequence'.
		
]

{ #category : #'as yet unclassified' }
EDNReader >> readIgnore [ 
	in next. "consume _ character"
	self suppressTagHandlers: [ self read ]. "read next item and don't invoke tag handlers"
	^ self read 
]

{ #category : #'private - reading' }
EDNReader >> readKeyword [
	"Read a keyword."
	| part1 part2 |
	in next. "consume the colon"
	part1 := self readSymbol.
	in peek = $/ 
	  ifTrue: [ 
		in next. "consume the slash"	
		(self class isSymbolFirstCharacter: in peek) ifFalse: [ Error signal: 'Illegal keyword name part start characted: ', in peek asString ].
		part2 := self readSymbol.
		"PENDING: should create an EDNKeyword class that interns instances.
	   Don't want to intern with smalltalk selectors symbols."
		^ (':',part1,'/',part2) asSymbol ]
    ifFalse: [
	   ^ (':',part1) asSymbol ] 
]

{ #category : #'as yet unclassified' }
EDNReader >> readList [
	| lst |
	lst := LinkedList new.
	in next. "consume ( character"
	[ self skipWhitespace. in peek = $) ] whileFalse: [ 
		lst add: self read 
	].
   in next. "consume ) character"
   ^ lst
]

{ #category : #'private - reading' }
EDNReader >> readMap [ 
	| m | 
	in next. "consume starting brace"
	m := Dictionary new.
	[ self skipWhitespace. in peek = $} ] whileFalse: [ 
	  | key val |
	  key := self read.
	  self skipWhitespace.
	  val := self read.
	  m at: key put: val.
	 ].
  in next. "consume ending brace"
	^ m

	
	
]

{ #category : #'private - reading' }
EDNReader >> readNumber [
	| sign integerPart decimalPart decimals |
	sign := 1.
	in peek = $+ ifTrue: [ in next ].
	in peek = $- ifTrue: [ sign := -1. in next ].
	
	integerPart := 0.
	[ self lookingAtDigit ] whileTrue: [ integerPart := integerPart * 10 + (in next digitValue) ].

  in peek = $. ifTrue: [ 
	  in next. "we have a decimal part"
     decimals := 1.
     decimalPart := 0.
     [ self lookingAtDigit ] whileTrue: [ 
	     decimalPart := decimalPart * 10 + (in next digitValue). 
	     decimals := decimals * 10 ]	.
	  ^ sign * (integerPart + (decimalPart/decimals) asFloat)  
	 ]
  ifFalse: [  ^ sign * integerPart ]

]

{ #category : #'private - reading' }
EDNReader >> readSet [
  "Read a set"
  | set |
  in next. "consume { character"
  set := Set new. 
  [ self skipWhitespace. in peek = $} ] whileFalse: [ set add: self read ].
  in next. "consume } character"
  ^ set
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

{ #category : #'private - reading' }
EDNReader >> readSymbol [
	"Read a symbol (characters)"
	^ ByteSymbol streamContents: [ :out |
		 out nextPut: (in next). "1st character is the symbol start char"
		 [ self class isSymbolCharacter: in peek ] whileTrue: [ 
			out nextPut: (in next) ]. 
		]
]

{ #category : #'as yet unclassified' }
EDNReader >> readUnicodeCharacter [
 "Read a unicode character escape"
  in next. "consume the u character"
  ^ ('16r', (in next: 4)) asNumber
]

{ #category : #'private - reading' }
EDNReader >> readVector [
	| v | 
	in next. "consume starting bracket"
	v := OrderedCollection new.
	[ self skipWhitespace. in peek = $] ] 
    whileFalse: [ v add: self read ]. 
  in next. "consume ending bracket"
	^ v

	
	
]

{ #category : #'private - decoding' }
EDNReader >> readWord [ 
  ^ String streamContents: [ :out |
	  [ self lookingAtLetter ] whileTrue: [ out << in next ]
	 ]
]

{ #category : #'private - reading' }
EDNReader >> skipWhitespace [ 
	"Skip any whitespace characters and comments"
	| ws ch |
  ws := self class whitespaceCharacters.
	[ ch := in peek.
	  (ch = $;) | (ws includes: ch) ] whileTrue: [ 
	ch := in next.
	ch = $; ifTrue: [ in skipTo: Character cr ]
	 ]
]

{ #category : #'as yet unclassified' }
EDNReader >> suppressTagHandlers: duringBlock [ 
 | oldValue ret |
 oldValue := applyTagHandlers.
 applyTagHandlers := false.
 ret := duringBlock value.
 applyTagHandlers := oldValue.
 ^ ret
]
