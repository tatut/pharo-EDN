Extension { #name : #UndefinedObject }

{ #category : #'*EDN' }
UndefinedObject >> writeEDNTo: out [
  out << 'nil'
]
