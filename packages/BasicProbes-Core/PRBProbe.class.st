Class {
	#name : #PRBProbe,
	#superclass : #PRBAbstractProbe,
	#instVars : [
		'methodReference',
		'probeId'
	],
	#category : #'BasicProbes-Core'
}

{ #category : #accessing }
PRBProbe >> methodReference [

	^ methodReference
]

{ #category : #accessing }
PRBProbe >> methodReference: anObject [

	methodReference := anObject.
]

{ #category : #accessing }
PRBProbe >> probeId [

	^ self
]
