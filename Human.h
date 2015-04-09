//
//  Human.h
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//


#import <Cocoa/Cocoa.h> 

@class ArterialPool, Brain, Tissue, VenousPool, Heart, Lung, Bag, Ventilator,Factors;

@interface Human : NSObject {

    ArterialPool	*myArteries;	// MacPuf arterial pool
    Brain		*myBrain;	// MacPuf brain object
    Tissue		*myTissues;	// MacPuf tissues
    VenousPool		*myVeins;	// MacPuf venous pool
    Heart		*myHeart;	// MacPuf heart
    Lung		*myLungs;	// MacPuf lungs
    Bag			*myBag;		// external Douglas bag for bag experiments
    Ventilator		*myVentilator;	// external ventilator for artificial ventilation
    float 		veinDelay[40];	// TDLAY from MacPuf FORTRAN - venous delay line
    
    int			age;		// years
    int			weight;		// kilograms
    int			height;		// centimeters
    
    float		barometric;	// barometric pressure, normal = 760 mm Hg
                                        // left in human object for convenience
    float		BARRF;		// new factor introduced in new version of macPuf
    int			iterations;	// used so myDocument can pass in the number to the human object
                                        // needed to adjust bicarbonate and acid administration to be smooth		
    float		DPG;		// 2,3 DPG
    float		Hgb;		// hemoglobin
    float		Hct;		// hematocrit or packed cell volume in original code
    float		temperature;	// Centigrade
    int			male;		// gender flag; male = 1 and female = 0
    float		metabolicRate;	// Factor 4
    float		fitness;	// Factor 25
    float		XLACT;		// Factor 44 to account for oxygen debt issues
    float		DPH;		// Factor 43
    float		XC2PR;		// Factor 119 added in new version of MacPuf
    float		RCOAJ;		// Factor 32 added in new version (replaced PA)
    float		XRESP;		// Factor 64
    int			simlt;		// flag to indicate SI units or mm Hg (1)
    int			totalSeconds;	// This tells the time for this particular human simulation.
                                        // I put this in the Human object so that the main document
                                        // controller only worries about how many additional iterations
                                        // to run the simulation.
       
}

- (void)	setIterations:(int)newIterations; // so myDocument can send the message in

//-(float)dampChange:(float)newValue: (float)oldValue: (float)dampConstant;
// This is included with metabolizer objects but unfortunately I need to be able to damp
// certain parameters that are for the whole human object, so I have repeated the function
// here.  Not clean, but works.
-(float)dampChange:(float)newValue oldValue:(float)oldValue dampConstant:(float)dampConstant;

-(void) simulate:(int)i;		// called by the document controller
                                        // number of cycles controlled at higher level
                                        
-(NSString *) runReport;		// creates the report at end of each run 
                                        // Routine is in DEADY in the original code
                                        
-(NSString *) cycleReport;		// creates the string to output every cycle
                                        // Same function as BRETH - uses lineprinter approach
                                        // IF I decide to implement graphic interface then this is
                                        // routine to alter.
                                        
-(NSString *) dumpParametersReport;	// Print out all 30 changeable parameters

                                        
-(void) changeValues:(NSMutableArray *)arrayOfFactors;			// used to update FROM interface
-(void) revertValuesCorrectly:(NSMutableArray *)arrayOfFactors;		// used to revert interface to current values

-(void) setVentilator:(int)ventOn PEEP:(int)PEEP rate:(int)rate FiO2:(float)FiO2 tidalVolume:(int)tidalVolume;

@end
