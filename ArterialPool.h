//
//  ArterialPool.h
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Metabolizer.h"

@interface ArterialPool : Metabolizer {

    //float		amountOfOxygen;			// MacPuf variable RO2MT  Factor 62
    //float		pO2;					// MacPuf variable RO2PR  Factor 72
    //float		oxygenContent;			// MacPuf variable RO2CT  Factor 49
    float		effluentOxygenContent;	// MacPuf variable EO2CT  Factor 94
    //float		oxygenSaturation;		// maximum, percent       Factor 76
    
    //float		amountOfCO2;			// MacPuf variable RC2MT  Factor 63
    //float		pCO2;					// MacPuf variable RC2PR  Factor 74
    //float		carbonDioxideContent;	// MacPuf variable RC2CT  Factor 78
    float 		effluentCO2Content;		// MacPuf variable EC2CT  Factor 101
   
    float		nitrogenContent;		// MacPuf variable RN2CT  Factor 106
    float		effluentNitrogenContent;// MacPuf same as EN2CT
    float		amountOfN2;				// MacPuf variable RN2MT  Factor 108
   
    //float		bicarbonateContent;		// MacPuf variable RC3CT  Factor 60
    
    float		lactateConcentration;	// MacPuf variable RLACT  Factor 90

    //float		pH;						// MacPuf variable RPH    Factor 33

}

// Accessor functions
@property float	effluentOxygenContent;
@property float	effluentCO2Content;
@property float	nitrogenContent;
@property float	effluentNitrogenContent;
@property float	amountOfN2;
@property float	lactateConcentration;

@end
