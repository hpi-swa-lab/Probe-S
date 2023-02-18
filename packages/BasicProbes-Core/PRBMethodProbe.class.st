Class {
	#name : #PRBMethodProbe,
	#superclass : #PRBProbe,
	#category : #'BasicProbes-Core'
}

{ #category : #'instance creation' }
PRBMethodProbe class >> on: aMethodReference [

	^ self new
		methodReference: aMethodReference;
		yourself
]

{ #category : #installing }
PRBMethodProbe >> installInto: aWrapper [
	aWrapper addBeforeInvocationProbe: self
]

{ #category : #recording }
PRBMethodProbe >> recordInvocationOf: aMethodReference on: aReceiver with: arguments [
	self subclassResponsibility.
]
