//
//  Factors.h
//  MacPuf
//
//  Created by Michael Dean on Sun Mar 17 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Factors : NSObject {
    NSString  	*factorName;
    float	referenceValue;
    float	currentValue;
    float	previousValue;
}
-(float)	referenceValue;
-(float) 	currentValue;
-(float)	previousValue;
-(void)		setCurrentValue:(float)value;
-(void)		setReferenceValue:(float)value;
-(void)		setPreviousValue:(float)value;
-(NSString *)	factorName;
-(void)		setFactorName:(NSString *)value;

@end
