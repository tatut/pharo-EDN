Extension { #name : #Set }

{ #category : #'*EDN' }
Set >> writeEDNTo: out [
  | first |
  first := true.
  out << '#{'.
  self do: [ :item |
	 first ifFalse: [ out << ' ' ].
	 first := false.
	 item writeEDNTo: out ].
  out << '}'.
]
