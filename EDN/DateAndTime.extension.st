Extension { #name : #DateAndTime }

{ #category : #'*EDN' }
DateAndTime >> writeEDNTo: out [
	out << '#inst "'; << self printString; << '"'
]
