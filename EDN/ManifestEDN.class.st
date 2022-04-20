"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestEDN,
	#superclass : #PackageManifest,
	#category : #'EDN-Manifest'
}

{ #category : #'code-critics' }
ManifestEDN class >> ruleReturnsBooleanAndOtherRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#EDNReader #read #false)) #'2022-04-20T17:52:20.906346+03:00') )
]
