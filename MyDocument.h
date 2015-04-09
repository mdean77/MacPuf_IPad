//
//  MyDocument.h
//  SnowLeopardMacpuf
//
//  Created by J Michael Dean on 10/4/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Human, Factors;

@interface MyDocument : NSDocument
{
    int			iterations;		 		// how many times to run simulator
    int			intervalFactor;				// used to control display intervals
	
    // Ventilator control temporary values
    float		rate;
    int			PEEP;
    float		FiO2;
    int			tidalVolume;
    float		flow;
    float		inspTime;
    float		expTime;
    float		ratio;
    int			ventOn;
	
    
	//    NSData		*dataFromFile;				// holds the view data
    NSString		*string;				// used to work with text view
    Human		*person;				// main MacPuf patient object
    NSMutableArray	*arrayOfFactors;
    NSEnumerator	*enumerator;				// used to sequentially access arrayOfFactors
    IBOutlet		NSTableView *tableView;			// used for changing variable values in the variable drawer
    IBOutlet 		NSWindow *myParentWindow;
	
	// Drawer definitions
	
    IBOutlet		NSDrawer *variablesDrawer;		// drawer for changing variables
    IBOutlet		NSDrawer *bagDrawer;			// drawer for Douglas bag settings
    IBOutlet		NSDrawer *ventDrawer;			// drawer for ventilator settings
    IBOutlet		NSDrawer *patientDrawer;		// for customized patients
	
	
	// Text field definitions
    IBOutlet 		NSTextField *textIterationsField;	// holds the number of iterations to run simulator
    IBOutlet		NSTextField *textBagO2Field;		// holds initial O2% of Douglas bag
    IBOutlet		NSTextField *textBagCO2Field;		// holds initial CO2% of Douglas bag
    IBOutlet		NSTextField *textBagN2Field;		// holds initial N2% of Douglas bag
	
	
	// Controller definitions so I can programatically change their values
	
    //IBOutlet		NSSlider   *timeSlider;			// so I can tell it what value to display
    IBOutlet		NSSlider   *bagO2Slider;		// initially set to 21%
    IBOutlet		NSSlider   *bagCO2Slider;		// initially 0.03%
    IBOutlet		NSMatrix   *intervalRadioMatrix;	// so I can set it correctly in the awakeFromNib
    IBOutlet		NSMatrix   *genderRadioMatrix;		// initially set to male
	
	//  Ventilator controller definitions
    
    IBOutlet		NSMatrix   *ventilatorOnOffMatrix;	// Controls ventilator on or off
	
	//  Ventilator text field definitions
    IBOutlet		NSTextField	*ventRate;		// Ventilator rate
    IBOutlet		NSTextField	*ventPEEP;		// Ventilator PEEP
    IBOutlet		NSTextField	*ventFiO2;		// Ventilator Fio2
    IBOutlet		NSTextField	*ventTidalVolume;	// Ventilator tidal volume
    IBOutlet		NSTextField	*ventFlow;		// Ventilator flow rate
    IBOutlet		NSTextField	*ventInspTime;		// Ventilator inspiratory time
    IBOutlet		NSTextField	*ventExpTime;		// Ventilator expiratory time
    IBOutlet		NSTextField	*ventRatio;		// I to E ratio
    
	// Definition of main textView where I put all MacPuf results, etc.
	
    IBOutlet 		NSTextView *textView;			// connnects to the GUI textview
	
}

-(IBAction) simulate:(id)sender;    	   		// action method to run simulator
-(IBAction) setIterations:(id)sender;
-(IBAction) inspectMacPuf:(id)sender;
-(IBAction) intervalMatrixClicked:(id)sender;		// handle the radio matrix for interval choices
-(IBAction) changeValues:(id)sender;			// accept variable changes
-(IBAction) changeBag:(id)sender;			// accept bag settings
-(IBAction) cancelChanges:(id)sender;			// cancel variable changes and revert to current
-(IBAction) cancelBag:(id)sender;			// cancel Douglas bag settings or discontinue the bag itself
-(IBAction) setVentPeep:(id)sender;
-(IBAction) setVentIMV:(id)sender;
-(IBAction) setVentFio2:(id)sender;
-(IBAction) setVentTV:(id)sender;
-(IBAction) ventilatorOnOffMatrixClicked:(id)sender;	// turn on and off the ventilator
-(IBAction) cancelVentilator:(id)sender;		// cancel ventilator setting changes
-(IBAction) acceptVentilator:(id)sender;		// accept ventilator setting changes

-(void)	createFactorArray;				// Brute force to create array of factors

// Data source methods needed for factor table
-(NSUInteger)	numberOfRowsInTableView:(NSTableView *)aTableView;
-(id)	tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex;
-(void) tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex;

@end
