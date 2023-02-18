Class {
	#name : #PRBBytecodeProbeTest,
	#superclass : #TestCase,
	#instVars : [
		'storedBlockMethod',
		'oneBlockMethod',
		'nestedBlockMethod',
		'combineStringsMethod'
	],
	#category : #'BasicProbes-Tests'
}

{ #category : #utilitiy }
PRBBytecodeProbeTest >> createBytecodeProbeFor: expression in: method [

	| start |
	start := method getSource asString findString: expression.
	^ PRBTestBytecodeProbe
		on: method methodReference
		from: start
		to: start + (expression size - 1).
]

{ #category : #running }
PRBBytecodeProbeTest >> setUp [

	oneBlockMethod := PRBClassToBeProbed>>#oneBlockMethod.
	storedBlockMethod := PRBClassToBeProbed>>#storedBlockMethod.
	nestedBlockMethod := PRBClassToBeProbed>>#nestedBlockMethod.
	combineStringsMethod := PRBClassToBeProbed>>#combineStrings:and:.
]

{ #category : #running }
PRBBytecodeProbeTest >> tearDown [

	PRBClassToBeProbed methodDictionary at: #oneBlockMethod put: oneBlockMethod.
	PRBClassToBeProbed methodDictionary at: #storedBlockMethod put: storedBlockMethod.
	PRBClassToBeProbed methodDictionary at: #nestedBlockMethod put: nestedBlockMethod.
	PRBClassToBeProbed methodDictionary at: #combineStrings:and: put: combineStringsMethod.
	
]

{ #category : #tests }
PRBBytecodeProbeTest >> testSingleBeforeProbeInMethod [

	| probe result object |
	probe := PRBTestMethodProbe on: oneBlockMethod methodReference.
	
	result := OrderedCollection new.
	probe block: [:receiver :arguments | result add: receiver].
	probe install.

	object := PRBClassToBeProbed new.
	object oneBlockMethod.
	
	self assert: object equals: result first.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testSingleBytecodeProbeInBlock [

	| probe result |
	probe := self 
		createBytecodeProbeFor: 'combineStrings: string1 and: string2' 
		in: oneBlockMethod.
	
	result := OrderedCollection new.
	probe block: [:value | result add: value].
	probe install.

	PRBClassToBeProbed new oneBlockMethod.
	
	self assert: 3 equals: result size.
	self assert: (result allSatisfy: [:o | o isString]).
	self assert: 6 equals: result first size.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testSingleBytecodeProbeInCalledMethod [

	| probe result |
	probe := self 
		createBytecodeProbeFor: 'reversed' 
		in: combineStringsMethod.
	
	result := OrderedCollection new.
	probe block: [:value | result add: value].
	probe install.

	PRBClassToBeProbed new oneBlockMethod.
	
	self assert: 3 equals: result size.
	self assert: 'cba' equals: result first.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testSingleBytecodeProbeInMethod [

	| probe result |
	probe := self 
		createBytecodeProbeFor: 'capitalized' 
		in: oneBlockMethod.
	
	result := OrderedCollection new.
	probe block: [:value | result add: value].
	probe install.

	PRBClassToBeProbed new oneBlockMethod.
	
	self assert: 'Cbazyxcbazyxcbazyx' equals: result first.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testSingleBytecodeProbeInNestedBlock [

	| probe result |
	probe := self 
		createBytecodeProbeFor: 'first: 2' 
		in: nestedBlockMethod.
	
	result := OrderedCollection new.
	probe block: [:value | result add: value].
	probe install.

	PRBClassToBeProbed new nestedBlockMethod.
	
	self assert: 3 equals: result size.
	self assert: (result allSatisfy: [:o | o isString]).
	self assert: 'cb' equals: result first.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testSingleBytecodeProbeInStoredBlock [

	| probe result |
	probe := self 
		createBytecodeProbeFor: 'first: 2' 
		in: storedBlockMethod.
	
	result := OrderedCollection new.
	probe block: [:value | result add: value].
	probe install.

	PRBClassToBeProbed new storedBlockMethod.
	
	self assert: 3 equals: result size.
	self assert: (result allSatisfy: [:o | o isString]).
	self assert: 'cb' equals: result first.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testSingleReturnProbeInMethod [

	| probe result |
	probe := PRBTestMethodReturnProbe on: combineStringsMethod methodReference.
	
	result := OrderedCollection new.
	probe block: [:returnValue | result add: returnValue].
	probe install.

	PRBClassToBeProbed new oneBlockMethod.
	
	self assert: 'cbazyx' equals: result first.
	self assert: 3 equals: result size.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testTwoBeforeProbes [

	| object probe1 probe2 result1 result2 |
	probe1 := PRBTestMethodProbe on: oneBlockMethod methodReference.
	result1 := OrderedCollection new.
	probe1 block: [:receiver :arguments | result1 add: receiver].
	probe1 install.

	probe2 := PRBTestMethodProbe on: oneBlockMethod methodReference.
	result2 := OrderedCollection new.
	probe2 block: [:receiver :arguments | result2 add: receiver].
	probe2 install.

	object := PRBClassToBeProbed new.
	object oneBlockMethod.
	
	self assert: object equals: result1 first.
	self assert: object equals: result2 first.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testTwoBytecodeProbesAtDifferentLocations [

	| probe1 probe2 result1 result2 |
	probe1 := self 
		createBytecodeProbeFor: 'capitalized' 
		in: oneBlockMethod.
	result1 := OrderedCollection new.
	probe1 block: [:value | result1 add: value].
	probe1 install.
	
	probe2 := self 
		createBytecodeProbeFor: 'first: 10' 
		in: oneBlockMethod.
	result2 := OrderedCollection new.
	probe2 block: [:value | result2 add: value].
	probe2 install.

	PRBClassToBeProbed new oneBlockMethod.
	
	self assert: 'Cbazyxcbazyxcbazyx' equals: result1 first.
	self assert: 'Cbazyxcbaz' equals: result2 first.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testTwoBytecodeProbesAtSameLocation [

	| probe1 probe2 result1 result2 |
	probe1 := self 
		createBytecodeProbeFor: 'capitalized' 
		in: oneBlockMethod.
	result1 := OrderedCollection new.
	probe1 block: [:value | result1 add: value].
	probe1 install.
	
	probe2 := self 
		createBytecodeProbeFor: 'capitalized' 
		in: oneBlockMethod.
	result2 := OrderedCollection new.
	probe2 block: [:value | result2 add: value].
	probe2 install.

	PRBClassToBeProbed new oneBlockMethod.
	
	self assert: 'Cbazyxcbazyxcbazyx' equals: result1 first.
	self assert: 'Cbazyxcbazyxcbazyx' equals: result2 first.
]

{ #category : #tests }
PRBBytecodeProbeTest >> testUninstallingMultipleProbesRemovesWrapper [

	| expression start probe |
	expression := 'capitalized'.
	start := oneBlockMethod getSource asString findString: expression.
	probe := PRBTestBytecodeProbe
		on: oneBlockMethod methodReference
		from: start
		to: start + (expression size - 1).

	probe install.
	probe uninstall.

	self assert: oneBlockMethod == (PRBClassToBeProbed>>#oneBlockMethod).
]
