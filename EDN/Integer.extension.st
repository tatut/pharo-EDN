Extension { #name : #Integer }

{ #category : #'*EDN' }
Integer >> writeEDNTo: out [
	out << self printString
]
