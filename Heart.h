//
//  Heart.h
//  MacPuf
//
//  Created by J. Michael Dean on Thu Mar 07 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Metabolizer.h"


@interface Heart : Metabolizer {
	float		cardiacFunction;					// MacPuf variable CO		Factor 3
	float		effectiveCardiacOutput;             // MacPuf variable COADJ	Factor 93
	float		maximumCardiacOutput;               // MacPuf variable COMAX	Factor 27
	float		restingCardiacOutput;               // MacPuf variable CONOM	Factor 82
	float		leftToRightShunt;					// MacPuf variable SHUNT	Factor 28
	float		rightToLeftShunt;					// MacPuf variable FADM		Factor 5
	float		admixtureEffect;					// MacPuf variable VADM		Factor 9
	float		effectiveVenousAdmixture;           // MacPuf variable PW		Factor 80
	float		decilitersPerIteration;             // MacPuf variable FTCO
	float		fitnessAdjustedOutputPerIteration;	// MacPuf variable FTCOC
}

@property float cardiacFunction;
@property float effectiveCardiacOutput;
@property float maximumCardiacOutput;
@property float restingCardiacOutput;
@property float leftToRightShunt;
@property float rightToLeftShunt;
@property float admixtureEffect;
@property float effectiveVenousAdmixture;
@property float decilitersPerIteration;
@property float fitnessAdjustedOutputPerIteration;


@end
