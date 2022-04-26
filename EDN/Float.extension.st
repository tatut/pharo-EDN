Extension { #name : #Float }

{ #category : #'*EDN' }
Float >> writeEDNTo: out [
  out << self printString.

]
