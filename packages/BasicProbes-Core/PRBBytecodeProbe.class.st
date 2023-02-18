Class {
	#name : #PRBBytecodeProbe,
	#superclass : #PRBProbe,
	#instVars : [
		'sourceRange'
	],
	#category : #'BasicProbes-Core'
}

{ #category : #'instance creation' }
PRBBytecodeProbe class >> on: aMethodReference from: startIndex to: endIndex [ 
	| newProbe |
	newProbe := self new.
	
	newProbe 
		methodReference: aMethodReference;
		sourceRange: (startIndex to: endIndex).

	^ newProbe
]

{ #category : #installing }
PRBBytecodeProbe >> installInto: aWrapper [
	| concretePCAndCompiledCode |
	concretePCAndCompiledCode := self stopPC.
	aWrapper 
		at: concretePCAndCompiledCode first 
		for: concretePCAndCompiledCode second 
		addBytecodeProbe: self.
]

{ #category : #recording }
PRBBytecodeProbe >> record: anObject in: aContext [ 
	self subclassResponsibility.
]

{ #category : #accessing }
PRBBytecodeProbe >> sourceRange [

	^ sourceRange
]

{ #category : #accessing }
PRBBytecodeProbe >> sourceRange: anObject [

	sourceRange := anObject.
]

{ #category : #private }
PRBBytecodeProbe >> stopPC [

	| compiledMethod pcCodeAndRange compiledSegments abstractPCAndCompiledCode |
	compiledMethod := self methodReference compiledMethod.
	compiledMethod isPRBWrapper ifTrue: [
		compiledMethod := compiledMethod compiledMethod].
	"The range may lie within a block closure, then we can not do much"
	compiledSegments := {compiledMethod} , compiledMethod nestedBlockMethods.	
	pcCodeAndRange := compiledSegments gather: [:compiledCode | | sourceMap ranges |
		sourceMap := compiledMethod debuggerMap abstractSourceMapForMethod: compiledCode.
		ranges := sourceMap associations select: [:assoc |
			(assoc value includes: self sourceRange start) and: [assoc value includes: self sourceRange stop]].
		ranges collect: [:range | {range key . compiledCode} -> range value]]. 
	abstractPCAndCompiledCode := (pcCodeAndRange detectMin: [:assoc | assoc value size]) key.

	^ {abstractPCAndCompiledCode second concretePCForAbstractPC: abstractPCAndCompiledCode first . abstractPCAndCompiledCode second}
]
