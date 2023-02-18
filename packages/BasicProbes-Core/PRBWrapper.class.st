Class {
	#name : #PRBWrapper,
	#superclass : #Object,
	#instVars : [
		'methodReference',
		'previousMethod',
		'beforeInvocationProbes',
		'bytecodeProbes'
	],
	#category : #'BasicProbes-Core'
}

{ #category : #'accessing - managing probes' }
PRBWrapper >> addBeforeInvocationProbe: probe [

	self beforeInvocationProbes add: probe.
]

{ #category : #'accessing - managing probes' }
PRBWrapper >> at: concretePC for: compiledCode addBytecodeProbe: probe [

	self ensureBytecodeProbesFor: compiledCode fits: concretePC.
		
	(self bytecodeProbesFor: compiledCode)
		at: concretePC 
		put: ((self bytecodeProbesFor: compiledCode) at: concretePC) , {probe}

	
]

{ #category : #private }
PRBWrapper >> beforeInvocationProbes [

	^ beforeInvocationProbes
]

{ #category : #private }
PRBWrapper >> bytecodeProbesFor: compiledCode [

	^ bytecodeProbes at: compiledCode ifAbsentPut: [Array new: 1000 withAll: #()]
]

{ #category : #private }
PRBWrapper >> compiledMethod [

	previousMethod ifNotNil: [^ previousMethod].
	^ self methodReference compiledMethod
]

{ #category : #'error handling' }
PRBWrapper >> doesNotUnderstand: aMessage [

	previousMethod ifNotNil: [^ aMessage sendTo: previousMethod].
	super doesNotUnderstand: aMessage
]

{ #category : #private }
PRBWrapper >> ensureBytecodeProbesFor: compiledCode fits: abstractPC [

	(self bytecodeProbesFor: compiledCode) size < abstractPC
		ifTrue: [ | newArray |
			newArray := Array new: abstractPC withAll: #(). 
			newArray copyFrom: bytecodeProbes.
			bytecodeProbes at: compiledCode put: newArray].
]

{ #category : #'initialize-release' }
PRBWrapper >> initialize [

	super initialize.
	beforeInvocationProbes := OrderedCollection new.
	bytecodeProbes := IdentityDictionary new.
]

{ #category : #installing }
PRBWrapper >> install [
	| tempPreviousMethod |
	tempPreviousMethod := self compiledMethod methodClass methodDictionary
		at: self compiledMethod selector.
		
	tempPreviousMethod isPRBWrapper ifTrue: [^ self].
	tempPreviousMethod isCompiledMethod not ifTrue: [
		self error: 'Someone else also wraps methods'].
	previousMethod := tempPreviousMethod.
	self ensureBytecodeProbesFor: previousMethod fits: previousMethod size.
	
	self compiledMethod methodClass methodDictionary
		at: self compiledMethod selector
		put: self.
]

{ #category : #testing }
PRBWrapper >> isPRBWrapper [

	^ true
]

{ #category : #testing }
PRBWrapper >> isPROWrapper [

	^ true
]

{ #category : #accessing }
PRBWrapper >> methodReference [
	
	^ methodReference
]

{ #category : #accessing }
PRBWrapper >> methodReference: aMethodReference [

	methodReference := aMethodReference.
]

{ #category : #running }
PRBWrapper >> notifyProbesBeforeInvocationOn: aReceiver with: arguments [

	self beforeInvocationProbes do: [:probe |
		probe 
			recordInvocationOf: self methodReference
			on: aReceiver
			with: arguments]
]

{ #category : #running }
PRBWrapper >> notifyProbesOfReturn: returnValue [

	self beforeInvocationProbes do: [:probe |
		probe 
			recordReturnOf: self methodReference
			with: returnValue]
]

{ #category : #'accessing - managing probes' }
PRBWrapper >> removeBeforeInvocationProbe: probe [

	self beforeInvocationProbes remove: probe.
	
	self	uninstallIfNoProbesLeft.
]

{ #category : #'accessing - managing probes' }
PRBWrapper >> removeBytecodeProbe: probe [

	bytecodeProbes values do: [:bytecodes | bytecodes withIndexDo: [:element :index |
		bytecodes at: index put: (element copyWithout: probe)]].
	
	self uninstallIfNoProbesLeft.
	
]

{ #category : #running }
PRBWrapper >> run: aSelector with: arguments in: aReceiver [

	| returnValue |
	self shouldRecord ifFalse: [
		^ self compiledMethod valueWithReceiver: aReceiver arguments: arguments].
	
	self notifyProbesBeforeInvocationOn: aReceiver with: arguments.
	
	returnValue := self 
		runSimulated: [self compiledMethod valueWithReceiver: aReceiver arguments: arguments]
		stoppingIn: self compiledMethod.
	
	self notifyProbesOfReturn: returnValue.
	
	^ returnValue
]

{ #category : #running }
PRBWrapper >> runSimulated: aBlock stoppingIn: compiledCode [

	| probesAtBytecode bytecodeStops |
	probesAtBytecode := #().
	bytecodeStops := self bytecodeProbesFor: compiledCode.

	^ thisContext
		runSimulated: aBlock
		contextAtEachStep: [:context | | contextMethod |
			contextMethod := context method.
			"potentially optimize by only looking up the bytecode ranges once"
			contextMethod = compiledCode ifTrue: [
				context actualStackSize > 0 ifTrue: [
					probesAtBytecode do: [:probe | 
						probe record: context top in: context]].
				context top isBlock ifTrue: [
					context push: (self wrapBlock: context pop)].
				probesAtBytecode := bytecodeStops at: context pc.
				context markQuickStep]].
]

{ #category : #accessing }
PRBWrapper >> shouldRecord [

	^ true
]

{ #category : #installing }
PRBWrapper >> uninstall [
	| currentMethod |
	currentMethod := self compiledMethod methodClass methodDictionary
		at: self compiledMethod selector.
		
	currentMethod ~= self ifTrue: [
		self error: 'someone else changed the method dictionary in the meantime, this is dangerous'].
	
	self compiledMethod methodClass methodDictionary
		at: self compiledMethod selector
		put: previousMethod.
]

{ #category : #private }
PRBWrapper >> uninstallIfNoProbesLeft [

	| noBytecodeProbes noInvocationProbes |
	noInvocationProbes := self beforeInvocationProbes isEmpty.
	noBytecodeProbes := bytecodeProbes values allSatisfy: [:bytecodeList | 
		bytecodeList allSatisfy: [:probes | probes isEmpty]].
	(noInvocationProbes and: [noBytecodeProbes]) ifTrue: [
		self uninstall].
]

{ #category : #running }
PRBWrapper >> wrapBlock: aBlockClosure [

	aBlockClosure homeMethod selector = #wrapBlock: ifTrue: [
		"already wrapped"
		^ aBlockClosure].
	
	aBlockClosure numArgs = 0 ifTrue: [
		^ [self 
				runSimulated: [aBlockClosure value]
				stoppingIn: aBlockClosure method]].
	aBlockClosure numArgs = 1 ifTrue: [
		^ [:arg1 | self runSimulated: [aBlockClosure value: arg1] stoppingIn: aBlockClosure method]].
	aBlockClosure numArgs = 2 ifTrue: [
		^ [:arg1 :arg2 | self runSimulated: [aBlockClosure value: arg1 value: arg2] stoppingIn: aBlockClosure method]].
	aBlockClosure numArgs = 3 ifTrue: [
		^ [:arg1 :arg2 :arg3 | self runSimulated: [aBlockClosure value: arg1 value: arg2 value: arg3] stoppingIn: aBlockClosure method]].
	aBlockClosure numArgs = 4 ifTrue: [
		^ [:arg1 :arg2 :arg3 :arg4 | self runSimulated: [aBlockClosure value: arg1 value: arg2 value: arg3 value: arg4] stoppingIn: aBlockClosure method]].


]
