//
//  MyDocument.m
//  SnowLeopardMacpuf
//
//  Created by J Michael Dean on 10/4/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import "MyDocument.h"
#import "Human.h"
#import "Factors.h"

@implementation MyDocument

- (NSString *) string
{
    return string;
}

-(void) setString:(NSString *)value
{
    string = value;
}

-(void) updateString
{
    [self setString: [textView string]];   // get the string from the text view
}

-(void) updateView
{
    [textView setString:string];   // put the string back
}

-(id) init
{
    if (self = [super init]) {
        iterations = 180;	
        intervalFactor = 10;
        rate = 15;	// to make arithmetic easier - cycle time is 4 seconds
        PEEP = 0;
        FiO2 = 20.93;
        tidalVolume = 450;
        flow = 16.875;
        inspTime = 1.6;	// assumes 40% of cycle is inspiratory
        expTime = 2.4;	// 4 seconds minus inspiratory time
        ratio = 0.667;	//simple math
        ventOn = 0;	// start with vent off
        person = [[Human alloc] init];
        arrayOfFactors = [[NSMutableArray alloc] init];
        [self createFactorArray];			// initial parameter values only
        [person revertValuesCorrectly:arrayOfFactors];  // update to the object values
	}        
	return self;
	
}
-(void) awakeFromNib
{
    NSLog(@"Reached awake from nib method");
    [textIterationsField setIntValue:iterations];
    [intervalRadioMatrix setState:NSOnState atRow:1 column:0];
    //[timeSlider setIntValue:iterations];
    // set up ventilator dialog default values
    [ventRate setFloatValue:rate];
    //[sliderRate setIntValue:rate];
    [ventPEEP setIntValue:PEEP];
    //[sliderPEEP setIntValue:PEEP];
    //[sliderFiO2 setFloatValue:FiO2];
    //[sliderTidalVolume setIntValue:tidalVolume];
    [ventFiO2 setFloatValue:FiO2];
    [ventTidalVolume setIntValue:tidalVolume];
    [ventFlow setFloatValue:flow];
    [ventInspTime setFloatValue:inspTime];
    [ventExpTime setFloatValue:expTime];
    [ventRatio setFloatValue:ratio];
    [ventilatorOnOffMatrix setState:NSOnState atRow:1 column:0];
	
}

-(IBAction) intervalMatrixClicked:(id)sender
{
    // Handle the radio buttons for interval choices
	
    switch ([sender selectedRow]) {
        case 0:
            intervalFactor = 1;
            break;        
        case 1:
            intervalFactor = 10;
            break;
        case 2:
            intervalFactor = 30;
            break;
	}
    iterations = (iterations >= intervalFactor) ? iterations : intervalFactor;
    // This is needed because if the user sets iterations lower than the factor, nothing will ever print.
    [textIterationsField setIntValue:iterations];	// setup the GUI initial values
	
}
-(void) dealloc
{
    NSLog(@"Destroying %@", self);
    [super dealloc];
}

-(IBAction) setIterations:(id)sender
{
    NSLog(@"Reached set iterations method");
    iterations = [sender intValue];
    iterations = (iterations >= intervalFactor) ? iterations : intervalFactor;
    [textIterationsField setIntValue:iterations];
}

