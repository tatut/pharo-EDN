Extension { #name : #Character }

{ #category : #'*EDN' }
Character >> writeEDNTo: out [
   self = Character space ifTrue: [ out << '\space'. ^ nil ].
	self = Character cr ifTrue: [ out << '\return'. ^ nil ].
	self = Character lf ifTrue: [ out << '\newline'. ^ nil ].
	self = Character tab ifTrue: [  out << '\tab'. ^ nil ].
	(self isLetter | self isDigit) ifTrue: [ out << '\'; << self. ^ nil ].
	out << '\u'; << (self asInteger printStringBase: 16 nDigits: 4)
]
