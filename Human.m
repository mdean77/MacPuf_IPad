//
//  Human.m
//  MacPuf
//
//  Created by J. Michael Dean on Wed Mar 06 2002.
//  Massive coding alterations done Sunday September 15, 2002.
//  Much more massive change made in Christmas week, 2002.  Involves all files.
//  More massive coding changes between December and February, 2003
//  Copyright (c) 2002 - 2003 J.Michael Dean, M.D., M.B.A. All rights reserved.
//

#import "Human.h"
#import "Factors.h"
#import "Metabolizer.h"
#import "ArterialPool.h"
#import "Brain.h"
#import "Tissue.h"
#import "VenousPool.h"
#import "Heart.h"
#import "Lung.h"
#import "Bag.h"
#import "Ventilator.h"

@implementation Human

-(id) init
{
    int i;
    if (self = [super init]) {
        myArteries = [[ArterialPool alloc] init];
        myBrain = [[Brain alloc] init];
        myTissues = [[Tissue alloc] init];
        myVeins = [[VenousPool alloc] init];
        myHeart = [[Heart alloc] init];
        myLungs = [[Lung alloc] init];
        myBag = [[Bag alloc] init]; 
        myVentilator = [[Ventilator alloc] init];
        age = 40;
        weight = 70;
        height = 178;
        barometric = 760;
        BARRF = 713.01;
        DPG = 3.7843;
        Hgb = 14.8;
        Hct = 45.0;
        temperature = 37.0;
        male = 1;
        totalSeconds = 0;
        metabolicRate = 100;
        fitness = 28;
        XLACT = 0.0006;
        XC2PR = 45.4757;
        DPH = 7.3996;
        RCOAJ = 100;
        XRESP = 8.8777;
        simlt = 1;  // Use mm Hg
        [myBrain calcContents:temperature:Hct:Hgb:DPG];
        [myArteries calcContents:temperature:Hct:Hgb:DPG];       
        [myTissues calcContents:temperature:Hct:Hgb:DPG];
        //[myVeins calcContents:temperature:Hct:Hgb:DPG];    
        [myLungs calcContents:temperature:Hct:Hgb:DPG];		
        for (i = 1; i <= 10; ++i) {
            veinDelay[i-1] = [myVeins oxygenContent];
            veinDelay[i+9] = [myVeins carbonDioxideContent];
            veinDelay[i+19] = [myVeins bicarbonateContent];
            veinDelay[i + 29] = XC2PR;
        }
    }
    return self;
}

-(float)dampChange:(float) newValue
          oldValue:(float) oldValue
      dampConstant:(float) dampConstant

{
    return (newValue * dampConstant + oldValue)/(dampConstant + 1);
}

- (void)setIterations:(int)newIterations
{
    iterations = newIterations;
}

-(void) setVentilator:(int)ventOn PEEP:(int)PEEP rate:(int)rate FiO2:(float)FiO2 tidalVolume:(int)tidalVolume
{
    if (ventOn == 1) {
        // set all the parameters
        NSLog(@"Human object now turning on ventilator");
        [myVentilator setPEEP:PEEP];
        [myVentilator setNARTI:0];
        [myLungs setRespiratoryRate:rate];
        [myLungs setTidalVolume:tidalVolume];
        [myLungs setFiO2:FiO2];
    }
    else // ventilator turned off
    {
        // set everything to spontaneous (NARTI = 1, PEEP = 0, etc.
        NSLog(@"Human object now turning off ventilator");
        [myVentilator setPEEP:0];
        [myVentilator setNARTI:1];
    }
}


//  Override the description method so it dumps useful information when I use 
//  NSLog.  I also use this method to implement the Inspect option in MacPuf.
-(NSString *) description
{
    NSString *header, *artString, *lungString,*brainString,*tissueString,*veinString,
    *bagString, *ventilatorString;
    NSMutableString  *result;
    header = [[NSString alloc] initWithFormat:@"\nTime         P.Pressures     Contents cc%%    Amounts in cc  pH    HCO3-\n%4d secs     O2     CO2      O2       CO2     O2     CO2",totalSeconds];
            
    artString = [myArteries description];	
    lungString = [myLungs description];
    brainString = [myBrain description];
    tissueString = [myTissues description];
    veinString = [myVeins description];
    bagString = [myBag description];
    ventilatorString = [myVentilator description];
    result = [[NSMutableString alloc] initWithCapacity:500];
    [result appendString:header];
    [result appendString:artString];
    [result appendString:lungString];
    [result appendString:brainString];
    [result appendString:tissueString];
    [result appendString:veinString];
    [result appendString:ventilatorString];
    [result appendString:bagString]; 
  
    //[result appendString: something to get the lactate value
    [header release];
    return result;
}

-(NSString *) runReport
{
// This is designed to print out information at the end of each run.  This implements routines that are contained
// in the DEADY procedure of MacPuf.  
    NSString *result;
    float x;
    x = 10*pow(2,(8 - [myArteries pH])*3.33);
    result = [[NSString alloc] initWithFormat:@"Final values for this run were...\n\nArterial pO2 = %6.1f            O2 Cont =%6.1f      O2 Sat = %5.1f%%\nArterial pCO2 = %5.1f            CO2 Cont =%6.1f \nArterial pH = %7.2f (%3.0f nm)   Arterial bicarbonate = %5.1f\n\nRespiratory rate = %5.1f         Tidal vol.= %6.0f ml\nTotal ventilation =%5.1f l/min   Actual cardiac output = %5.1f l/min\nTotal dead space = %4.0f ml       Actual venous admixture = %3.1f%%\n\n",
    [myArteries pO2],[myArteries oxygenContent],[myArteries oxygenSaturation]*100,
    [myArteries pCO2],[myArteries carbonDioxideContent],[myArteries pH],
    x,[myArteries bicarbonateContent],
    [myLungs respiratoryRate],[myLungs tidalVolume], [myLungs totalVentilation],
    [myHeart effectiveCardiacOutput],[myLungs deadSpace],
    [myHeart effectiveVenousAdmixture]];
    return result;
}

-(NSString *) dumpParametersReport	// Print out first 6 changeable parameters
{
    NSString *result;
    result = [[NSString alloc] initWithFormat:@"\n     List of first six parameters:\n     Inspired O2 %%:%6.2f\n     Inspired CO2 %%:%6.2f\n     Cardiac performance %%:%6.2f\n     Metabolic rate %%:%6.2f\n     Right to left:%6.2f\n     Extra dead space:%6.2f\n",
    [myLungs FiO2],[myLungs FiCO2],[myHeart cardiacFunction],metabolicRate, [myHeart rightToLeftShunt],[myLungs addedDeadSpace]];
    NSLog(@"%@",result);
    return result;
}
    

-(NSString *) cycleReport
{
// This is designed to print out whatever should come at each cycle for O2, CO2, ventilation, and RRate.
// It is somewhat based on BRETH.  The assumed string length is 72 characters, and the string will be
// appended onto a time measurement.
//
    NSMutableString *result;		// holds the physiological
    NSMutableString *temp;		// holds the gases until attached to result
    int pO2, pCO2, vent, rate;
    int minutes, seconds;
    NSRange O_Range, V_Range, C_Range, R_Range;	// NSRange is struct with location, length int members
    const float factor = (float)72/120;  	// Converts a scale of 120 to a length of 72 characters
    // Now get these puppies
    pO2 = [myArteries pO2];
    pCO2 = [myArteries pCO2];
    vent = [myLungs totalVentilation];
    rate = [myLungs respiratoryRate];
    O_Range.location = (pO2 < 120) ? pO2*factor :72;  
    O_Range.length = 1;
    C_Range.location = (pCO2 < 120) ? pCO2*factor :72;
    C_Range.length = 1;
    V_Range.location = (vent < 120) ? vent*factor :72;
    V_Range.length = 1;
    R_Range.location = (rate < 120) ? rate*factor :72;
    R_Range.length = 1;
    seconds = totalSeconds % 60;
    minutes = totalSeconds / 60;

    result = [[NSMutableString alloc] initWithCapacity:82];
    [result appendFormat:@"%4d:%2d     ", minutes, seconds];
    temp = [[NSMutableString alloc] initWithCapacity:73];
    [temp setString:@"                                                                         \n"];
    [temp replaceCharactersInRange:O_Range withString:@"O"];	// pO2 in mm Hg
    [temp replaceCharactersInRange:C_Range withString:@"C"];	// pCO2 in mm Hg
    [temp replaceCharactersInRange:V_Range withString:@"V"];	// total ventilation in liters
    [temp replaceCharactersInRange:R_Range withString:@"F"];	// frequency of breaths per minute
    [result appendString:temp];
    [temp release];
    return result;
}


