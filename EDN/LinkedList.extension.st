Extension { #name : #LinkedList }

{ #category : #'*EDN' }
LinkedList >> writeEDNTo: out [
  | first |
  first := true.
  out << '('.
  self do: [ :item |
	 first ifFalse: [ out << ' ' ].
	 first := false.
	 item writeEDNTo: out ].
  out << ')'.
]
