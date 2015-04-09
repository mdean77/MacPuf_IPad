//
//  Brain.h
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Metabolizer.h"

@interface Brain : Metabolizer {

    float		oxygenationIndex;	// MacPuf variable BO2AD   Factor 
    float		bloodFlow;		// MacPuf variable CBF     Factor 68
    float		symptomFlag;		// MacPuf variable PG
    
    // Oxygen 
    //float		amountOfOxygen;		// MacPuf variable BO2MT  Factor 66
    //float		pO2;			// MacPuf variable BO2PR  Factor 45
    //float		oxygenContent;		// MacPuf variable BO2CT  Factor 57
    //float		oxygenSaturation;	// maximum, percent       (new)
    
    // Carbon dioxide
    //float		amountOfCO2;		// MacPuf variable BC2MT  Factor 67
    //float		pCO2;			// MacPuf variable BC2PR  Factor 46
    //float		carbonDioxideContent;	// MacPuf variable BC2CT  Factor 58
    
    // Bicarbonate
    //float		bicarbonateContent;	// MacPuf variable BC3CT  Factor 91
    float		bicarbDeviation;	// MacPuf variable BC3AJ  Factor 22
        
    // pH
    //float		pH;			// MacPuf variable BPH    Factor 36
    float		C2CHN;			// variable to track changes in brain pCO2
}

@property float oxygenationIndex;
@property float bloodFlow;
@property float symptomFlag;
@property float bicarbDeviation;
@property float C2CHN;




@end
