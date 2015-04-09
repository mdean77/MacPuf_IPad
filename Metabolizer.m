//
//  Metabolizer.m
//  MacPuf
//
//  Created by Michael Dean on Thu Mar 07 2002.
//  Massively revised October 2, 2011 (nine years)
//  Copyright (c) 2011 J. Michael Dean, M.D., M.B.A.. All rights reserved.
//

#import "Metabolizer.h"

float sign(float f, float g) {
    // sign(f,g) = sgn(g) * abs(f)
    // If g < 1 then return abs(f) * -1
    // else return abs(f)
    float result = (g < 0) ? -abs_r(f) : abs_r(f);
    return result;
}

float abs_r(float f) {
    return (f < 0) ? -f : f;
}

@implementation Metabolizer

@synthesize amountOfOxygen;
@synthesize pO2;
@synthesize oxygenContent;
@synthesize amountOfCO2;
@synthesize pCO2;
@synthesize pH;
@synthesize carbonDioxideContent;
@synthesize oxygenSaturation;
@synthesize bicarbonateContent;

-(float)dampChange:(float) newValue 
        oldValue:(float) oldValue 
        dampConstant:(float) dampConstant

    {
        return (newValue * dampConstant + oldValue)/(dampConstant + 1);
    }
    
-(void)updatePh    
    {
        pH = (6.1 + log10((bicarbonateContent)/(pCO2 * .03)));
    }

-(void)updatePh:(float)bicarbonate CO2:(float)CO2
{
    pH = (6.1 + log10((bicarbonate)/(CO2 * .03)));
}
    

// This method replaces the MacPuf GASES subroutine.  It accepts any values of pO2, pCO2 and pH and
// works out O2 and CO2 contents and the saturation of O2.  It then uses the appropriate routines to
// set these variables using the accessor methods of the calling object.  This is possible because I have 
// named all the variables consistently between metabolizing objects that may call this routine.  Therefore,
// the method actually returns void and exerts its effect directly on the object members.

-(void) calcContents:(float)temperature:(float)Hct:(float)Hgb:(float)DPG
{
	  // NSLog(@"calcContents method");
    // constants needed for the rather complex Kelman equations
    const 	float a1 = -8.532229E3;
    const 	float a2 = 2.121401E3;
    const 	float a3 = -6.707399E1;
    const 	float a4 = 9.359609E5;
    const 	float a5 = -3.134626E4;
    const 	float a6 = 2.396167E3;
    const 	float a7 = -6.710441E1;
    float	p, pk, dox, x, t, sol, dr, cp, cc, h, sat;

    x = pO2 * pow(10,(0.4*(pH - (7.4+(DPG-3.8)*0.025)) + 0.024*(37 - temperature)) + 0.026057669*log(40/pCO2));
    x = (x < 0.01) ? 0.01 : x;   // Make sure x is at least greater than 0.01
    sat = (x >= 10) ? x*(x*(x*(x+a3)+a2)+a1)/(x*(x*(x*(x+a7)+a6)+a5)+a4) : (0.003683+0.000584*x)*x;
    p = 7.4 - pH;
    pk = 6.086 + p*0.042 + (38 - temperature)*(0.00472+0.00139*p);
    t = 37 - temperature;
    sol = 0.0307+(0.00057+0.00002*t)*t;
    dox = 0.590 + (0.2913-0.0844*p)*p;
    dr = 0.664+(0.2275-0.0938*p)*p;
    t = dox +(dr - dox)*(1 - sat);
    cp = sol*pCO2*(1+pow(10, pH - pk));
    cc = t * cp;
    h = Hct * 0.01;
    [self setOxygenSaturation:sat];
    [self setOxygenContent:Hgb*sat*1.34 + 0.003*pO2];
    if ([self oxygenContent] < 0.001) [self setOxygenContent:0.001];
    [self setCarbonDioxideContent:(cc*h+(1-h)*cp)*2.22];
    if ([self carbonDioxideContent] < 0.001) [self setCarbonDioxideContent:0.001];
    

}

