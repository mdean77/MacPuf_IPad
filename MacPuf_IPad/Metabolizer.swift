//
//  Metabolizer.swift
//  MacPuf for IPad
//
//  Created by J Michael Dean on 4/8/15.
//  Copyright (c) 2015 J Michael Dean. All rights reserved.
//
//  Metabolizer contains oxygen, carbon dioxide, bicarbonate, and pH for its compartment.
//	Individual parts of Human are metabolizers and have their own values for these parameters.
//	For this reason, the updating can be done by telling each organ to calculate its gas
//	contents, and to update its pH, and to calculate gas pressures for certain contents.
//	All calls to these routines are carried out within this class or its subclasses.

import Foundation

class Metabolizer  {
	var amountOfOxygen = 0.0
	var	pO2 = 0.0
	var	oxygenContent = 0.0
	var	oxygenSaturation = 0.0
	var	amountOfCO2 = 0.0
	var	pCO2 = 0.0
	var	carbonDioxideContent = 0.0
	var	bicarbonateContent = 0.0
	var	pH = 0.0

	// sign(f,g) = sgn(g) * abs(f)
	func sign(op1:Double, op2:Double) -> Double {
		return op2 < 0 ? -abs(op1) : abs(op1)
	}
	
	// This method replaces the MacPuf GASES subroutine.  It accepts any values of pO2, pCO2 and pH and
	// works out O2 and CO2 contents and the saturation of O2.  It also needs values for temperature,
	// hematocrit, hemoglobin and DPG.  Since these values are usually normal I have provided default values
	// but these can be overridden if the developer allows these parameters to be changed by the user.
	
	func calculateContents(pH:Double,temperature:Double = 37.0,DPG:Double = 3.7843,
		Hct:Double = 45.0, Hgb:Double = 14.8){
			
			// Series of constants needed for the Kelman equations
			let a1 = -8.532229E3
			let a2 = 2.121401E3
			let a3 = -6.707399E1
			let a4 = 9.359609E5
			let a5 = -3.134626E4
			let a6 = 2.396167E3
			let a7 = -6.710441E1
			
			var (p, pk, dox, x, t, sol) = (0.0, 0.0,0.0,0.0,0.0,0.0)
			var (dr, cp, cc, h, sat, a, b, c, dph) = (0.0, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)
			
			// Original FORTRAN: X=PO2*10.**(.4*(PH-DPH)+.024*(37.-TEMP)+.026057699*(ALOG(40./PC2)))
			
			dph = 7.4 + (DPG - 3.8) * 0.25
			dph = (dph > 7.58) ? 7.58 : dph
			a = 0.4*(pH - dph)
			b = 0.024*(37.0-temperature)
			c = 0.026057699 * (log(40.0/pCO2))
			x = pO2*pow(10.0,(a + b + c ))
			x = (x < 0.01) ? 0.01 : x   // Make sure x is at least greater than 0.01
			sat = (x >= 10) ? (x*(x*(x*(x+a3)+a2)+a1))/(x*(x*(x*(x+a7)+a6)+a5)+a4) : (0.003683+0.000584*x)*x
			p = 7.4 - pH
			pk = 6.086 + p * 0.042 + (38.0 - temperature) * (0.00472 + 0.00139 * p)
			t = 37.0 - temperature
			sol = 0.0307+(0.00057+0.00002*t)*t
			dox = 0.590 + (0.2913-0.0844*p)*p
			dr = 0.664+(0.2275-0.0938*p)*p
			t = dox + (dr - dox) * (1 - sat)
			cp = sol*pCO2*(1+pow(10, pH - pk))
			cc = t * cp
			h = Hct * 0.01
			
			var saturation = sat
			var o2Content = Hgb*sat*1.34 + 0.003*pO2
			o2Content = (o2Content < 0.001) ? 0.001 : o2Content
			var co2Content = (cc*h+(1-h)*cp)*2.22
			co2Content = (co2Content < 0.001) ? 0.001 : co2Content
			
			oxygenContent = o2Content
			carbonDioxideContent = co2Content
			oxygenSaturation = saturation
	}
	
	// This method replaces the MacPuf GSINV subroutine.  It accepts values of O2 and CO2 content and using
	// successive approximation it iterates to the respective partial pressures.  I am using exactly the same logic
	// as the original version but have tried to make it clear how it works.
	
