//
//  Heart.swift
//  MacPuf_IPad
//
//  Created by J Michael Dean on 4/10/15.
//  Copyright (c) 2015 J Michael Dean. All rights reserved.
//

import Foundation

class Heart : Metabolizer {
	
	var	cardiacFunction:Double = 0.0										// MacPuf variable CO		Factor 3
	var	effectiveCardiacOutput:Double = 0.0             // MacPuf variable COADJ	Factor 93
	var	maximumCardiacOutput:Double = 0.0               // MacPuf variable COMAX	Factor 27
	var	restingCardiacOutput:Double = 0.0               // MacPuf variable CONOM	Factor 82
	var	leftToRightShunt:Double = 0.0										// MacPuf variable SHUNT	Factor 28
	var	rightToLeftShunt:Double = 0.0										// MacPuf variable FADM		Factor 5
	var	admixtureEffect:Double = 0.0										// MacPuf variable VADM		Factor 9
	var	effectiveVenousAdmixture:Double = 0.0           // MacPuf variable PW		Factor 80
	var	decilitersPerIteration:Double = 0.0             // MacPuf variable FTCO
	var	fitnessAdjustedOutputPerIteration:Double = 0.0	// MacPuf variable FTCOC
	
	
	
	override init(){
		super.init()
		cardiacFunction = 100.000;
		effectiveCardiacOutput = 4.9528;
		maximumCardiacOutput = 35.0000;
		restingCardiacOutput = 4.6000;
		leftToRightShunt = 0.000;
		rightToLeftShunt = 0.000;
		admixtureEffect = 3.0000;
		effectiveVenousAdmixture = 2.3618;
		decilitersPerIteration = 0.82546666; // assumes ft = 1/60 and is deciliters per iteration
		fitnessAdjustedOutputPerIteration = 0.80895;
	}
}