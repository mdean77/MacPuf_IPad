//
//  Metabolizer.h
//  MacPuf
//
//  Created by Michael Dean on Thu Mar 07 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  EVEN more massive changes October 2, 2011 (9 years later!)
//  Copyright (c) 2011 J. Michael Dean, M.D., M.B.A.. All rights reserved.
//
//  Abstract class that contains the frequently used damp and ph functions in MacPuf
//  All parts of MacPuf that ever use these functions will inherit from this object.
//  The gases and gsinv procedures will probably go into this class as well.

#import <Cocoa/Cocoa.h>

// Structure to return from GSINV equivalent
typedef struct _gasValues {
    float	pO2, pCO2, contO2, contCO2;
} GasValues;

// Some utility functions
float sign(float f, float g);
float abs_r(float f);		// abs function for floats


@interface Metabolizer : NSObject {
// The following fields are present in all metabolizing objects;  each object has additional
// fields that are not used here.  The following are needed for GSINV and GASES to work.
// Metabolizer is an abstract class.
    
    float		amountOfOxygen;		
    float		pO2;			
    float		oxygenContent;		
    float		oxygenSaturation;	    
    float		amountOfCO2;		
    float		pCO2;			
    float		carbonDioxideContent;	    
    float		bicarbonateContent;    
    float		pH;

}

@property float amountOfOxygen;
@property float pO2;
@property float oxygenContent;
@property float amountOfCO2;
@property float pCO2;
@property float carbonDioxideContent;
@property float pH;
@property float oxygenSaturation;
@property float bicarbonateContent;

// setPh:bicarbonate:pCO2 replaces the MacPuf function PHFNC and calculates pH from
// Henderson-Hasselbach.  This is done in all metabolizing compartments of MacPuf.
-(void)updatePh:(float)bicarbonate CO2:(float)CO2;
-(void)updatePh;

-(float)dampChange:(float)newValue oldValue:(float)oldValue dampConstant:(float)dampConstant;

-(void) calcContents:(float)temperature:(float)Hct:(float)Hgb:(float)DPG;
-(GasValues) calcTrialContents:(float)temperature:(float)Hct:(float)Hgb:(float)DPG:(GasValues)trialGases;
-(void) calcPressures:(float)temperature:(float)Hct:(float)Hgb:(float)DPG;

@end