	func calculatePressures(oxygenContent:Double, carbonDioxideContent:Double, pO2initial:Double,
		pCO2initial:Double, pH:Double, temperature:Double = 37.0, DPG:Double = 3.7842, Hct:Double = 45.0,
		Hgb: Double = 14.8){
			
			let err = 0.01
			var (trialO2Content, trialCO2Content) = (0.0, 0.0)
			var (deltaOxygen1, deltaOxygen2, deltaCarbonDioxide1, deltaCarbonDioxide2) = (0.0,0.0,0.0,0.0)
			var (guessOxygen1, guessOxygen2, guessCarbonDioxide1, guessCarbonDioxide2) = (0.0,0.0,0.0,0.0)
			
			// Flags to track status of iterators
			//	ICH3 is a flag that indicates a bracket is being pursued for pO2
			//	ICH1 is a flag that indicates if pO2 is adequately approximated (ICH1 = 0)
			//	ICH4 is a flag that indicates a bracket is being pursued for pCO2
			//	ICH2 is a flag that indicates if pCO2 is adequately approximated (ICH2 = 0)
			var (ich1, ich2, ich3, ich4) = (1,1,1,1)
			
			// Magnitudes of iterative change
			var (D1Z, D2Z, D1, D2, DS) = (2.0, 2.0, 0.0, 0.0, 0.0)
			var x = 0.0
			
			var pO2 = pO2initial		//set initial estimate as what was fed in from MacPuf
			var pCO2 = pCO2initial	//set initial estimate as what was fed in from MacPuf
			
			do {
				// Do the first estimation by calling calculateContents with these initial guesses
				calculateContents(pH, temperature:temperature, DPG:DPG, Hct:Hct, Hgb:Hgb)
				
				// Calculate the delta, but must be non-zero or we will get division by zero error later
				deltaOxygen2 = (trialO2Content - oxygenContent) == 0 ?  0.001 : trialO2Content - oxygenContent
				
				deltaCarbonDioxide2 = (trialCO2Content - carbonDioxideContent) == 0 ? 0.001 : trialCO2Content - carbonDioxideContent
				
				guessOxygen2 = pO2
				guessCarbonDioxide2 = pCO2
				
				if (ich3 == 1) {
					ich3 = 0
					D1 = sign(D1Z, op2: -deltaOxygen2)
				}
				
				if (ich4 == 1) {
					ich4 = 0
					D2 = sign(D2Z, op2: -deltaCarbonDioxide2)
				}
				// check for convergence
				if (abs(deltaOxygen2) < err) {
					ich1 = 0
				}
				if (abs(deltaCarbonDioxide2) < err) {
					ich2 = 0
				}
				if ((ich1 + ich2) == 0) {
					return
				}
				
				DS = D1 * Double(ich1)		// clever way to suppress further changes if already converged
				x = pO2 + DS - pO2 * 0.25;
				if (x<0) {
					DS = -pO2 * 0.75;
				}
				pO2 = pO2 + DS;		// new pO2 value to try.  This directly changes the object pO2.
				
				DS = D2 * Double(ich2)
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
				
				calculateContents(pH, temperature:temperature, DPG:DPG, Hct:Hct, Hgb:Hgb)
				
				// Calculate the delta, but must be non-zero or we will get division by zero error later
				deltaOxygen1 = deltaOxygen2
				deltaOxygen2 = (trialO2Content - oxygenContent) == 0 ?  0.001 : trialO2Content - oxygenContent
				
				deltaCarbonDioxide1 - deltaCarbonDioxide2
				deltaCarbonDioxide2 = (trialCO2Content - carbonDioxideContent) == 0 ? 0.001 : trialCO2Content - carbonDioxideContent
				
				guessOxygen1 = guessOxygen2
				guessOxygen2 = pO2
				guessCarbonDioxide1 = guessCarbonDioxide2
				guessCarbonDioxide2 = pCO2
				
				// Check the oxygen content results for suitability
				ich1 = 0;
				if (abs(deltaOxygen2) > err) {
					ich1 = 1;		// Not done
					
					if ((deltaOxygen2 * D1) > 0) {
						ich3 = 1;
						pO2 = guessOxygen1 + (guessOxygen2 - guessOxygen1)*abs(deltaOxygen1)/(abs(deltaOxygen2)+abs(deltaOxygen1));
						D1Z = D1Z * 0.5;
					}
					
					if ((deltaOxygen2 * D1) < 0) {
						D1 = (guessOxygen2 == guessOxygen1) ? sign(D1Z, op2: -deltaOxygen2) : (guessOxygen2 - guessOxygen1)*abs(deltaOxygen2)/abs(deltaOxygen2 - deltaOxygen1);
					}
				}
				
				// Check the carbon dioxide content results for suitability
				ich2 = 0;
				if (abs(deltaCarbonDioxide2) > err) {
					ich2 = 1;
					
					if ((deltaCarbonDioxide2 * D2) > 0) {
						ich4 = 1;
						pCO2 = guessCarbonDioxide1 + (guessCarbonDioxide2 - guessCarbonDioxide1)*abs(deltaCarbonDioxide1)/(abs(deltaCarbonDioxide2)+abs(deltaCarbonDioxide1));
						D2Z = D2Z * 0.5;
					}
					
					if ((deltaCarbonDioxide2 * D2) < 0) {
						D2 = (guessCarbonDioxide2 == guessCarbonDioxide1) ? sign(D2Z, op2: -deltaCarbonDioxide2) : (guessCarbonDioxide2 - guessCarbonDioxide1)*abs(deltaCarbonDioxide2)/abs(deltaCarbonDioxide2 - deltaCarbonDioxide1);
					}
				}
				
			} while (ich1 + ich2) != 0
			
			return
	}
	
	
	
}
