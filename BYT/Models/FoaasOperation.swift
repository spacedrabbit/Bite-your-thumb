//
//  FoaasOperation.swift
//  AC3.2-BiteYourThumb
//
//  Created by Louis Tur on 11/20/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation
import LouisSDK

struct FoaasOperation: Codable, Mappable {
	let name: String
	let url: String
	let fields: [FoaasField]
	
	var displayName: String {
		switch name {
		case "Who the fuck are you anyway":
			return "Anyway"
		case "This Thing In Particular":
			return "Particular"
		case "Fuck You And The Horse You Rode In On" :
			return "Horse"
		case "{Name} You Are Being The Usual Slimy Hypocritical Asshole... You May Have Had Value Ten Years Ago, But People Will See That You Don't Anymore.":
			return "Hypocritical"
		case "That's Fucking Ridiculous":
			return "Ridiculous"
		default:
			return name.capitalized
		}
	}
}
