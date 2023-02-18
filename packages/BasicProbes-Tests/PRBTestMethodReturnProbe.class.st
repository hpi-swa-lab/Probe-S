Class {
	#name : #PRBTestMethodReturnProbe,
	#superclass : #PRBMethodProbe,
	#instVars : [
		'block'
	],
	#category : #'BasicProbes-Tests'
}

{ #category : #accessing }
PRBTestMethodReturnProbe >> block [

	^ block
]

{ #category : #accessing }
PRBTestMethodReturnProbe >> block: anObject [

	block := anObject.
]

{ #category : #accessing }
PRBTestMethodReturnProbe >> recordReturnOf: aMethodReference with: returnValue [

	block value: returnValue
]
