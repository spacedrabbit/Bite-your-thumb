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
	let shortname: String?
	let url: String
	let fields: [FoaasField]
	
	var displayName: String {
		return shortname ?? name
	}
}
