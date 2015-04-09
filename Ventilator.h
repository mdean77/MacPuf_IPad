//
//  Ventilator.h
//  MacPuf
//
//  Created by J. Michael Dean on Thu Mar 07 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Ventilator object handles artificial ventilation only.  
// Details to be worked out in future.

@interface Ventilator : NSObject {

    float		PEEP;		// cm H2O
    int			NARTI;		// if = 0 then ventilator is ON, if = 1 then spontaneous ventilation
    
}
// Accessors
-(float) PEEP;
-(int) NARTI;
-(BOOL) Off;
-(BOOL) On;

-(void) setPEEP:(float)value;
-(void) setNARTI:(int)value;

@end
