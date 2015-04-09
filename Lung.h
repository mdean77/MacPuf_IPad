//
//  Lung.h
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Metabolizer.h"

// Lung contains the pulmonary circulation, alveoli, etc. as one would expect from real lungs.
// Ventilatory drive is handled here, but admixture calculations are handled in the heart.

@interface Lung : Metabolizer {
    // Oxygen (alveolar and pulmonary capillary idealized)
    //float		amountOfOxygen;		// MacPuf variable AO2MT  Factor 39
    //float		pO2;			// MacPuf variable AO2PR  Factor 41
    //float		oxygenContent;		// MacPuf variable PO2CT  Factor 54
    //float		oxygenSaturation;	// (new)
    
    // Carbon dioxide  (alveolar and pulmonary capillary idealized)
    //float		amountOfCO2;		// MacPuf variable AC2MT  Factor 40
    //float		pCO2;			// MacPuf variable AC2PR  Factor 42
    //float		carbonDioxideContent;	// MacPuf variable PC2CT  Factor 53
   
    // Nitrogen (alveolar)
    float		pN2;			
    float		amountOfNitrogen;	// MacPuf variable AN2MT  Factor 65
   
    // Bicarbonate (pulmonary capillary idealized NOT CURRENTLY USED IN MacPuf MODEL)
    //float		bicarbonateContent;	// stored only as a temp during the simulation Line 950
    
    // pH (pulmonary capillary idealized NOT CURRENTLY USED IN MacPuf MODEL)
    //float		pH;			// stored only as a temp during the simulation Line 950
   
    // Some of these may be confusing but I have made a decision to use a 1.0 second iteration
    // for all simulations.  Thus, instead of having variables to reflect per iteration values,
    // I have made variables to reflect per second values.  See, for example, old AVENT: 
    float		alveolarVentilationPerIteration;	// MacPuf variable AVENT  Factor 
    float 		addedDeadSpace;		// MacPuf variable BULLA  Factor 6
    float		hypercapnicVentResponse;// MacPuf variable AZ     Factor 10
    float		hypoxicVentResponse;	// MacPuf variable BZ	  Factor 11
    float		neurogenicVentResponse; // MacPuf variable CZ     Factor 12
    float		deadSpace;		// MacPuf variable DSPAC  Factor 70
    float		totalVentilation;	// MacPuf variable DVENT  Factor 51
    float		lungElastance;		// MacPuf variable ELAST  Factor 8
    float		FEV;			// MacPuf variable FEV	  Factor 
    float 		alveolarMinuteVent;	// MacPuf variable FVENT  Factor 35
    float		ventilatoryCoupling;	// MacPuf variable PR     Factor 
    float		referenceLungVolume;	// MacPuf variable REFLV  Factor
    float		respiratoryRate;	// MacPuf variable RRATE  Factor 48
    float		tidalVolume;		// MacPuf variable TIDVL  Factor 47
    float		FiO2;			// MacPuf variable FIO2   Factor 1
    float		FiCO2;			// MacPuf variable FIC2   Factor 2
    float	        effectiveVentResponse;	// MacPuf variable SVENT  Factor
    float		vitalCapacity;		// MacPuf variable VC     Factor 29
    float		totalLungVolume;	// MacPuf variable VLUNG  Factor 7
    float		exhaledVentilation; 	// MacPuf variable XVENT  Factor 
    float 		addedPFTDeadSpace;	// MacPuf variable XDSPA  Factor 
    float		inspiration;	        // % of respiratory cycle spent in inspiration SPACE
    float 		breathingCapacity; 	// Factor 24
    float		RVADM;			// RVADM used only when using PFT (see end of Clin2)
}

-(float) 	respiratoryRate;
-(float)	totalVentilation;
-(float)	tidalVolume;
-(float)	deadSpace;
-(float)	FiO2;
-(float)	FiCO2;
-(float) 	addedDeadSpace;
-(float)	breathingCapacity;
-(float)	lungElastance;
-(float)	FEV;
-(float)	alveolarMinuteVent;
-(float)	ventilatoryCoupling;
-(float) 	totalLungVolume;
-(float)	hypercapnicVentResponse;
-(float)	hypoxicVentResponse;
-(float)	neurogenicVentResponse;
-(float)	inspiration;
-(float)	vitalCapacity;
-(float)	RVADM;
-(float)	effectiveVentResponse;
-(float)	addedPFTDeadSpace;
- (float)	pN2;
-(float)	alveolarVentilationPerIteration;
-(float)	exhaledVentilation;


-(void)		setExhaledVentilation:(float)value;
- (void)	setPN2:(float)newPN2;
- (float)	amountOfNitrogen;
- (void)	setAmountOfNitrogen:(float)newAmountOfNitrogen;
- (void)	setAddedPFTDeadSpace:(float)newAddedPFTDeadSpace;
-(void) 	setFiO2:(float)value;
-(void)		setFiCO2:(float)value;
-(void)		setAddedDeadSpace:(float)value;
-(void)		setTotalLungVolume:(float)value;
-(void)		setLungElastance:(float)value;
-(void)		setAlveolarMinuteVent:(float)value;
-(void)		setVentilatoryCoupling:(float)value;
-(void)		setFEV:(float)value;
-(void)		setHypercapnicVentResponse:(float)value;
-(void)		setHypoxicVentResponse:(float)value;
-(void)		setNeurogenicVentResponse:(float)value;
-(void)		setInspiration:(float)value;
-(void)		setVitalCapacity:(float)value;
-(void) 	setBreathingCapacity:(float)value;
-(void)		setRVADM:(float)value;
-(void)		setAlveolarVentilationPerIteration:(float)value;
-(void)		setTotalVentilation:(float)value;
-(void)		setRespiratoryRate:(float)value;
-(void)		setEffectiveVentResponse:(float) value;
-(void)		setDeadSpace:(float)value;
-(void)		setTidalVolume:(float)value;


@end
