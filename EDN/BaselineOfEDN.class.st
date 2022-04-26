Class {
	#name : #BaselineOfEDN,
	#superclass : #BaselineOf,
	#category : #EDN
}

{ #category : #baselines }
BaselineOfEDN >> baseline: spec [ 
	spec for: #common do: [ spec 
		package: 'EDN';
		package: 'EDN-Tests' with: [ spec requires: #('EDN') ];
		group: 'default' with: #('EDN' 'EDN-Tests') ]
]
