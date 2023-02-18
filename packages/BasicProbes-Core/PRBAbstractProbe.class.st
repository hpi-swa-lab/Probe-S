Class {
	#name : #PRBAbstractProbe,
	#superclass : #Object,
	#category : #'BasicProbes-Core'
}

{ #category : #private }
PRBAbstractProbe >> ensurePRBWrapperPresence [

	| methodObject |
	methodObject := self methodReference compiledMethod.
	methodObject isPRBWrapper ifFalse: [
		methodObject := PRBWrapper new 
			methodReference: self methodReference;
			yourself.
		methodObject install].
		
	^ methodObject
]

{ #category : #private }
PRBAbstractProbe >> ifPRBWrapperPresent: aBlock [

	| methodObject |
	methodObject := self methodReference compiledMethod.
	methodObject isPRBWrapper ifTrue: [
		aBlock value: methodObject].
]

{ #category : #installing }
PRBAbstractProbe >> install [
	
	| wrapper |
	wrapper := self ensurePRBWrapperPresence.
	self installInto: wrapper. 
]

{ #category : #installing }
PRBAbstractProbe >> installInto: aWrapper [

	self subclassResponsibility.
]

{ #category : #accessing }
PRBAbstractProbe >> methodReference [

	self subclassResponsibility
]

{ #category : #accessing }
PRBAbstractProbe >> probeId [

	self subclassResponsibility.
]

{ #category : #recording }
PRBAbstractProbe >> record: aValue in: aContext [

	self subclassResponsibility.
]

{ #category : #recording }
PRBAbstractProbe >> recordInvocationOf: aMethodReference on: aReceiver with: arguments [
	self subclassResponsibility.
]

{ #category : #installing }
PRBAbstractProbe >> uninstall [
	
	self ifPRBWrapperPresent: [:wrapper |
		wrapper removeBytecodeProbe: self].
	
]
