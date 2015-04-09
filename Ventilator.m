//
//  Ventilator.m
//  MacPuf
//
//  Created by J. Michael Dean on Thu Mar 07 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import "Ventilator.h"


@implementation Ventilator

-(id) init
{
    NSLog(@"Creating %@", self);    
    if (self = [super init]) {
        PEEP = 0.000;
        NARTI = 1; // spontaneous ventilation
        NSLog(@"Object initialized: %@", self);
        }
    return self;
}

-(NSString *) description
{
    if (NARTI == 1) { return [NSString stringWithFormat:
        @"\n\nVentilator off.  Natural ventilation, no PEEP."];
    }
    else
    {return [NSString stringWithFormat:
@"\n\nVentilator on.  PEEP = %5.0f Inspiratory time = %4.2f secs I:E ratio = %4.2f", PEEP, PEEP, PEEP];
    }
}

-(float) PEEP
{
    return PEEP;
}

-(int) NARTI
{
    return NARTI;
}

-(void) setPEEP:(float)value
{
    PEEP = value;
}

-(void) setNARTI:(int)value
{
    NARTI = value;
    if(NARTI < 0) NSLog(@"Problem with NARTI");
    if(NARTI > 1) NSLog(@"Problem with NARTI");
}

-(BOOL) On
{
    return (NARTI == 0) ? YES : NO;
}

-(BOOL) Off
{
    return (NARTI == 0) ? NO : YES;
}

@end
