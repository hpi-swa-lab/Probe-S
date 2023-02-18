Class {
	#name : #PRBTestBytecodeProbe,
	#superclass : #PRBBytecodeProbe,
	#instVars : [
		'block'
	],
	#category : #'BasicProbes-Tests'
}

{ #category : #accessing }
PRBTestBytecodeProbe >> block [

	^ block
]

{ #category : #accessing }
PRBTestBytecodeProbe >> block: anObject [

	block := anObject.
]

{ #category : #recording }
PRBTestBytecodeProbe >> record: aValue in: aContext [

	self block value: aValue.
]
