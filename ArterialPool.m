//
//  ArterialPool.m
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import "ArterialPool.h"


@implementation ArterialPool

@synthesize	effluentOxygenContent;
@synthesize	effluentCO2Content;
@synthesize	nitrogenContent;
@synthesize	effluentNitrogenContent;
@synthesize	amountOfN2;
@synthesize	lactateConcentration;

-(id) init
{
    NSLog(@"Creating %@", self);    
    if (self = [super init]) {
        amountOfOxygen = 195.3276;
        pO2 = 93.4906;
        oxygenContent = 19.5328; 
        effluentOxygenContent = 19.5328;
        oxygenSaturation = 0; // gets fixed by calcContents
        amountOfCO2 = 474.1322;
        pCO2 = 40.0676;
        carbonDioxideContent = 47.4132;
        effluentCO2Content = 47.4132;
        amountOfN2 = 7.2573;
        nitrogenContent = 0.73;
        effluentNitrogenContent = 0.7257;
        bicarbonateContent = 23.8357;
        lactateConcentration = 0.9940;
        pH = 7.3937;
        NSLog(@"Object initialized: %@", self);
        }
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:
            @"\nArterial %8.1f%8.1f%8.1f%8.1f%8.0f%8.0f%7.3f%6.1f",
            pO2, pCO2,oxygenContent, carbonDioxideContent,amountOfOxygen,amountOfCO2,pH,
            bicarbonateContent];
}

@end
