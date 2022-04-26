Extension { #name : #String }

{ #category : #'*EDN' }
String >> writeEDNTo: out [
	out << '"'.
	self do: [ :c |
		c asInteger bytesCount > 1 
		ifTrue: [ out << '\u'; << (c asInteger printStringBase: 16) ]
		ifFalse: [ 
			c = $" ifTrue: [ out << '\"' ] ifFalse: [ out << c ]
			 ] ].
   out << '"'.
]
