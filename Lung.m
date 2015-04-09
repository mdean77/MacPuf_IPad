//
//  Lung.m
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import "Lung.h"


@implementation Lung

-(id) init
{
    NSLog(@"Creating %@", self);    
    if (self = [super init]) {
        amountOfOxygen = 346.1360;
        pO2 = 101.6193;
        oxygenContent = 19.6547;
        oxygenSaturation = .970730;  //Value made up - need to connect to simulator
        amountOfCO2 = 144.7786;
        pCO2 = 39.9436;
        carbonDioxideContent = 47.3157;
        pN2 = 0;  //Value made up - need to connect to simulator
        pH = 7.40; //Fake
        amountOfNitrogen = 1987.6002;
        bicarbonateContent = 0;  //value made up - need to connect to simulator
        alveolarMinuteVent = 4.3957;
        alveolarVentilationPerIteration = 73.2621;  // 366.3107 is value in Fortran code but reflects larger ft!!;
        addedDeadSpace = 0.0000;
        hypercapnicVentResponse = 100.000;
        hypoxicVentResponse = 100.000;
        neurogenicVentResponse = 100.000;
        deadSpace = 130.6685;
        totalVentilation = 6.0536;
        lungElastance = 5.0000;
        FEV = 4.0;
        ventilatoryCoupling = 100.000;
        referenceLungVolume = 3000.000;
        respiratoryRate = 12.6881;
        tidalVolume = 477.1105;
        FiO2 = 20.93000;
        FiCO2 = 0.0300;
        effectiveVentResponse = 6.0536;
        vitalCapacity = 5.0000;
        totalLungVolume = 3000.000;
        exhaledVentilation = 8.8777;
        addedPFTDeadSpace = 0.000;
        inspiration = 0.4000;
        breathingCapacity = 100;
        RVADM = 0.000;
        NSLog(@"Object initialized: %@", self);
        }
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:
            @"\nAlv./Lung%8.1f%8.1f    (Sat=%4.1f%%) %8.0f%8.0f\n(Pulm.cap)%7.1f%8.1f%8.1f%8.1f",
            pO2, pCO2,oxygenSaturation*100,amountOfOxygen,amountOfCO2,pO2,pCO2,oxygenContent,
            carbonDioxideContent];
}

// Accessor procedures

-(float) respiratoryRate
{
    return respiratoryRate;
}

-(float) totalVentilation
{
    return totalVentilation;
}

-(float) tidalVolume
{
    return tidalVolume;
}
-(float) deadSpace
{
    return deadSpace;
}

-(float) addedDeadSpace
{
    return addedDeadSpace;
}

-(float) lungElastance
{
    return lungElastance;
}
 -(float) FEV
{
    return FEV;
}

-(float)	alveolarMinuteVent
{
    return alveolarMinuteVent;
}

-(float)	ventilatoryCoupling
{
    return ventilatoryCoupling;
}
-(float) FiO2
{
    return FiO2;
}

-(float) FiCO2
{
    return FiCO2;
}

-(float) breathingCapacity
{
    return breathingCapacity;
}

-(float) 	totalLungVolume
{
    return totalLungVolume;
}

-(float)	hypercapnicVentResponse
{
    return hypercapnicVentResponse;
}

-(float)	hypoxicVentResponse
{
    return hypoxicVentResponse;
}

-(float)	neurogenicVentResponse
{
    return neurogenicVentResponse;
}

-(float)	inspiration
{
    return inspiration;
}

-(float)	vitalCapacity
{
    return vitalCapacity;
}

-(float)	RVADM
{
    return RVADM;
}

-(float) effectiveVentResponse {
    return effectiveVentResponse;
}

- (float)	addedPFTDeadSpace
{
    return addedPFTDeadSpace;
}

-(float)	alveolarVentilationPerIteration
{
    return alveolarVentilationPerIteration;
}

-(float)	exhaledVentilation
{
    return exhaledVentilation;
}

-(void)		setExhaledVentilation:(float)value
{
    exhaledVentilation = value;
}

-(void)		setAlveolarVentilationPerIteration:(float)value
{
    alveolarVentilationPerIteration = value;
}

- (void)	setAddedPFTDeadSpace:(float)newAddedPFTDeadSpace
{
    addedPFTDeadSpace = newAddedPFTDeadSpace;
}

-(void) setFiO2:(float)value
{
    FiO2 = value;
}

-(void) setFiCO2:(float)value
{
    FiCO2 = value;
}
-(void)		setAddedDeadSpace:(float)value
{
    addedDeadSpace = value;
}

-(void)		setTotalLungVolume:(float)value
{
    totalLungVolume = value;
}

-(void)		setTotalVentilation:(float)value
{
    totalVentilation = value;
}


-(void)		setLungElastance:(float)value
{
    lungElastance = value;
}

-(void)		setFEV:(float)value
{
    FEV = value;
}

-(void)		setAlveolarMinuteVent:(float)value
{
    alveolarMinuteVent = value;
}

-(void)		setVentilatoryCoupling:(float)value
{
    ventilatoryCoupling = value;
}

-(void)		setHypercapnicVentResponse:(float)value
{
    hypercapnicVentResponse = value;
}

-(void) 	setRespiratoryRate:(float)value
{
    respiratoryRate = value;
}

-(void)		setHypoxicVentResponse:(float)value
{
    hypoxicVentResponse = value;
}

-(void)		setNeurogenicVentResponse:(float)value
{
    neurogenicVentResponse = value;
}

-(void)		setInspiration:(float)value
{
    inspiration = value;
}

-(void)		setEffectiveVentResponse:(float) value
{
    effectiveVentResponse = value;
}


-(void)		setVitalCapacity:(float)value
{
    vitalCapacity = value;
}

-(void)		setBreathingCapacity:(float)value
{
    breathingCapacity = value;
}

-(void)		setRVADM:(float)value
{
    RVADM = value;
}
- (float)	pN2
{
    return pN2;
}
    - (void)	setPN2:(float)newPN2
{
    pN2 = newPN2;
}
    - (float)	amountOfNitrogen
{
    return amountOfNitrogen;
}
    - (void)	setAmountOfNitrogen:(float)newAmountOfNitrogen
{
    amountOfNitrogen = newAmountOfNitrogen;
}

-(void)	setDeadSpace:(float)value
{
    deadSpace = value;
}

-(void)  setTidalVolume:(float)value
{
    tidalVolume = value;
}


@end