-(IBAction) setVentPeep:(id) sender
{
    NSLog(@"We got to setVentPeep");
    PEEP = [sender intValue];		// get value from the slider
    [ventPEEP setIntValue:PEEP];	// updates the text field
}
-(IBAction) setVentIMV:(id) sender
{
    float cycleTime;
    NSLog(@"We got to setVentRate");
    rate = [sender intValue];
    if (rate == 0) rate = 0.000001;
    [ventRate setFloatValue:rate];
    cycleTime = 60/rate;
    inspTime = cycleTime*0.4;         // This is the default inspiratory percentage in MacPuf.
    expTime = cycleTime - inspTime;
    ratio = inspTime/expTime;
    flow = tidalVolume*60/(1000*inspTime);
    [ventFlow setFloatValue:flow];
    [ventInspTime setFloatValue:inspTime];
    [ventExpTime setFloatValue:expTime];
    [ventRatio setFloatValue:ratio];
    
}
-(IBAction) setVentFio2:(id) sender
{
    NSLog(@"We got to setVentFio2");
    FiO2 = [sender floatValue];
    [ventFiO2 setFloatValue:FiO2];
}
-(IBAction) setVentTV:(id) sender
{
    NSLog(@"We got to setVentTidalVolume");
    tidalVolume = [sender intValue];
    flow = tidalVolume*60/(1000*inspTime);   // need to change flow to liters per minute
    [ventTidalVolume setIntValue:tidalVolume];
    [ventFlow setFloatValue:flow];
}
-(IBAction) simulate:(id)sender
{
    int i;
    NSUInteger textLength;
    [person setIterations:iterations];  // needed so the human object can handle bicarb and acid administration
    NSString  *header1 = @"\n   Time     0     10    20    30    40    50    60    70    80    90   100   110   120\n";
    NSString  *header2 = @"(Min:Secs)  .     .     .     .     .     .     .     .     .     .     .     .     .\n";
    // First I need to set textLength to the length of my textview string!!
    textLength = [[textView string] length];
    [textView setSelectedRange:NSMakeRange(textLength, 0)];
    [textView insertText:header1];
    [textView insertText:header2];
    for(i=1; i<=iterations; i++)
    {
        [person simulate:i];
        if (i % intervalFactor == 0) {
			[textView insertText: [person cycleReport]];
			//[textView insertText: [person description]];
		}
    }
    [textView insertText: @"\n"];
    [textView insertText:[person runReport]];
    [textView insertText:[person dumpParametersReport]];
    [person revertValuesCorrectly:arrayOfFactors];		// in case any factors changed by simulator
    [tableView reloadData];
    id anObject;
    for (anObject in arrayOfFactors){
        [anObject setPreviousValue:[anObject currentValue]];
    }
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    
    [super windowControllerDidLoadNib:aController];
	
    if (!string) {
        NSCalendarDate *runDate = [NSCalendarDate calendarDate];
        NSString *dateString = [runDate descriptionWithCalendarFormat:@"%a %m/%d/%y %I:%M %p"];
        [self setString:
		 @"                                 Welcome to MacPuf.\n\n     Macpuf is a model of the human respiratory system designed at McMaster University Medical School, Canada, and St. Bartholomew's Hospital Medical College, England, by Drs. CJ Dickinson, EJM Campbell, AS Rebuck, NL Jones, D Ingram, and K Ahmed.  MacPuf was created to study gas transport and exchange.  MacPuf contains simulated lungs, circulating blood, and tissues.  Initially MacPuf breathes at a rate and depth determined by known influences upon ventilation.\n\n     Enjoy yourself and try not to hurt your new experimental volunteer (or patient!)\n\n     Adjust the settings below and click the Run Simulation button to proceed.\n\n"];
        [textView setFont:[NSFont fontWithName: @"Monaco" size:12]];
        [textView insertText:dateString];
        [textView insertText:@"\n"];
        [self updateView];
    }
	
}


- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    [self updateString];
    return [string dataUsingEncoding:NSASCIIStringEncoding];
}


- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [self setString:aString];
    [self updateView];
    
    return YES;
}

// Override printShowingPrintPanel so I can control printing parameters
// This method is automatically hit by printDocument: which is called from the menu
// This was a problem to figure out because the default menu link was to print: and this is
// not correct for a document based application such as MacPuf.

-(void)printShowingPrintPanel:(BOOL)flag{
    NSPrintInfo *printInfo = [self printInfo];
    [printInfo setHorizontalPagination:NSFitPagination];
    [printInfo setVerticallyCentered:NO];
    [printInfo setTopMargin:50];
    [printInfo setBottomMargin:50];
    [printInfo setLeftMargin:50];
    [printInfo setRightMargin:50];
    NSPrintOperation *printOp;
    printOp = [NSPrintOperation printOperationWithView:textView
                                             printInfo:printInfo];
    [printOp setShowPanels:flag];
    [printOp runOperation];
    NSLog(@"Hit my print method");
}



-(void) textDidChange:(NSNotification *)aNotification
{
    [self updateChangeCount:NSChangeDone];
}


-(IBAction) inspectMacPuf:(id)sender
{
    //[textView setSelectedRange:NSMakeRange(textLength, 0)];
    NSUInteger textLength;
    textLength = [[textView string] length];
    [textView setSelectedRange:NSMakeRange(textLength, 0)]; 
    [textView insertText: @"\n"];
    [textView insertText: [person description]];    // same as the Inspect Option on original
	// May want to move out of the routine
    [textView insertText: @"\n"];
}

