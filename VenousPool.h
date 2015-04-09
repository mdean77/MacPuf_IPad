//
//  VenousPool.h
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Metabolizer.h"

@interface VenousPool : Metabolizer {
    // Oxygen 
    //float		amountOfOxygen;		// MacPuf variable VO2MT  Factor 98
    //float		pO2;			// MacPuf variable VO2PR  Factor 96
    //float		oxygenContent;		// MacPuf variable VO2CT  Factor 31
    //float		oxygenSaturation;	// maximum, percent       (new)
    
    // Carbon dioxide
    //float		amountOfCO2;		// MacPuf variable VC2MT  Factor 50
    //float		pCO2;			// MacPuf variable VC2PR  Factor 97
    //float		carbonDioxideContent;	// MacPuf variable VC2CT  Factor 61
   
    // Bicarbonate
    //float		bicarbonateContent;	// MacPuf variable VC3CT  Factor 88
    float		bicarbonateAmount;	// MacPuf variable VC3MT  Factor 86
    float		addBicarb;		// additional bicarbonate, use negative to give acid
                                                // In venous pool because is administered there
                                                // MacPuf variable ADDC3  Factor 21 		
    // pH
    //float		pH;			// MacPuf variable VPH    Factor 34
    float		venousBloodVolume;	// MacPuf variable VBLVL  Factor 20
}


// Accessors
-(float) addBicarb;
-(float) venousBloodVolume;
-(float) bicarbonateAmount;

-(void) setAddBicarb:(float)value;
-(void) setVenousBloodVolume:(float)value;
-(void) setBicarbonateAmount:(float)value;
@end
