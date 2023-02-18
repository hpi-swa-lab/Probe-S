"
I am BaselineOfSton, I load STON (Smalltalk Object Notation).
I am a BaselineOf.
"
Class {
	#name : #BaselineOfBasicProbes,
	#superclass : #BaselineOf,
	#category : #BaselineOfBasicProbes
}

{ #category : #baselines }
BaselineOfBasicProbes >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec blessing: #baseline.
			spec
				package: 'BasicProbes-Core';
				package: 'BasicProbes-Tests' with: [spec requires: #('Core')];
				group: 'Core' with: #('BasicProbes-Core');
				group: 'Tests' with: #('BasicProbes-Tests');
				group: 'default' with: #('Core') ].
]