-(IBAction) changeValues:(id) sender
{
    // tells me to change the values as indicated in the table
    // The array should already have been changed by the view - now i change the factors themselves
    // and enter those changes into the transcript
    // New values are in arrayOfFactors in the currentValue field.  Pass the array into the person object.
    NSMutableString *previous, *current;
    int i = 0;
    NSUInteger textLength;
    id anObject;
    
    textLength = [[textView string] length];			// reset insertion in case I print in later
    [textView setSelectedRange:NSMakeRange(textLength, 0)];
    
    [person changeValues:arrayOfFactors];
    [variablesDrawer close];
    
    
    
    for (anObject in arrayOfFactors) {
        if ([anObject currentValue] != [anObject previousValue]) {i++;}}
	
    //[textView setSelectedRange:NSMakeRange(textLength, 0)];
    if (i > 0) {[textView insertText:@"\nFactors Changed by User:\n"];}
    
	
    for (anObject in arrayOfFactors) {
        if ([anObject currentValue] != [anObject previousValue]) {
            previous = [[NSMutableString alloc] initWithFormat:@"%6.2f ", [anObject previousValue]];
            current = [[NSMutableString alloc] initWithFormat:@"%6.2f ", [anObject currentValue]];
            [textView insertText: @"     "];
            [textView insertText:[anObject factorName]];
            [textView insertText: @" changed from "];
            [textView insertText: previous];
            [textView insertText: @" to "];
            [textView insertText: current];
            [textView insertText: @"\n"];

            [anObject setPreviousValue:[anObject currentValue]];
        }
    }

}

-(IBAction) changeBag:(id)sender			// accept bag settings
{
    //  This method changes the initial settings for a Douglas bag experiment
    //  If there is already a Douglas bag it will reset it to the new settings
    NSLog(@"Accepting bag settings");
    [bagDrawer close];
}



-(IBAction) cancelChanges:(id)sender			// cancel variable changes and revert to current
{
    NSLog(@"Canceling changes in variable values");
    [person revertValuesCorrectly:arrayOfFactors];
    [tableView reloadData];
    [variablesDrawer close];
}


-(IBAction) cancelBag:(id)sender			// cancel Douglas bag settings or discontinue the bag itself
{
    //  This method cancels the Douglas bag completely.  There are no changes to cancel since the user can only
    //  set up initial bag volume and concentrations of gases.  Thus, there is no need to cancel changes without 
    //  canceling the bag itself.
    NSLog(@"Canceling Douglas bag");
    [bagDrawer close];
}

-(IBAction) ventilatorOnOffMatrixClicked:(id)sender
{
    // Handle the on off switch for the ventilator
    switch ([sender selectedRow]) {
        case 0:
            ventOn = 1;
            NSLog(@"Ventilator on");
            break;
        case 1:
            ventOn = 0;
            NSLog(@"Ventilator off");
            break;
    }
}

-(IBAction) acceptVentilator:(id)sender			// accept ventilator settings
{
    //  This method accepts changes in the ventilator, including turning it on.
    //  If the ventilator is already on, then it just changes settings.
    NSLog(@"Accepting ventilator settings");
    // Now I need to pass the values into the human object and tell it to set the settings
    [person setVentilator:ventOn PEEP:PEEP rate:rate FiO2:FiO2 tidalVolume:tidalVolume];
    [ventDrawer close];
}
-(IBAction) cancelVentilator:(id)sender			// cancel ventilator settings or discontinue ventilator itself
{
    //  This method turns off artificial ventilation.  The user can twiddle the knobs, but then they are twiddled.
    //  At present I have no button or method to revert the settings to previous settings.
    NSLog(@"Canceling artificial ventilator");
    [ventDrawer close];
}


// Data source methods needed for factor table

-(NSUInteger)	numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [arrayOfFactors count];
}

-(id)	tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
    NSString *identifier = [aTableColumn identifier];
    Factors *factor = [arrayOfFactors objectAtIndex:rowIndex];
    return [factor valueForKey:identifier];
}

-(void) tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
    NSString *identifier = [aTableColumn identifier];
    Factors *factor = [arrayOfFactors objectAtIndex:rowIndex];
    [factor takeValue:anObject forKey:identifier];
}