// The routine below is similar to calcContents except it is designed to return trial values to calcPressures.
// In calcPressures, it is necessary to call this routine to get trial values and compare them to the target;  it
// would not do for me to be changing actual MacPuf parameters in this routine!

-(GasValues) calcTrialContents:(float)temperature:(float)Hct:(float)Hgb:(float)DPG:(GasValues)trialGases
{
    // NSLog(@"calcTrialContents method");
    // constants needed for the rather complex Kelman equations
    const 	float a1 = -8.532229E3;
    const 	float a2 = 2.121401E3;
    const 	float a3 = -6.707399E1;
    const 	float a4 = 9.359609E5;
    const 	float a5 = -3.134626E4;
    const 	float a6 = 2.396167E3;
    const 	float a7 = -6.710441E1;
    float	p, pk, dox, x, t, sol, dr, cp, cc, h;
    pO2 = trialGases.pO2;	// Note that this causes a direct change of the object pO2!
    pCO2 = trialGases.pCO2;
    x = pO2 * pow(10,(0.4*(pH - (7.4+(DPG-3.8)*0.025)) + 0.024*(37 - temperature)) + 0.026057669*log(40/pCO2));
    x = (x < 0.01) ? 0.01 : x;   // Make sure x is at least greater than 0.01
    oxygenSaturation = (x >= 10) ? x*(x*(x*(x+a3)+a2)+a1)/(x*(x*(x*(x+a7)+a6)+a5)+a4) : (0.003683+0.000584*x)*x;
    p = 7.4 - pH;
    pk = 6.086 + p*0.042 + (38 - temperature)*(0.00472+0.00139*p);
    t = 37 - temperature;
    sol = 0.0307+(0.00057+0.00002*t)*t;
    dox = 0.590 + (0.2913-0.0844*p)*p;
    dr = 0.664+(0.2275-0.0938*p)*p;
    t = dox +(dr - dox)*(1 - oxygenSaturation);
    cp = sol*pCO2*(1+pow(10, pH - pk));
    cc = t * cp;
    h = Hct * 0.01;
    trialGases.contO2 = Hgb*oxygenSaturation*1.34 + 0.003*pO2;
    trialGases.contCO2 = (cc*h+(1-h)*cp)*2.22;
	  if (trialGases.contCO2 < 0.001) trialGases.contCO2 = 0.001;
    return trialGases;

}


// This method replaces the MacPuf GSINV subroutine.  It accepts values of O2 and CO2 content and using
// successive approximation it iterates to the respective partial pressures.  Like calcContents, it also
// directly changes (using accessor methods) the values within the calling object rather then returning an
// array of values and requiring the object to update itself.

// After considering a rewrite, I have decided to exactly copy the logic in the original version as it was a
// well thought out routine, highly efficient, etc.  I have even used the exact variable names.  One important
// aspect is that pO2 and pCO2 are DIRECTLY altered within the routine - not just as locals, but inside the
// respective metabolizer object.  This routine is only called in the myArteries object, and thus the routine
// will directly change the arterial pO2 and pCO2 on each iteration.

