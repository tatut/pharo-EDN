Extension { #name : #ScaledDecimal }

{ #category : #'*EDN' }
ScaledDecimal >> writeEDNTo: out [
  | s |
  s := self numerator asString.
  out << (s copyFrom: 1 to: s size - scale) ;
      << $.;
      << (s allButFirst: s size - scale);
      << $M
]
