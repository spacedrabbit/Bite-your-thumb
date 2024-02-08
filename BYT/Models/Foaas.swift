//
//  Foaas.swift
//  AC3.2-BiteYourThumb
//
//  Created by Louis Tur on 11/15/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation
import LouisSDK

struct Foaas: Codable, Mappable {
	
	let message: String
	let subtitle: String
	
	var description: String {
		return "\(message)\n\(subtitle)"
	}
	
}
