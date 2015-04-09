//
//  Bag.m
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.file:///Library/Developer/Documentation/DocSets/com.apple.ADC_Reference_Library.DeveloperTools.docset/Contents/Resources/Documents/documentation/DeveloperTools/Conceptual/XcodeCoreDataTools/Art/multiItemappearance.jpg
//

#import "Bag.h"


@implementation Bag

-(id) init
{
    NSLog(@"Creating %@", self);    
    if (self = [super init]) {
        volume = 0.000;
        carbonDioxide = 0.000;
        oxygen = 0.000;
        NSLog(@"Object initialized: %@", self);
        }
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:
        @"\nThere is no Douglas bag attached at present."];
}

@end
