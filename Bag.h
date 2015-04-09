//
//  Bag.h
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Bag : NSObject {
    float		volume;			// MacPuf variable BAG   Factor 116
    float		carbonDioxide;		// MacPuf variable BAGC  Factor 38
    float		oxygen;			// MacPuf variable BAGO  Factor 37
}

@end
