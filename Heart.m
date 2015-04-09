//
//  Heart.m
//  MacPuf
//
//  Created by J. Michael Dean on Thu Mar 07 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import "Heart.h"


@implementation Heart

@synthesize cardiacFunction;
@synthesize effectiveCardiacOutput;
@synthesize maximumCardiacOutput;
@synthesize restingCardiacOutput;
@synthesize leftToRightShunt;
@synthesize rightToLeftShunt;
@synthesize admixtureEffect;
@synthesize effectiveVenousAdmixture;
@synthesize decilitersPerIteration;
@synthesize fitnessAdjustedOutputPerIteration;

-(id) init{
	NSLog(@"Creating %@", self);
	if (self = [super init]) {
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
		NSLog(@"Object initialized: %@", self);		
	}
	return self;
}

@end
