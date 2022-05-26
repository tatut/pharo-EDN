Extension { #name : #UUID }

{ #category : #'*EDN' }
UUID >> writeEDNTo: out [
	out << '#uuid "'; << self printString; << '"'
]