-(void) dealloc
{
    NSLog(@"Destroying human"); 
    [myArteries release];
    [myBrain release];
    [myTissues release];
    [myVeins release];
    [myHeart release];
    [myLungs release];
    [myBag release];
    [myVentilator release];
    [super dealloc];
}

-(void) simulate:(int)i
{
// Local constants and variables for convenience
    const float ft = 1./60;
    const float e = 0.0000001;
    static float c1,c2,c3, c4,c5,c6,c7,c8,c9,c10, c11, c12, c13,c14,c15, c16, c17,c18, c19;
    static float c20, c21,c22, c23, c24, c25, c26, c27, c28, c29,c30, c31, c32, c33;
    static float c34, c35, c36,c37, c38, c39, c40, c41, c42, c43,c44, c45, c46, c47, c48, c49;
    static  float c50, c51, c52, c53, c54, c55, c56, c57, c58, c59,c60;
    static  float c61, c62, c63, c64, c65, c66, c67, c68, c69,c70;
    static float c71, c72, c73, c74, c75, c76;
    static float x,xx, y,z,s, u,v,w;
    static float pj= 97.0730;
    static float xu, fd,xc2;
    static float qa = 249.6541;
    static float qb = 199.5492; 
    static float pc = 0.7993;
//    static float xpc;  // for pc when it represents gas amounts instead of mixture
    static  float c2ref, xnew;
    static  int	nft, m, n, iter;	// used in delay functions
    static int pntdly = 1, pl = 0;
    static float po2, pc2, fy;	// local variables to store pO2 and pCO2
    
    totalSeconds++;		//  computation interval is always 1.0 seconds

// Conduct the constant calculations as in the original MacPuf
// I originally did not plan to do this but in fact it is easier to isolate the
// constants in one part of the simulation loop.  

    if (i == 1) {
        NSLog(@"Initializing constants");
        
    x = [myLungs tidalVolume] * [myLungs respiratoryRate];
    xx = barometric / simlt;
    if ((x < 1) && ([myVentilator On])) [myLungs setAlveolarVentilationPerIteration:0.001];
    c1 = 1000./[myVeins venousBloodVolume];
    c2 = 100./[myVeins venousBloodVolume];
    c3 = 0.0203*Hgb;
    c4 = ([myLungs lungElastance] + 105)*0.01;
    c5 = 2.7/([myLungs vitalCapacity] + 0.4);
    c6 = [myLungs FEV] * 25. + 29.;
    
// Prepare to decrease ventilatory effect of temperature in c45, increase cardiac output increase
// with temperature increase (c8), reduce cardiac output response to exercise slightly (c9)
    z = [myTissues oxygenConsumption] * metabolicRate * 0.00081;
    c7 = z * (pow((temperature -26),1.05));
    c8 = (30 - [myVentilator PEEP]*5/[myLungs lungElastance])*0.0028*
        [myHeart restingCardiacOutput]*(temperature - 23.);    
    c9 = (c7 - [myTissues oxygenConsumption])*.0074;
    c10 = ft * 0.005; // new value 0.05
    c11 = xx - 0.03 * temperature * temperature - 5.92;
    c11 = (c11 > 0.00001) ? c11 : 0.00001;
    c12 = c11 * 0.003592/(273 + temperature);
    c13 = 0.9/[myTissues extraFluidVolume];
    c14 = [myHeart leftToRightShunt] + 1;
    c15 = 2./weight;
    c16 = [myHeart cardiacFunction] * 0.01;
    c17 = ft * 10;
    c18 = [myHeart admixtureEffect] * 80.;
    c19 = (metabolicRate - 90.) * [myLungs RVADM] * .05;
    c19 = (c19 > -1) ? c19 : -1;
    c20 = 650. * [myLungs vitalCapacity];
    c20 = ([myLungs addedDeadSpace] > 0) ? c20 + sqrt([myLungs addedDeadSpace]) * 15: c20;
    c21 = (40 - [myVentilator PEEP]) * .025;
    c22 = 4.5/ft;
    c23 = 20.*simlt/barometric;
    c24 = [myHeart restingCardiacOutput]*0.3;
    c25 = 100. * c12;
    c26 = 7./[myTissues extraFluidVolume];
    c27 = ft * 0.1;
    c28 = 30000./([myVeins venousBloodVolume]+1000.);
    c29 = ft * 0.0039*pow(weight,0.425)*pow(height, 0.725);
    c30 = 520 / [myTissues extraFluidVolume];
    c31 = 2.7/[myTissues extraFluidVolume];
    c32 = c29 + 0.0000001;
    c33 = c3*308 - [myTissues extraFluidVolume]*0.65*c30;
    c34 = 0.004/(c12 * ft);
    c35 = 0.01/c12;
    c36 = 7.7*c13;
    c37 = [myLungs inspiration]/ft;
    c38 = [myLungs totalLungVolume]*0.00000004/pow(ft, 1.5);
    c39 = ft * 0.127;
    c40 = c29 *(metabolicRate-25)*1.3;
    c41 = ft *(temperature - 24.5) * 1.82;
    c42 = c29 * 0.003;
    c43 = 1/(1+7.7*c3);
    x = pow((metabolicRate * 0.01),0.8)*0.2*[myLungs vitalCapacity];
    c44 = x * 0.0132 * [myLungs hypercapnicVentResponse];
    c45 = x * 0.008 * [myLungs hypoxicVentResponse];
    
//  Slightly change ventilation effects of exercise
    c46 = [myLungs neurogenicVentResponse]*0.714*(pow(z*(temperature - 26)*0.0005, 0.97)+0.01);
    
//  Reduce temperature effects on ventilation
    x = 356./c11 + 0.5;
    x = (x>1) ? 1 : x;
    y = pow(temperature-29,1.5);
    if (temperature > 37) y = 23;
    c47 = [myLungs ventilatoryCoupling] * 0.000262*y*x;
    c48 = 0.04 *(temperature -26) * [myLungs vitalCapacity];

// Increase respiratory rate effects of elastance changes
    c49 = 8. + pow([myLungs lungElastance], .75);
    c50 = (150 + [myLungs ventilatoryCoupling])*0.0275*(temperature - 17);
    c51 = [myLungs tidalVolume] * [myLungs respiratoryRate]* 0.001;
    c52 = [myLungs totalLungVolume]*0.03 - 20 + [myLungs addedDeadSpace];
    c53 = 0.8/ft;
    c54 = [myLungs addedPFTDeadSpace] * 0.001;
    
    c55 = 0.2/ft; // 0.1 / ft old value
    c56 = 0.001/ft;
    c57 = ft * 60;
    c58 = ft * 1.27;
    c59 = ft * 0.3;
    c60 = ft * 0.008;

// Reduce rate of cardiac output increase at start exercise
    x = pow(metabolicRate * 0.01,1.45);
    if (x > 12) x = 12;
    c61 = 0.00025 * RCOAJ/(ft*x);
    //c61 = 0.22/ft; // old value
    c62 = ft * 50000./([myLungs neurogenicVentResponse]+300.);
    //c62 = ft * 240000./([myLungs neurogenicVentResponse]+300.); // old value
    
    c63 = ft * c7 * 0.12;
    c64 = 0.01488*Hgb*([myTissues extraFluidVolume]+[myVeins venousBloodVolume]*0.001);
    c65 = 7.324 - [myLungs neurogenicVentResponse]*0.00005;
    c66 = c65 - 0.002;
    c67 = [myLungs neurogenicVentResponse] - 30.;

// Reduce rate increase of ventilation at start exercise
    c68 = ft * 1500./(metabolicRate + 200.);
    //c68 = ft * 3000./(metabolicRate + 200.); // old value
    
    c69 = (fitness - 20)*0.00035;
    c70 = c29 * 1.3;

// New constants for 2,3 DPG changes and fitness
    c71 = 21.7 + male*1.6;
    c72 = ft * 0.002;
    x = (metabolicRate*1.5 - 150.)*0.02 - 7;
    if (x < -7) x = -7;
    if (x > 0) x = 0;
    c73 = fitness + x;
    c74 = 0.000005/ft;
    c75 = 0.002/ft;
    c76 = 0.05/ft;

// When user adds bicarb the total amount needs to be spread over the run time, so dose must be
// adjusted according to the number of iterations in the run.
    if (i == 1) {
        [myVeins setAddBicarb:[myVeins addBicarb]/(float)iterations];
    }
    // only do on first pass!
    
    DPH = 7.4 + (DPG - 3.8)*0.025;
    if (DPH > 7.58) DPH = 7.58;
    if (DPG > 13) DPG = 13;

// The code below allows instant changes in lung gas composition and pressures after
// an acute change in barometric pressure.
    if (c11 < BARRF) {
        x = c11/BARRF;
        [myLungs setAmountOfOxygen:[myLungs amountOfOxygen]*x];
        [myLungs setAmountOfCO2:[myLungs amountOfCO2]*x];
        [myLungs setAmountOfNitrogen:[myLungs amountOfNitrogen]*x];
        [myLungs setPO2:[myLungs pO2]*x];
        [myLungs setPCO2:[myLungs pCO2]*x];
    }
    
    if (c11 > BARRF) {
        x = (c11-BARRF)*0.0083*[myLungs totalLungVolume]/BARRF;
        [myLungs setAmountOfOxygen:[myLungs amountOfOxygen]+x*[myLungs FiO2]];
        [myLungs setAmountOfCO2:[myLungs amountOfCO2]+x*[myLungs FiCO2]];
        [myLungs setAmountOfNitrogen:[myLungs amountOfNitrogen]+x*(100 - [myLungs FiO2]-[myLungs FiCO2])];
        xx = c11/([myLungs amountOfOxygen]+[myLungs amountOfCO2]+[myLungs amountOfNitrogen]);
        [myLungs setPO2:[myLungs amountOfOxygen]*xx];
        [myLungs setPCO2:[myLungs amountOfCO2]*xx];
    }
    }    
    
// Adjust cardiac output for hypoxia, changes in oxygen consumption, etc. and limit to
// reasonable values.  This is done by computing some constants and telling the myHeart
// object to adjust the cardiac parameters.    

    y = ([myArteries oxygenContent] * 0.056 < 0.4) ? 0.4 : [myArteries oxygenContent]*0.056;
    [myHeart setEffectiveCardiacOutput:
        [myHeart dampChange:((c8 + c9)/y)*c16
                   oldValue:[myHeart effectiveCardiacOutput]
               dampConstant:c61]];
    if ([myHeart cardiacFunction] < 3) [myHeart setEffectiveCardiacOutput:e];
    if ([myHeart effectiveCardiacOutput]>[myHeart maximumCardiacOutput]) [myHeart setEffectiveCardiacOutput:
        [myHeart maximumCardiacOutput]];
    [myHeart setDecilitersPerIteration:[myHeart effectiveCardiacOutput]*c17];
    [myHeart setFitnessAdjustedOutputPerIteration:([myHeart decilitersPerIteration]*(1 - c69*[myHeart effectiveCardiacOutput]))];
    // THERE IS A PROBLEM HERE THAT I DO NOT UNDERSTAND AS THE VALUE IS SET 10 TIMES TOO LOW
    // FOR THE PRESENT I AM PATCHING OUT THE USE OF FITNESS ADJUSTED CARDIAC OUTPUT JUST TO GET
    // MACPUF DEBUGGED.  I WILL NEED TO COME BACK TO THIS ISSUE.
		// October 2011 - returning to this issue prior to Big Nerd Ranch
    
// Oxygen content or pressure affects venous admixture and very slowly DPG
    DPG = (DPG + (23.3 - [myArteries oxygenContent] - DPG) * ft * .05);

// Increase venous admixture if alveolar pO2 is very high
    x = [myLungs pO2];	
    y = [myLungs pO2];
    x = ( x>200) ? 200 : x;
    y = ( y>600) ? 600 : y;
    x = ([myLungs pO2] > 400) ? x - (y - 400.)*.3 : x;
    x = (x > 55) ? x : 55;

// Venous admixture (effective) is changed by PEEP, alveolar pO2 and any
// fixed right to left shunt
    
// We also limit venous admixture so it cannot exceed 100
    [myHeart setEffectiveVenousAdmixture:(((c18/x+c19)*c21 + [myHeart rightToLeftShunt]) > 100)
        ? 100
        : ((c18/x+c19)*c21 + [myHeart rightToLeftShunt])];

// Arterial CO2 and O2 amounts incremented by mixture of pure venous and pure
// idealized pulmonary capillary blood, determined by ratios of x and pc.
    x = [myHeart effectiveVenousAdmixture] * .01;
    pc = 1. -x;

    
// Nitrogen content is determined in terms of partial pressures assuming a linear
// dissociation curve
    [myArteries setAmountOfN2:
        [myArteries amountOfN2] + [myHeart decilitersPerIteration]*
        ((x * [myTissues pN2] + pc *(c11 - [myLungs pO2] - [myLungs pCO2]))*.00127 -
         [myArteries effluentNitrogenContent])];
    
    u = x *[myVeins carbonDioxideContent] + pc * [myLungs carbonDioxideContent];
    v = x *[myVeins oxygenContent] + pc * [myLungs oxygenContent];
    
    [myArteries setAmountOfCO2:
        ([myArteries amountOfCO2]+[myHeart decilitersPerIteration]*(u - [myArteries effluentCO2Content]))];
    if ([myArteries amountOfCO2] < 0.001) [myArteries setAmountOfCO2:0.001];
    
    [myArteries setAmountOfOxygen:
        ([myArteries amountOfOxygen] + [myHeart decilitersPerIteration]*(v - [myArteries effluentOxygenContent]))];

// Contents passing to the tissues are affected by rates of blood flow
    w = c22/[myHeart effectiveCardiacOutput];

// If heart is effectively stopped then prevent changes in arterial blood composition
    if (w > 100) {
        // NSLog(@"The cardiac output is effectively zero");
        w = 0;
    }
    [myArteries setEffluentOxygenContent:
        [myArteries dampChange:[myArteries amountOfOxygen]*0.1
                      oldValue:[myArteries effluentOxygenContent]
                  dampConstant:w]];
    [myArteries setEffluentCO2Content:
        [myArteries dampChange:[myArteries amountOfCO2]*0.1
                      oldValue:[myArteries effluentCO2Content]
                  dampConstant:w]];
    [myArteries setEffluentNitrogenContent:
        [myArteries dampChange:[myArteries amountOfN2]*0.1
                      oldValue:[myArteries effluentNitrogenContent]
                  dampConstant:w]];
    z = c17 * [myHeart effectiveCardiacOutput];

// Arterial O2 and CO2 contents will reach the chemoreceptors in the brain
// To calculate the tensions we will call the FORTRAN GSINV routine
// which has not yet been implemented.  First we must set the contents:
    [myArteries setOxygenContent:
        [myArteries dampChange:v
                      oldValue:[myArteries oxygenContent]
                  dampConstant:z]];
    
    [myArteries setCarbonDioxideContent:
        [myArteries dampChange:u
                      oldValue:[myArteries carbonDioxideContent]
                  dampConstant:z]];
    if ([myArteries carbonDioxideContent] < 0.001) [myArteries setCarbonDioxideContent:0.001];

// We must also setup the bicarbonate  which must take into account
// in vitro influence of arterial pCO2 on bicarbonate concentration:
    [myArteries setBicarbonateContent:
        c3 * ([myArteries pCO2] - XC2PR) +[myVeins bicarbonateContent]];
    if (([myArteries bicarbonateContent]*[myArteries pCO2]) <0) {
        NSLog(@"Bicarbonate less than zero, patient is dead.");
        // need to go to a death routine somewhere but not yet defined
    }

// And set the pH based on the adjusted bicarbonate:
    [myArteries updatePh];
    
// Estimate arterial pCO2 change for later effects on brain chemoceptors
    [myBrain setC2CHN:[myArteries pCO2]];
    [myArteries calcPressures:temperature:Hct:Hgb:DPG];
    [myBrain setC2CHN:[myArteries pCO2]-[myBrain C2CHN]];
    pj = [myArteries oxygenSaturation]*100;

// u represents specified energy expenditure from metabolic rate potentially changed
// by the user - this is incorporated in constant c7.  
    s = [myLungs effectiveVentResponse];
    s = (s < 0) ? -s : s;

// First term of u is oxygen consumption of respiratory muscles and the second
// term is oxygen consumption of heart.  In event of anaerobic metabolism the
// energy requirements are the same but much more lactate is produced (11 times)
// and oxygen is spared (XLACT factor).

// In original MacPuf, there was a check to make sure the tissue amount of oxygen was
// greater than an error term;  otherwise death routine was called.  However, in revisions
// in 1987, the authors added the concept that tissue oxygen utilization will stop at
// very low pressure, and if tissue pO2 were under 10, oxygen consumption needs to be
// tapered off.
    
    u = ft * (pow(s,c4)*c5+c7 + [myHeart effectiveCardiacOutput]);
// PATCHOUT OF FITNESS ADJUSTMENT
//    x=  [myTissues amountOfOxygen] + [myHeart fitnessAdjustedOutputPerIteration] *
//        ([myArteries effluentOxygenContent] - [myTissues oxygenContent]) - u + XLACT;
		x=  [myTissues amountOfOxygen] + 0.98*[myHeart decilitersPerIteration] *
				([myArteries effluentOxygenContent] - [myTissues oxygenContent]) - u + XLACT;



// If pO2 under 10 then taper the oxygen consumption
    xu = (x*c31 < 10) ?
        c7*ft*([myTissues pO2] - 10)/([myTissues pO2] - x*c31) : 0;
    xu = (xu < c7*ft) ? xu : c7*ft;  // XU = AMIN1(C7*FT,XU) - limit the adjustment value
    [myTissues setAmountOfOxygen:x + xu]; // add back in the oxygen value in x
    if ([myTissues amountOfOxygen] < 0.01) [myTissues setAmountOfOxygen:0.01]; // handle decompression
      

// Compute the tissue pO2 damping appropriately:
    [myTissues setPO2:
        [myTissues dampChange:[myTissues amountOfOxygen]*c31
                     oldValue:[myTissues pO2]
                 dampConstant:c55]];
    x = [myTissues amountOfOxygen] - 250;
    if (x > 0 ) {
        [myTissues setPO2:45 + 0.09*x];	// FORTRAN Line 520
    }
    
// FORTRAN LINE 530 STARTS HERE
// Lactate metabolism is handled here.  Y represents catabolism related to
// cardiac output and metabolism
    y = c29*[myArteries lactateConcentration];

// X is a threshold - when tissue pH less than 7.0 catabolism is impaired
// Cerebral blood flow is used to give appropriate changes in lactate metabolism
// with low pCO2 or alkalosis - this is convenience, not physiology.  CBF is computed
// elsewhere in the simulation and happens to change in the appropriate way.
    w = [myBrain bloodFlow]*.019;
    if (w > 1) w = 1;
    x = [myTissues pH] * 10. - 69.;
    if (x > w) x = w;

// Z is catabolic rate for lactate.  First term is hepatic removal, second term is renal removal
// with pH influence, and third term is blood flow related metabolism by muscles, made dependent
// on cardiac output.  The entire expression is multipled by Y, a function of lactate concentration.
    z = y*(x*0.8612+0.0232*pow(2,(8-[myTissues pH])*3.33)+[myHeart effectiveCardiacOutput]*0.01);
    w = c70/(w + 0.3);

// Fitness is the threshold for switching to anaerobic metabolism;  by its name one can infer
// it should relate to physical fitness!  
    v = c73 - [myTissues pO2];

// If the anaerobic trigger occurs, these statements rapidly increase lactate production (w) if
// tissue pO2 is low.  In addition, catabolism (z) drops if tissue pO2 is too low.
    if (v > 0) {
        w = w + c42*pow(v+1,4);
        z = z *0.04*[myTissues pO2];
    }

// XLACT is O2 sparing effect of lactic acid production;  it may not exceed actual O2 consumption (u).
    x = 2.04*(w - c32);
    if (x > u) x = u;
    XLACT = [self dampChange:x
                    oldValue:XLACT
                dampConstant:c53];		// Fortran line 590
    
// Limit of rate of lactate formation determined by metabolic drive to tissues, or the level of exercise.
// It is also related to body size, which is captured in c29.

    if (w > c40) w = c40;

// Reduce lactate catabolism (z) if effective cardiac output is less than 1/3 of normal resting
// cardiac output to take account of likely diminished liver and kidney blood flow (and hence
// reduced lactate clearance.

    if ([myHeart effectiveCardiacOutput] < [myHeart restingCardiacOutput]*0.3) {
        z = z * [myHeart effectiveCardiacOutput]/c24;
    }
    
// Increase total lactate by difference between production and catabolism
    v = w - z;
    [myTissues setLactateAmount:[myTissues lactateAmount] + v];

// Reduce the rate of arterial lactate by using a greater damping constant;  this was
// a change to using c75 in the FORTRAN source instead of c55.
    [myArteries setLactateConcentration:
        [myArteries dampChange:[myTissues lactateAmount]*2./weight
                      oldValue:[myArteries lactateConcentration]
                  dampConstant:[myHeart effectiveCardiacOutput]*0.002/ft]];

// FORTRAN LINE 640
// Next we handle the nitrogen stores in tissues, moving N2 between fast (T)
// and slow (S) tissue compartments according to partial pressure differences.
    x = ([myTissues pN2]-[myTissues slowN2]) * c60;

// PATCHOUT ADJUSTMENT FOR FITNESS
//    [myTissues setAmountOfNitrogen:
//        [myTissues amountOfNitrogen] + [myHeart fitnessAdjustedOutputPerIteration] *
//        ([myArteries effluentNitrogenContent] - ([myTissues pN2]*0.00127))-x];
    [myTissues setAmountOfNitrogen:
        [myTissues amountOfNitrogen] + 0.98*[myHeart decilitersPerIteration] *
        ([myArteries effluentNitrogenContent] - ([myTissues pN2]*0.00127))-x];
    
    [myTissues setAmountSlowNitrogen: [myTissues amountSlowNitrogen] + x];

// Test to see if slow space is supersaturated
    y = ([myTissues amountSlowNitrogen]*c26 - c11)*c27;
    
// If supersaturated then augment excessNitrogen and decrease amountSlowNitrogen, or 
// vice versa if ambient pressure is relatively higher.
// Bubbles is arbitrary index for symptoms from nitrogen bubbles in the tissue, taking
// account of BTPS volume and loading by the number of molecules of gas - note that
// bubbles is only a rough index and the program was still in development in 1987.  I
// have incorporated the changes of 1987 by CJD to dampen the change in bubbles.
    if(y <= 0) {
                y = y * 0.3;
        if ([myTissues excessNitrogen] > 0) {
            [myTissues setAmountSlowNitrogen: [myTissues amountSlowNitrogen] - y];
    
//[myTissues setBubbles:pow([myTissues excessNitrogen],1.2)*20/barometric];  OLD VERSION
            
            [myTissues setBubbles:
                [myTissues dampChange:pow([myTissues excessNitrogen],1.2)*c23
                             oldValue:[myTissues bubbles]
                         dampConstant:0.005/(12*ft)]];
            [myTissues setExcessNitrogen: [myTissues excessNitrogen] + y];
        }
    }
     
    
// Compute the partial pressures
    [myTissues setSlowN2: [myTissues amountSlowNitrogen]*c26];
    [myTissues setPN2: [myTissues amountOfNitrogen]*c28];

// Tissue CO2 exchanges.  U is still the metabolism factor calculated earlier
// 0.001 converts from cc to litres
// PATCHOUT FITNESS ADJUSTMENT
//    [myTissues setAmountOfCO2:[myTissues amountOfCO2] +
//        ([myHeart fitnessAdjustedOutputPerIteration]*([myArteries effluentCO2Content]-[myTissues carbonDioxideContent])
//         + [myTissues respiratoryQuotient]*u)*0.001];
    [myTissues setAmountOfCO2:[myTissues amountOfCO2] +
        (0.98*[myHeart decilitersPerIteration]*([myArteries effluentCO2Content]-[myTissues carbonDioxideContent])
         + [myTissues respiratoryQuotient]*u)*0.001];
    
// Compute partial pressures from total CO2 and standard bicarbonate
// These methods were completely revised in 1987 to track movement up or down in tissue CO2 and
// modify the buffer constant accordingly.
    

    c2ref = [myTissues pCO2];
    [myTissues setPCO2:
        ([myTissues amountOfCO2]*c30 - [myTissues bicarbonateAmount]*c36+c33)*c43];	// FORTRAN Line 5 past 670

// Track movement up or down in tissue CO2 and modify buffer constant accordingly
    
    [myTissues setReferenceCO2:
        [myTissues referenceCO2] + ([myTissues pCO2] - c2ref)];
    [myTissues setTC3AJ:
    [myTissues dampChange:0.2*[myTissues referenceCO2]
                 oldValue:[myTissues TC3AJ]
             dampConstant:c10]];

   xnew = [myHeart fitnessAdjustedOutputPerIteration]*0.1*
       (([myVeins bicarbonateContent] -(XC2PR - 40.)*c3)-[myTissues bicarbonateAmount]*c13);
//   xnew = 0.98*[myHeart decilitersPerIteration]*0.1*
//       (([myVeins bicarbonateContent] -(XC2PR - 40.)*c3)-[myTissues bicarbonateAmount]*c13);
  
// 0.4 in line below represents buffers of lactic acid partly inside cells so that displacement of bicarbonate
// is less than strict molar equivalence
   
   [myTissues setBicarbonateAmount:[myTissues bicarbonateAmount] + xnew - 0.4 * v];

// Decrement pre-delay pool representing total amount on venous side although contents are effectively damped by the
// delay line
   [myVeins setBicarbonateAmount: ([myVeins bicarbonateAmount] - xnew)];

   [myTissues setBicarbonateContent:[myTissues bicarbonateAmount]*c13+([myTissues pCO2]-40)*c3 - [myTissues TC3AJ]];
   if (([myTissues bicarbonateContent] * [myTissues pCO2]) <= 0) NSLog(@"We have a bad fucking arithmetic problem in tissue bicarb!");
   [myTissues updatePh];
   [myTissues calcContents:temperature:Hct:Hgb:DPG];

// Amounts of gases in venous pool increase by arriving blood from tissues and decrement by blood going to lungs.
// Same for bicarbonate.  Venous contents for oxygen and CO2 are then determined.
   x = c69*[myHeart effectiveCardiacOutput] * [myHeart decilitersPerIteration];  // Not sure of this translation

// Bicarbonate addition adds CO2 (22.4 L = 1 mol HCO3)
   if ([myVeins addBicarb] > 0)
       [myVeins setAmountOfCO2:[myVeins amountOfCO2]+22.4 * [myVeins addBicarb]];
   
// PATCHOUT Fitness adjustment
//   [myVeins setAmountOfCO2:
//   [myVeins amountOfCO2] + [myHeart fitnessAdjustedOutputPerIteration]*[myTissues carbonDioxideContent]-
//       [myHeart decilitersPerIteration]*([myVeins carbonDioxideContent]*c14 - [myArteries carbonDioxideContent]*
//                                  [myHeart leftToRightShunt])+x*[myArteries effluentCO2Content]];
   [myVeins setAmountOfCO2:
       [myVeins amountOfCO2] + 0.98*[myHeart decilitersPerIteration]*[myTissues carbonDioxideContent]-
       [myHeart decilitersPerIteration]*([myVeins carbonDioxideContent]*c14 - [myArteries carbonDioxideContent]*
                                         [myHeart leftToRightShunt])+x*[myArteries effluentCO2Content]];
// NOT SURE IF THIS LINE SHOULD BE AVAILABLE OR NOT
// I THINK NOT - pCO2 goes into toilet if I leave this in place so need to find ou where it came from 	
//   [myVeins setAmountOfCO2: [myVeins amountOfCO2] + 0.1*[myHeart fitnessAdjustedOutputPerIteration]*[myTissues carbonDioxideContent]];
//   [myVeins setAmountOfCO2: [myVeins amountOfCO2] - [myHeart decilitersPerIteration]*[myVeins carbonDioxideContent]];
//   [myVeins setAmountOfCO2: [myVeins amountOfCO2] + x * [myArteries effluentCO2Content]];
   
   
//   [myVeins setAmountOfOxygen:
//       [myVeins amountOfOxygen] + [myHeart fitnessAdjustedOutputPerIteration]*[myTissues oxygenContent]-
//       [myHeart decilitersPerIteration]*([myVeins oxygenContent]*c14 - [myArteries oxygenContent]*
//                                  [myHeart leftToRightShunt])+x*[myArteries effluentOxygenContent]];
   [myVeins setAmountOfOxygen:
       [myVeins amountOfOxygen] + 0.98*[myHeart decilitersPerIteration]*[myTissues oxygenContent]-
       [myHeart decilitersPerIteration]*([myVeins oxygenContent]*c14 - [myArteries oxygenContent]*
                                         [myHeart leftToRightShunt])+x*[myArteries effluentOxygenContent]];
   
// Adjust tissue and venous pool bicarb amounts - bicarb moves after delay line into arterial side
   xnew = [myHeart fitnessAdjustedOutputPerIteration]*0.1*([myTissues bicarbonateAmount]*c13 -([myVeins bicarbonateContent]-
                                                                                            (XC2PR-40)*c3));
//   xnew = 0.98*[myHeart decilitersPerIteration]*0.1*([myTissues bicarbonateAmount]*c13 -([myVeins bicarbonateContent]-
//                                                                                               (XC2PR-40)*c3));

   [myVeins setBicarbonateAmount:[myVeins bicarbonateAmount]+xnew + [myVeins addBicarb]];
   [myTissues setBicarbonateAmount:[myTissues bicarbonateAmount]-xnew];

// Do the venous oxygen and CO2 content changes
   [myVeins setOxygenContent:[myVeins amountOfOxygen]*c2];
   [myVeins setCarbonDioxideContent:[myVeins amountOfCO2]*c2];

// Calculate bicarb content after infusion but before delay line
   [myVeins setBicarbonateContent:[myVeins bicarbonateAmount]*c1+([myTissues pCO2]-40)*c3-[myTissues TC3AJ]];
   XC2PR = [myTissues pCO2];
   if ([myVeins bicarbonateAmount]<=0) NSLog(@"We have a big fucking arithmetic problem in venous bicarb!");

// Call DELAY - will put this inline here.  New Year Day 2:13 PM

   nft = (int) (9*pow([myHeart effectiveCardiacOutput], 0.75)*ft+0.5);
   nft = (nft < 1) ? 1 : nft;
   nft = (nft > 10) ? 10 : nft;
   m = pntdly + nft - 1;
   for(iter = pntdly; iter <= m; ++iter) {
       // NSLog(@"The var iter is %i.\n", iter);
       n = iter;
       if (n > 10) n = n - 10;
       veinDelay[n - 1] = [myVeins oxygenContent];
       veinDelay[n + 9] = [myVeins carbonDioxideContent];
       veinDelay[n + 19] = [myVeins bicarbonateContent];
       veinDelay[n + 29] = XC2PR;
   }
   n = pntdly + nft;
   if (n > 10) n = n - 10;
   [myVeins setOxygenContent:veinDelay[n - 1]];
   [myVeins setCarbonDioxideContent:veinDelay[n+9]];
   [myVeins setBicarbonateContent:veinDelay[n+19]];
   XC2PR = veinDelay[n+29];
   pntdly = n;

   // Should be the end of the delay loop
   // I have set up the setPh procedure to expect to use the bicarb and pCO2 from the SAME object
   // and this is usually right, but if I need to pass other parameters I have to fool it, as shown here:
   // The call in Macpuf is to PHFNC(VC3CT, XC2PR) instead of (VC3CT, VC2PR)

   [myVeins updatePh:[myVeins bicarbonateContent]
              CO2:XC2PR];
   
// Next section concerns gas exchange in lungs.  PC is fraction of cardiac output perfectly mixed with
// alveolar gases.  U and V are amounts of each gas taken in per unit fraction time (ft).

   pc = [myHeart decilitersPerIteration]*c14*pc;
   x = [myLungs alveolarVentilationPerIteration]*c12;
   u = x * [myLungs FiO2];
   v = x * [myLungs FiCO2];

// Calculate the amounts of each gas in the lungs.  W is the volume at end of nominal inspiration.

   [myLungs setAmountOfOxygen:[myLungs amountOfOxygen]+u];
   [myLungs setAmountOfCO2:[myLungs amountOfCO2]+v];
   [myLungs setAmountOfNitrogen:[myLungs amountOfNitrogen]+x*(100 - [myLungs FiO2] - [myLungs FiCO2])];
   w = [myLungs amountOfOxygen]+[myLungs amountOfCO2] + [myLungs amountOfNitrogen];
   
// Now calculate partial pressures in the alveoli

   x = c11 / w;
   po2 = [myLungs amountOfOxygen]*x;		// These local copies of pO2 and pCO2 are used later
   pc2 = [myLungs amountOfCO2]*x;		// in the simulation loop.

// Change alveolar gas amounts in accordance with blood gas contents entering from veins
// and leaving the lungs.  PC = final amount of total gas at the end of everything.

   [myLungs setAmountOfOxygen:[myLungs amountOfOxygen] + pc*([myVeins oxygenContent]-[myLungs oxygenContent])];
   [myLungs setAmountOfCO2:[myLungs amountOfCO2] + pc*
       ([myVeins carbonDioxideContent]-[myLungs carbonDioxideContent])];
   [myLungs setAmountOfNitrogen:[myLungs amountOfNitrogen] + pc *
       ([myTissues pN2]*0.00127 - [myArteries effluentNitrogenContent])];
   pc = [myLungs amountOfOxygen]+[myLungs amountOfCO2] + [myLungs amountOfNitrogen];

// In next section, FY becomes positive only if more gas goes out than in, in which case FY is later
// brought into the calculation of effective dead space

//   if (pl == 2) {
//       fy = ([myLungs alveolarVentilationPerIteration]>= 20) ? (pc-w)*c34/[myLungs respiratoryRate]:0;
//   }

   if (pl != 2) {
       if ([myLungs alveolarVentilationPerIteration]>=20) {
           fy = (pc-w)*c34/[myLungs respiratoryRate];
       }
   }
   else
       fy = 0;
   
   if (pl < 0) {
       // CALL BAGER (5, PC, X, C12, MMENU)  LINE 790
       NSLog(@"Call Bager from line 790");
   }
   
// XVENT is volume exhaled in nominal time ft down to resting lung volume.  If this is negative
// then there must be diffusion respiration in which case we have to do the relevant sections
// that were in FORTRAN lines 720 and 730 - but I have moved them inline here to make more sense.

   [myLungs setExhaledVentilation:pc*c35 - [myLungs totalLungVolume]];
   
   if ([myLungs exhaledVentilation] < 0) {
       fd = [myLungs exhaledVentilation]*c12;
       [myLungs setAmountOfOxygen:[myLungs amountOfOxygen] - fd * [myLungs FiO2]];
       [myLungs setAmountOfCO2:[myLungs amountOfCO2] - fd * [myLungs FiCO2]];
       [myLungs setAmountOfNitrogen:[myLungs amountOfNitrogen]- fd * z];
       }
   else {
       x = [myLungs exhaledVentilation]*c25;
       [myLungs setTotalVentilation:x/pc];
       x = x/c11;
       y = x * [myLungs pO2];
       z = x * [myLungs pCO2];
       pc = x*(c11 - [myLungs pO2] - [myLungs pCO2]);
       
       //[myLungs setTotalVentilation:[myLungs exhaledVentilation]*c25/pc]; 	// OLD version
       //y = [myLungs totalVentilation]*[myLungs amountOfOxygen];			// I think no difference
       //z = [myLungs totalVentilation]*[myLungs amountOfCO2];
       //pc = [myLungs totalVentilation]*[myLungs amountOfNitrogen];
       qa = (u - y)/ft;
       qb = (z - v)/ft;
       //qa = u - y;
       //qb = z - v;
       if (pl > 0.5) {
           //CALL BAGER (4, XVENT, X, C12, MMENU)  LINE 820
           NSLog(@"Call BAGER from line 820");
           if (x < -9000) NSLog(@"We have a bad fucking arithmetic problem in Fortran line 820!");
       }
       

       if ([myLungs alveolarVentilationPerIteration] < e) {
           qa = 0.001;
           qb = e;
       }
           // Set the new amounts of gas
           [myLungs setAmountOfOxygen:(([myLungs amountOfOxygen]-y)>0.01) ? [myLungs amountOfOxygen] - y : 0.01];
           [myLungs setAmountOfCO2:(([myLungs amountOfCO2]-z) > 0.01) ? [myLungs amountOfCO2] - z : 0.01];
           [myLungs setAmountOfNitrogen:(([myLungs amountOfNitrogen]-pc)>0.01) ? [myLungs amountOfNitrogen] - pc : 0.01];
   }
  
   
// FORTRAN line 850 !
   u = c11/([myLungs amountOfOxygen]+[myLungs amountOfCO2] + [myLungs amountOfNitrogen]);

// Take account of inspiratory to expiratory duration ratio
   v = c37/[myLungs respiratoryRate];
   v = (v > 4) ? 4 : v;
   if ([myLungs alveolarVentilationPerIteration] < 20) v = 0;


// Speed of change (x) of alveolar gas tensions is function of tidal volume
   x = ([myLungs tidalVolume]+100)*c38;
// compute end expiratory partial pressures
   y = [myLungs amountOfOxygen]*u;
   z = [myLungs amountOfCO2] * u;
   [myLungs setPO2:
   [myLungs dampChange:(y+(po2 - y)*v)
              oldValue:[myLungs pO2]
          dampConstant:x]];

   [myLungs setPCO2:
   [myLungs dampChange:(z+(pc2-z)*v)
              oldValue:[myLungs pCO2]
          dampConstant:x]];
   if ([myLungs pO2] < 0.00001) [myLungs setPO2:0.00001];
   if ([myLungs pCO2] < 0.00001) [myLungs setPCO2:0.00001];

// Determine respiratory quotient (expired) then alveolar gas tensions and then finally
// the contents of O2 and CO2 in pulmonary capillary blood
   if (qa != 0) pc = qb/qa;
   //if (qa != 0) [myTissues setRespiratoryQuotient:qb/qa];
   x = [myVeins bicarbonateContent] + c3*([myLungs pCO2] - XC2PR);
   if (x < e) NSLog(@"We have a bad fucking arithmetic problem in old Fortran line 930");
   // NOTE:  I am skipping some detailed arithmetic traps for now but anticipate having to go back!


   [myLungs updatePh:x
              CO2:[myLungs pCO2]];
   [myLungs calcContents:temperature:Hct:Hgb:DPG];
   
// Now determine cerebral blood flow adjustments in relation to cardiac output and brain pH (pCO2 sensitive)
   z = sqrt([myHeart effectiveCardiacOutput])*0.5;
   if (z > 1) z = 1;
   // Increase CBF for falling O2 saturation - pj was stored earlier and is 100*sat
   y = (7.40 - [myBrain pH])*([myBrain pCO2]*0.0184-[myBrain bicarbDeviation]*0.1)*(117-pj)*0.05;
   if (y > 0) y = 300*pow(y,2);
   if (y > 4.4) y = 4.4;
   [myBrain setBloodFlow:
        [myBrain dampChange:(y-.12)*42.8*z+[myBrain C2CHN]*7
                    oldValue:[myBrain bloodFlow]*z
                dampConstant:c76]];
   if ([myHeart effectiveCardiacOutput]*2 > [myBrain bloodFlow]) [myBrain setBloodFlow:[myHeart effectiveCardiacOutput]*2];

// Compute brain gas amts by metab assuming RQ of 0.98 and allowing for different amts supplied by arterial blood
// and leaving in venous blood.  Check for arithmetic errors and then calc brain gas tensions from
// guesstimated dissocation curves.
   y = [myBrain bloodFlow] * c39;
   x = c41 * ([myBrain oxygenationIndex] + 0.25);
   z = x;
   if ([myBrain pO2] <= 18) {
       z = x * ([myBrain pO2] * 0.11 - 1);
       x = x*(19-[myBrain pO2]);
       if (z < 0) z = 0;
   }
   
   [myBrain setAmountOfOxygen:[myBrain amountOfOxygen]+y*([myArteries oxygenContent]-[myBrain oxygenContent])
           -2 * z *([myBrain oxygenationIndex]+0.1)];
   if ([myBrain amountOfOxygen] < 0.1) [myBrain setAmountOfOxygen:0.1];

   [myBrain setAmountOfCO2:[myBrain amountOfCO2]+y*([myArteries carbonDioxideContent]-[myBrain carbonDioxideContent])
       + 2.15*x];
   [myBrain setPO2:[myBrain amountOfOxygen]*1.6];
   [myBrain setPCO2:[myBrain amountOfCO2]*0.078];
   w = [myBrain pCO2] - 40;
   y = [myBrain bicarbonateContent] + [myBrain bicarbDeviation] + 0.2*w;

// Small proportion of added bicarbnate is added also to CSF, affecting breathing appropriately
   [myBrain setBicarbDeviation:[myBrain bicarbDeviation] + (([myArteries bicarbonateContent]-24)*0.3 -
                                                            [myBrain bicarbDeviation])*c42];
   
// Adjust bicarb to pCO2 then calc brain pH (i.e. pH at the receptors).  Then determine contents
// of O2 and CO2 in blood leaving the brain.

   x = 6.1 + log10((2*y+[myArteries bicarbonateContent])/((2*[myBrain pCO2]+[myArteries pCO2])*0.03));
   z = pow(((abs_r(x - [myBrain pH])+e)*100),2)+.04;
   if (z > c17) z = c17;

// Restrict rate of change of brain receptor pH
// Fortran line 1080  NOTE that setpH is NOT same function as setPh!!
   [myBrain setPH:
       [myBrain dampChange:x
                  oldValue:[myBrain pH]
              dampConstant:z]]; 
    z = 6.1 + log10(([myVeins bicarbonateAmount]*c1+([myBrain pCO2]-40)*c3)/([myBrain pCO2]*0.03));
    xc2 = [myBrain pH];
    [myBrain setPH:z];
    [myBrain calcContents:temperature:Hct:Hgb:DPG];
    [myBrain setPH:xc2];
    
 // Now we have some ventilation calculations, which hopefully will close the loop on old Puf.
    if ([myVentilator On]) [myLungs setTotalVentilation:c51];

// Natural ventilation controls total vent (U and SVENT) = sum of central CO2 chemoreceptor drive
// (slope x, intercept z) O2 lack receptor (slope y) central neurogenic drive (proportional to
// oxygen consumption, etc.) and chemoceptors take account of rapid changes in CO2 as well as O2 and sat.
// Fortran Line 1100

    y = (118 - pj)*0.05 + [myBrain C2CHN]*0.05+[myVeins addBicarb]*.2;
    z = y * 0.002;
    x = (c65 + z - [myBrain pH])*1000*y;
    if (x < 0) x = 0;
    w = (c66 + z - [myBrain pH])*150*y;
// High brain pH or low CO2 only inhibits ventilation if learnt intrinsic drive (cz) is reduced or gone
    if (w < 0) {
        if (c67 > 0) w = 0;
    }
    z = ([myBrain pCO2] - 120) * 0.25;
    if (z < 0) z = 0;
    y = (98 - pj)*([myArteries pCO2]-25)*.12;
    if (y < 0) y = 0;

// Index of brain oxygenation lowers and stops breathing eventually if too low
    u = [myBrain amountOfOxygen] - 10;
    u = (u <0) ? 0 : 1;
    [myBrain setOxygenationIndex:
        [myBrain dampChange:u
                   oldValue:[myBrain oxygenationIndex]
               dampConstant:c63]];
// Prevent immediate changes in specified vent capacity
    XRESP = [self dampChange:c46
                    oldValue:XRESP
                dampConstant:c68];
// Compute total additive effects of ventilatory stimuli
    u = (c44*(x + w) + c45 * y + XRESP - z)*c47;
    if (u > c6) u = c6;  // restrict to a maximum value stored in c6
    
// Damp the speed of response according to cardiac output and depth of breathing, include brain oxygenation index
    x = ([myHeart effectiveCardiacOutput]+5)*c62/([myLungs tidalVolume]+400);
    [myLungs setEffectiveVentResponse:[myBrain oxygenationIndex]*
        [self dampChange:u
                oldValue:[myLungs effectiveVentResponse]
            dampConstant:x]];

    // NOW A SERIOUS RAT NEST OF FORTRAN IF STATEMENTS:
    
    if (pl < 0) {
        [myLungs setTotalVentilation:e];
        [myLungs setRespiratoryRate:0.0001];
    }
    
    else { // pl > = 0
        if (([myLungs effectiveVentResponse] < c48) && [myVentilator Off]) {
            [myLungs setTotalVentilation:e];
            [myLungs setRespiratoryRate:0.0001];
        }
        else { // effectiveVentResponse must be > c48 but the ventilator could be on or off so we test
            if ([myVentilator Off]){
                [myLungs setTotalVentilation:[myLungs effectiveVentResponse]];
                [myLungs setRespiratoryRate:(c49 + pow([myLungs totalVentilation], 0.7)*0.37)*c50/(pj+40)];
            }
        }
        if (([myLungs respiratoryRate] > 1) && ([myHeart effectiveCardiacOutput] > 0.5)) {
            u = [myLungs pO2] * 0.15;
            u = (u > 70) ? 70 : u;
            [myLungs setDeadSpace:[self dampChange:(c52+[myLungs totalVentilation]*100 / pow([myLungs respiratoryRate],1.12) + 20 * [myLungs totalVentilation]/([myHeart effectiveCardiacOutput]+5)+u+fy+c54*([myLungs tidalVolume]+500))
                                          oldValue:[myLungs deadSpace]
                                      dampConstant:c55]]; 
        }
    }
    

    [myLungs setTidalVolume:[myLungs totalVentilation]*1000/[myLungs respiratoryRate]];
    if([myVentilator Off]) {
        [myLungs setTidalVolume:([myLungs tidalVolume]>c20) ? c20 : [myLungs tidalVolume]];
        [myLungs setRespiratoryRate:[myLungs totalVentilation]*1000/[myLungs tidalVolume]];
    }

    [myLungs setAlveolarVentilationPerIteration:[myLungs respiratoryRate]*([myLungs tidalVolume] - [myLungs deadSpace]) * ft];
    if ([myLungs alveolarVentilationPerIteration] <= 0) [myLungs setAlveolarVentilationPerIteration:e];
    [myLungs setAlveolarMinuteVent:[myLungs alveolarVentilationPerIteration]*c56];

    [myBrain setSymptomFlag:([myBrain oxygenationIndex]>0.3) ? [myBrain symptomFlag]- [myBrain oxygenationIndex]*c59
                                                             : [myBrain symptomFlag] - ([myBrain oxygenationIndex]-1)*c58];
    // CALL DEATH

    BARRF = c11;
    
   
// At end of simulation run (iterations) re-zero the added bicarbonate or acid variable so it won't add again
   if (i == iterations) [myVeins setAddBicarb:0];
   
}

   
       

