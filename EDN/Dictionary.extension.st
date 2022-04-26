Extension { #name : #Dictionary }

{ #category : #'*EDN' }
Dictionary >> writeEDNTo: out [
   | first |
   first := true.
	out << '{'.
	self associationsDo: [ :assoc |
	  first ifFalse: [ out << ' ' ].
	  first := false.
	  assoc key writeEDNTo: out.
	  out << ' '.
	  assoc value writeEDNTo: out.	  
	].
	out << '}'.
]
