Class {
	#name : #PRBTestMethodProbe,
	#superclass : #PRBMethodProbe,
	#instVars : [
		'block'
	],
	#category : #'BasicProbes-Tests'
}

{ #category : #accessing }
PRBTestMethodProbe >> block [

	^ block
]

{ #category : #accessing }
PRBTestMethodProbe >> block: anObject [

	block := anObject.
]

{ #category : #recording }
PRBTestMethodProbe >> recordInvocationOf: aMethodReference on: aReceiver with: arguments [
	
	self block value: aReceiver value: arguments
]
