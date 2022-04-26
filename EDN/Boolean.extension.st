Extension { #name : #Boolean }

{ #category : #'*EDN' }
Boolean >> writeEDNTo: out [
	out << self printString
]
