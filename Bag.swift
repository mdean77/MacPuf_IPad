//
//  Bag.swift
//  MacPuf_IPad
//
//  Created by J Michael Dean on 4/11/15.
//  Copyright (c) 2015 J Michael Dean. All rights reserved.
//
//	Models a Doublas bag for rebreathing experiments.  I did not implement
//	this at all in the previous Objective C attempt, but this is worth doing.

import Foundation

class Bag {
	
	var volume:Double = 0.0						// MacPuf variable BAG   Factor 116
	var carbonDioxide:Double = 0.0		// MacPuf variable BAGC  Factor 38
	var oxygen:Double = 0.0						// MacPuf variable BAGO  Factor 37
	
	init(volume:Double, carbonDioxide:Double, oxygen:Double){
		self.volume = volume
		self.carbonDioxide = carbonDioxide
		self.oxygen = oxygen
	}
}