-(void) createFactorArray
{
    Factors *factor;
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Inspired O2 (%)"];
    [factor setReferenceValue:20.93];
    [factor setCurrentValue:20.93];
    [arrayOfFactors addObject:factor];
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Inspired CO2 (%)"];
    [factor setReferenceValue:0.03];
    [factor setCurrentValue:0.03];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Cardiac pump performance, % normal"];
    [factor setReferenceValue:100];
    [factor setCurrentValue:100];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Metabolic rate, % normal"];
    [factor setReferenceValue:100];
    [factor setCurrentValue:100];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Extra R-->L shunt, % cardiac output"];
    [factor setReferenceValue:0.0];
    [factor setCurrentValue:0.0];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Extra dead space above normal, ml"];
    [factor setReferenceValue:0.00];
    [factor setCurrentValue:0.00];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Lung volume (end expiratory), ml"];
    [factor setReferenceValue:3000];
    [factor setCurrentValue:3000];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Lung elastance, cm H20/liter"];
    [factor setReferenceValue:5.0];
    [factor setCurrentValue:5.0];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Venous admixture effect, %cardiac output)"];
    [factor setReferenceValue:3.0];
    [factor setCurrentValue:3.0];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Vent response to CO2 or H+, % normal"];
    [factor setReferenceValue:100];
    [factor setCurrentValue:100];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Vent response to hypoxia, % normal"];
    [factor setReferenceValue:100];
    [factor setCurrentValue:100];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Central neurogenic vent drive, % normal"];
    [factor setReferenceValue:100];
    [factor setCurrentValue:100];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Total barometric pressure, mm Hg"];
    [factor setReferenceValue:760];
    [factor setCurrentValue:760];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Body temperature, degrees Centigrade"];
    [factor setReferenceValue:37.0];
    [factor setCurrentValue:37.0];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Tissue respiratory quotient (RQ)"];
    [factor setReferenceValue:0.80];
    [factor setCurrentValue:0.80];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Tissue CO2 stores, liters STPD"];
    [factor setReferenceValue:13.3736];
    [factor setCurrentValue:13.3736];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Tissue ECF distribution volume, liters"];
    [factor setReferenceValue:12.00];
    [factor setCurrentValue:12.00];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Haemoglobin, g/100 ml blood"];
    [factor setReferenceValue:14.8];
    [factor setCurrentValue:14.8];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Hematocrit (packed cell volume) (%)"];
    [factor setReferenceValue:45.0];
    [factor setCurrentValue:45.0];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Venous blood volume, ml"];
    [factor setReferenceValue:3000];
    [factor setCurrentValue:3000];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Added bicarbonate(+) or acid(-), mmol"];
    [factor setReferenceValue:0.00];
    [factor setCurrentValue:0.00];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Brain bicarb (+/-) from normal, mmol/l"];
    [factor setReferenceValue:-0.0678];
    [factor setCurrentValue:-0.0678];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"2,3 DPG concentration in RBC, mmol/l"];
    [factor setReferenceValue:3.7843];
    [factor setCurrentValue:3.7843];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Breathing capacity, % normal"];
    [factor setReferenceValue:100];
    [factor setCurrentValue:100];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Index of state of fitness"];
    [factor setReferenceValue:28];
    [factor setCurrentValue:28];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Inspiratory time / total breath time"];
    [factor setReferenceValue:0.40];
    [factor setCurrentValue:0.40];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Maximum cardiac output, liters/min"];
    [factor setReferenceValue:35];
    [factor setCurrentValue:35];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Extra L-->R shunt, % cardiac output"];
    [factor setReferenceValue:0];
    [factor setCurrentValue:0];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Vital capacity, liters BTPS"];
    [factor setReferenceValue:5];
    [factor setCurrentValue:5];
    [arrayOfFactors addObject:factor];    
    [factor release];
    
    factor = [[Factors alloc] init];
    [factor setFactorName:@"Positive end-expiratory pressure, cm H2O"];
    [factor setReferenceValue:0.0];
    [factor setCurrentValue:0.0];
    [arrayOfFactors addObject:factor];    
    [factor release];
	
    id anObject;
    for (anObject in arrayOfFactors){
        [anObject setPreviousValue:[anObject currentValue]];
    }
    
}

@end
