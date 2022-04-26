Extension { #name : #OrderedCollection }

{ #category : #'*EDN' }
OrderedCollection >> writeEDNTo: out [
	out << '['.
   firstIndex to: lastIndex do: [ :index | 
	   index > 1 ifTrue: [ out << ' ' ].
		(array at: index) writeEDNTo: out ].
	out << ']'.
]
