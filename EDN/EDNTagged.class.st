Class {
	#name : #EDNTagged,
	#superclass : #Object,
	#instVars : [
		'tag',
		'data'
	],
	#category : #EDN
}

{ #category : #accessing }
EDNTagged >> data [

	^ data
]

{ #category : #accessing }
EDNTagged >> data: anObject [

	data := anObject
]

{ #category : #accessing }
EDNTagged >> tag [

	^ tag
]

{ #category : #accessing }
EDNTagged >> tag: anObject [

	tag := anObject
]
