Class {
	#name : #PRBClassToBeProbed,
	#superclass : #Object,
	#category : #'BasicProbes-Tests'
}

{ #category : #fixtures }
PRBClassToBeProbed >> combineStrings: string1 and: string2 [

	^ string1 reversed , string2 reversed
]

{ #category : #fixtures }
PRBClassToBeProbed >> exceptionMethod [

	| result |
	result := PRBException signal.
	^ result
]

{ #category : #fixtures }
PRBClassToBeProbed >> exceptionUnwindMethod [

	| exception result |
	exception := PRBException new.
	result := [exception signal]
		ensure: [exception tag: self].
	^ result
]

{ #category : #fixtures }
PRBClassToBeProbed >> nestedBlockMethod [

	| result string1 string2 |
	string1 := 'abc'.
	string2 := 'xyz'.
	result := ''.
	3 timesRepeat: [ | intermediateResult |
		intermediateResult := result , (self combineStrings: string1 and: string2).
		[:string | result := string first: 2] value: intermediateResult].
	result := result capitalized.
	^ result
]

{ #category : #fixtures }
PRBClassToBeProbed >> oneBlockMethod [

	| result string1 string2 |
	string1 := 'abc'.
	string2 := 'xyz'.
	result := ''.
	3 timesRepeat: [
		result := result , (self combineStrings: string1 and: string2)].
	result := result capitalized first: 10.
	^ result
]

{ #category : #fixtures }
PRBClassToBeProbed >> storedBlockMethod [

	| result string1 string2 storeFirstTwo |
	string1 := 'abc'.
	string2 := 'xyz'.
	result := ''.
	storeFirstTwo := [:string | result := string first: 2].
	3 timesRepeat: [ | intermediateResult |
		intermediateResult := result , (self combineStrings: string1 and: string2).
		storeFirstTwo value: intermediateResult].
	result := result capitalized.
	^ result
]
