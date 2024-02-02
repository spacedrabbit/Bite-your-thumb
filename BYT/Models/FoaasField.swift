//
//  FoaasField.swift
//  AC3.2-BiteYourThumb
//
//  Created by Louis Tur on 11/21/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

struct FoaasField: Codable {
	let name: String
	let field: String
	
	var description: String {
		return "Name: \(name)   Field: \(field)"
	}
}