-(void) calcPressures:(float)temperature:(float)Hct:(float)Hgb:(float)DPG
{
    // NSLog(@"Entering calcPressures method");
    const	float err = 0.01;
    float	D1Z = 2, D2Z = 2;
    float	D1, D2, DS;
    int		ich1=1, ich2=1, ich3=1, ich4=1;
    float	x,y,xx1,xx2,yy1,yy2,xp1,xp2,yp1,yp2;
    GasValues	trial;			// Holds the values for the call to calcTrialContents
    int		convergeCount = 0; 	// my only real change so I can see how fast this puppy converges

    // Get rid of next line except when testing!
    // pO2 = 105;  pCO2 = 35;    
    //  Use current pO2 and pCO2 for initial guesses
start:				// FORTRAN line 100
    //    NSLog(@"Start");

    trial.pO2 = pO2;
    trial.pCO2 = pCO2;
    trial = [self calcTrialContents:temperature:Hct:Hgb:DPG:trial];
    x = trial.contO2;
    y = trial.contCO2;
    xx2 = x - oxygenContent;
    if (xx2 == 0) xx2 = 0.001;
    yy2 = y - carbonDioxideContent;
    if (yy2 == 0) yy2 = 0.001;
    xp2 = pO2;
    yp2 = pCO2;

    if (ich3 ==1) {
        ich3 = 0;
        D1 = sign(D1Z, -xx2);
    }

    if (ich4 == 1) {
        ich4 = 0;
        D2 = sign(D2Z, -yy2);
    }
    // check for convergence
    if (abs_r(xx2) < err) {
        ich1 = 0;
    }
    if (abs_r(yy2) < err) {
        ich2 = 0;
    }
    if ((ich1 + ich2) == 0) {
        return;
    }

    // I am assuming that I can just return because the object's pO2 and pCO2 have already been
    // directly changed in calcTrialContents.

middle:				// FORTRAN line 210
    //     NSLog(@"Middle");
    DS = D1 * ich1;		// clever way to suppress further changes if already converged
    x = pO2 + DS - pO2 * 0.25;
    if (x<0) {
        DS = -pO2 * 0.75;
    }
    pO2 = pO2 + DS;		// new pO2 value to try.  This directly changes the object pO2.

    DS = D2 * ich2;
    x = pCO2 + DS - pCO2 * 0.25;
    if (x<0) {
        DS = -pCO2 * 0.75;
    }
    pCO2 = pCO2 + DS;		// new pCO2 value to try.  This directly changes the object pCO2.

    if (pO2 < 0.1) {
        pO2 = 0.1;
    }
    if (pCO2 < 0.1) {
            pCO2 = 0.1;
    }

    trial.pO2 = pO2;
    trial.pCO2 = pCO2;
    trial = [self calcTrialContents:temperature:Hct:Hgb:DPG:trial];
    x = trial.contO2;
    y = trial.contCO2;

    xx1 = xx2;
    xx2 = x - oxygenContent;
    xp1 = xp2;
    xp2 = pO2;
    yy1 = yy2;
    yy2 = y - carbonDioxideContent;
    yp1 = yp2;
    yp2 = pCO2;

    // Check the oxygen content results for suitability
    ich1 = 0;
    if (abs_r(xx2) > err) {
        ich1 = 1;		// Not done

        if ((xx2 * D1) > 0) {
            ich3 = 1;
            pO2 = xp1 + (xp2 - xp1)*abs_r(xx1)/(abs_r(xx2)+abs_r(xx1));
            D1Z = D1Z * 0.5;
        }

        if ((xx2 * D1) < 0) {
            D1 = (xp2 == xp1) ? sign(D1Z, -xx2) : (xp2 - xp1)*abs_r(xx2)/abs_r(xx2 - xx1);
        }
    }

    // Check the carbon dioxide content results for suitability
    ich2 = 0;
    if (abs_r(yy2) > err) {
        ich2 = 1;

        if ((yy2 * D2) > 0) {
            ich4 = 1;
            pCO2 = yp1 + (yp2 - yp1)*abs_r(yy1)/(abs_r(yy2)+abs_r(yy1));
            D2Z = D2Z * 0.5;
        }

        if ((yy2 * D2) < 0) {
            D2 = (yp2 == yp1) ? sign(D2Z, -yy2) : (yp2 - yp1)*abs_r(yy2)/abs_r(yy2 - yy1);
        }
    }

    if ((ich1 + ich2) == 0) {
        return;
    }
    if ((ich3 + ich4 - 1) < 0) {
        goto middle;
    }
    //NSLog(@"convergence count = ");
    ++convergeCount;
    goto start;
}
    
@end