-(void) changeValues:(NSMutableArray *)arrayOfFactors
{
    NSLog (@"Changing the value");
    [myLungs setFiO2:[[arrayOfFactors objectAtIndex:0] currentValue]];		
    [myLungs setFiCO2:[[arrayOfFactors objectAtIndex:1] currentValue]];		   
    [myHeart setCardiacFunction:[[arrayOfFactors objectAtIndex:2] currentValue]];	    
    metabolicRate = [[arrayOfFactors objectAtIndex:3] currentValue];		
    [myHeart setRightToLeftShunt:[[arrayOfFactors objectAtIndex:4] currentValue]];	
    [myLungs setAddedDeadSpace:[[arrayOfFactors objectAtIndex:5] currentValue]];		
    [myLungs setTotalLungVolume:[[arrayOfFactors objectAtIndex:6] currentValue]];		    
    [myLungs setLungElastance:[[arrayOfFactors objectAtIndex:7] currentValue]];		  
    [myHeart setAdmixtureEffect:[[arrayOfFactors objectAtIndex:8] currentValue]];	
    [myLungs setHypercapnicVentResponse:[[arrayOfFactors objectAtIndex:9] currentValue]];		
    [myLungs setHypoxicVentResponse:[[arrayOfFactors objectAtIndex:10] currentValue]];		
    [myLungs setNeurogenicVentResponse:[[arrayOfFactors objectAtIndex:11] currentValue]];		   
    barometric = [[arrayOfFactors objectAtIndex:12] currentValue];		   
    temperature = [[arrayOfFactors objectAtIndex:13] currentValue];	
    [myTissues setRespiratoryQuotient:[[arrayOfFactors objectAtIndex:14] currentValue]];
    [myTissues setAmountOfCO2:[[arrayOfFactors objectAtIndex:15] currentValue]];	
    [myTissues setExtraFluidVolume:[[arrayOfFactors objectAtIndex:16] currentValue]];	    
    Hgb = [[arrayOfFactors objectAtIndex:17] currentValue];		  
    Hct = [[arrayOfFactors objectAtIndex:18] currentValue];		
    [myVeins setVenousBloodVolume:[[arrayOfFactors objectAtIndex:19] currentValue]];		
    [myVeins setAddBicarb:[[arrayOfFactors objectAtIndex:20] currentValue]];	
    [myBrain setBicarbDeviation:[[arrayOfFactors objectAtIndex:21] currentValue]];	 
    DPG = [[arrayOfFactors objectAtIndex:22] currentValue];		   
    [myLungs setBreathingCapacity:[[arrayOfFactors objectAtIndex:23] currentValue]];		
    fitness = [[arrayOfFactors objectAtIndex:24] currentValue];	
    [myLungs setInspiration:[[arrayOfFactors objectAtIndex:25] currentValue]];	
    [myHeart setMaximumCardiacOutput:[[arrayOfFactors objectAtIndex:26] currentValue]];	    
    [myHeart setLeftToRightShunt:[[arrayOfFactors objectAtIndex:27] currentValue]];	   
    [myLungs setVitalCapacity:[[arrayOfFactors objectAtIndex:28] currentValue]];	
    [myVentilator setPEEP:[[arrayOfFactors objectAtIndex:29] currentValue]];	

}

 -(void) revertValuesCorrectly:(NSMutableArray *)arrayOfFactors	// I think I understand this
{
    NSLog (@"Reverting the value");
    [[arrayOfFactors objectAtIndex:0] setCurrentValue:[myLungs FiO2]];
    [[arrayOfFactors objectAtIndex:1] setCurrentValue:[myLungs FiCO2]];
    [[arrayOfFactors objectAtIndex:2] setCurrentValue:[myHeart cardiacFunction]];
    [[arrayOfFactors objectAtIndex:3] setCurrentValue:metabolicRate];
    [[arrayOfFactors objectAtIndex:4] setCurrentValue:[myHeart rightToLeftShunt]];
    [[arrayOfFactors objectAtIndex:5] setCurrentValue:[myLungs addedDeadSpace]];
    [[arrayOfFactors objectAtIndex:6] setCurrentValue:[myLungs totalLungVolume]];
    [[arrayOfFactors objectAtIndex:7] setCurrentValue:[myLungs lungElastance]];
    [[arrayOfFactors objectAtIndex:8] setCurrentValue:[myHeart admixtureEffect]];
    [[arrayOfFactors objectAtIndex:9] setCurrentValue:[myLungs hypercapnicVentResponse]];
    [[arrayOfFactors objectAtIndex:10] setCurrentValue:[myLungs hypoxicVentResponse]];
    [[arrayOfFactors objectAtIndex:11] setCurrentValue:[myLungs neurogenicVentResponse]];
    [[arrayOfFactors objectAtIndex:12] setCurrentValue:barometric];
    [[arrayOfFactors objectAtIndex:13] setCurrentValue:temperature];
    [[arrayOfFactors objectAtIndex:14] setCurrentValue:[myTissues respiratoryQuotient]];
    [[arrayOfFactors objectAtIndex:15] setCurrentValue:[myTissues amountOfCO2]];
    [[arrayOfFactors objectAtIndex:16] setCurrentValue:[myTissues extraFluidVolume]];
    [[arrayOfFactors objectAtIndex:17] setCurrentValue:Hgb];
    [[arrayOfFactors objectAtIndex:18] setCurrentValue:Hct];
    [[arrayOfFactors objectAtIndex:19] setCurrentValue:[myVeins venousBloodVolume]];
    [[arrayOfFactors objectAtIndex:20] setCurrentValue:[myVeins addBicarb]];
    [[arrayOfFactors objectAtIndex:21] setCurrentValue:[myBrain bicarbDeviation]];
    [[arrayOfFactors objectAtIndex:22] setCurrentValue:DPG];
    [[arrayOfFactors objectAtIndex:23] setCurrentValue:[myLungs breathingCapacity]];
    [[arrayOfFactors objectAtIndex:24] setCurrentValue:fitness];
    [[arrayOfFactors objectAtIndex:25] setCurrentValue:[myLungs inspiration]];
    [[arrayOfFactors objectAtIndex:26] setCurrentValue:[myHeart maximumCardiacOutput]];
    [[arrayOfFactors objectAtIndex:27] setCurrentValue:[myHeart leftToRightShunt]];
    [[arrayOfFactors objectAtIndex:28] setCurrentValue:[myLungs vitalCapacity]];
    [[arrayOfFactors objectAtIndex:29] setCurrentValue:[myVentilator PEEP]]; 

}   













@end
