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
	

	var amountOfOxygen:Double
	var	pO2:Double
	var	oxygenContent:Double
	var	oxygenSaturation:Double
	var	amountOfCO2:Double
	var	pCO2:Double
	var	carbonDioxideContent:Double
	var	bicarbonateContent:Double
	var	pH:Double
	
	init(){
		(amountOfOxygen, pO2,oxygenContent,oxygenSaturation,amountOfCO2,pCO2,carbonDioxideContent,bicarbonateContent,pH) = (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)
	}
	
	// sign(f,g) = sgn(g) * abs(f)
	func sign(_ op1:Double, op2:Double) -> Double {
		return op2 < 0 ? -abs(op1) : abs(op1)
	}
	
	// This method replaces the MacPuf GASES subroutine.  It accepts any values of pO2, pCO2 and pH and
	// works out O2 and CO2 contents and the saturation of O2.  It also needs values for temperature,
	// hematocrit, hemoglobin and DPG.  Since these values are usually normal I have provided default values
	// but these can be overridden if the developer allows these parameters to be changed by the user.
	
	func calculateContents(_ pH:Double,temperature:Double = 37.0,DPG:Double = 3.7843,
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
			
			let saturation = sat
			var o2Content = Hgb*sat*1.34 + 0.003*pO2
			o2Content = (o2Content < 0.001) ? 0.001 : o2Content
			var co2Content = (cc*h+(1-h)*cp)*2.22
			co2Content = (co2Content < 0.001) ? 0.001 : co2Content
			
			oxygenContent = o2Content
			carbonDioxideContent = co2Content
			oxygenSaturation = saturation
	}
}


