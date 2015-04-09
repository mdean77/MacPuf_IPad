//
//  Tissue.h
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Converted to properties and synthesis October 2011
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Metabolizer.h"

@interface Tissue : Metabolizer {
    // Oxygen 
    //float		amountOfOxygen;         // MacPuf variable TO2MT  Factor 95
    //float		pO2;                    // MacPuf variable TO2PR  Factor 96
    //float		oxygenContent;          // MacPuf variable TO2CT  Factor 55
    //float		oxygenSaturation;       // maximum, percent       (new)
    
    // Carbon dioxide
    //float		amountOfCO2;            // MacPuf variable TC2MT  Factor 16
    //float		pCO2;                   // MacPuf variable TC2PR  Factor 97
    //float		carbonDioxideContent;	// MacPuf variable TC2CT  Factor 56
    float		referenceCO2;           // MacPuf variable TC2RF  Factor 84
   
    // Nitrogen - has fast and slow compartment
    float		pN2;                    // MacPuf variable TN2PR  Factor 103
    float		amountOfNitrogen;       // MacPuf variable TN2CT  Factor 102
    float		slowN2;                 // MacPuf variable SN2PR  Factor 105
    float		amountSlowNitrogen;     // MacPuf variable SN2MT  Factor 112
    float		excessNitrogen;         // MacPuf variable UN2MT  Factor 107
    float		bubbles;                // Nitrogen bubbles in tissue (i.e. bends) Factor 83
    
    // Bicarbonate
    //float		bicarbonateContent;     // MacPuf variable TC3CT  Factor 87
    float		TC3AJ;                  // MacPuf variable TC3AJ  Factor 111
    float 		bicarbonateAmount;      // MacPuf variable TC3MT
    
    // Lactate
    float		lactateAmount	;       // MacPuf variable TLAMT  Factor 89
    
    // pH
    //float		pH;                     // MacPuf variable TPH    Factor 59
    
    // Tissue characteristics
    float		oxygenConsumption;      // MacPuf variable CONSO  Factor 73
    float		respiratoryQuotient;	// MacPuf variable TRQ    Factor 15
    float		extraFluidVolume;       // MacPuf variable TVOL   Factor 17

}

// Accessors
@property float  oxygenConsumption;
@property float  respiratoryQuotient;
@property float  extraFluidVolume;
@property float  pN2;
@property float  amountOfNitrogen;
@property float  slowN2;
@property float  amountSlowNitrogen;
@property float  excessNitrogen;
@property float  lactateAmount;
@property float  bubbles;
@property float  referenceCO2;
@property float  TC3AJ;
@property float bicarbonateAmount;

@end
