Class {
	#name : #PRBBenchmarks,
	#superclass : #Object,
	#category : #'BasicProbes-Tests'
}

{ #category : #scripts }
PRBBenchmarks >> bouncingAtomsMorphBenchmark [
	"The following is a benchmark script intended for execution in a workspace."

	| expression m method probe result start |
	m := BouncingAtomsMorph new openInWorld.
	m abandon.
	[m step] bench.
	"before optimization: '132,000 per second. 7.55 microseconds per run. 9.21816 % GC time.' "
	"after optimization: '131,000 per second. 7.61 microseconds per run. 10.17593 % GC time.' "
	"after selective block simulation optimization:   '137,000 per second. 7.28 microseconds per run. 5.97761 % GC time.' "

	method := BouncingAtomsMorph>>#step.
	expression := 'origin'.
	start := method getSource asString findString: expression.
	probe := PRBTestBytecodeProbe
			on: method methodReference
			from: start
			to: start + (expression size - 1).
	result := OrderedCollection new: 10000.
	probe block: [:value | result add: value].
	probe install.

	[m step] bench.
	"before optimization: '243 per second. 4.12 milliseconds per run. 2.13829 % GC time.' "
	"after optimization:  '5,760 per second. 174 microseconds per run. 6.43871 % GC time.' "
	"after selective block simulation optimization: '39,500 per second. 25.3 microseconds per run. 4.65907 % GC time.' "
	probe uninstall.
]
