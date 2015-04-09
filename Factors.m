//
//  Factors.m
//  MacPuf
//
//  Created by Michael Dean on Sun Mar 17 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Factors.h"


@implementation Factors

-(float)	referenceValue
{
    return referenceValue;
}

-(float) 	currentValue
{
    return currentValue;
}

-(float)	previousValue
{
    return previousValue;
}

-(void)		setCurrentValue:(float)value
{
    currentValue = value;
}

-(void)		setReferenceValue:(float)value
{
    referenceValue = value;
}

-(void)		setPreviousValue:(float)value
{
    previousValue = value;
}

-(NSString *)	factorName
{
    return factorName;
}

-(void)		setFactorName:(NSString *)value
{
    factorName = value;
}
@end
