//
//  Brain.m
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import "Brain.h"


@implementation Brain

@synthesize oxygenationIndex;
@synthesize bloodFlow;
@synthesize symptomFlag;
@synthesize bicarbDeviation;
@synthesize C2CHN;

-(id) init
{
    NSLog(@"Creating %@", self);    
    if (self = [super init]) {
        oxygenationIndex = 1.000;
        bloodFlow = 52.3808;
        symptomFlag = 0.000;
        amountOfOxygen = 18.2142;
        pO2 = 29.1427;
        oxygenContent = 10.1284; 
        oxygenSaturation = 0;  // This value is just a filler - need to connect to simulator
        amountOfCO2 = 680.7448;
        pCO2 = 53.0981;
        carbonDioxideContent = 56.6056;
        bicarbonateContent = 22.7000;
        bicarbDeviation = -0.0678;
        pH = 7.3290;
        C2CHN = 0;
        NSLog(@"Object initialized: %@", self);
        }
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:
            @"\nBrain/CSF%8.1f%8.1f%8.1f%8.1f%8.0f%8.0f%7.3f%6.1f",
            pO2, pCO2,oxygenContent, carbonDioxideContent,amountOfOxygen,amountOfCO2,pH,
            bicarbonateContent+bicarbDeviation];
}

@end
