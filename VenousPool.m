//
//  VenousPool.m
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import "VenousPool.h"


@implementation VenousPool

-(id) init
{
    NSLog(@"Creating %@", self);    
    if (self = [super init]) {
        amountOfOxygen = 434.7640;
        //pO2 = 40.0;
        oxygenContent = 14.4921;
        oxygenSaturation = 0;  // value made up - needs to be connected to simulator
        amountOfCO2 = 1543.2665;
        //pCO2 = 45.7;
        carbonDioxideContent = 51.4422;
        bicarbonateContent = 25.4605;
        bicarbonateAmount = 71.2432;
        addBicarb = 0.000;
        pH = 7.3710;
        venousBloodVolume = 3000.000;
        NSLog(@"Object initialized: %@", self);
        }
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:
            @"\nMixed Ven. (same as tissue)%6.1f%8.1f%8.0f%8.0f%7.3f%6.1f",
            oxygenContent, carbonDioxideContent,amountOfOxygen,amountOfCO2,pH,
            bicarbonateContent];
}
// Accessors
-(float) addBicarb
{
    return addBicarb;
}

-(float) venousBloodVolume
{
    return venousBloodVolume;
}

-(float) bicarbonateAmount {
    return bicarbonateAmount;
}

-(void) setAddBicarb:(float)value
{
    addBicarb = value;
}
-(void) setVenousBloodVolume:(float)value
{
    venousBloodVolume = value;
}
-(void) setBicarbonateAmount:(float)value {
    bicarbonateAmount = value;
}

@end
