//
//  FoaasBuilder.swift
//  AC3.2-BiteYourThumb
//
//  Created by Louis Tur on 11/27/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

enum FoaasBuilderError: Error {
	case keyDoesNotExist(key: String)
	case keyIndexNotFound(key: String)
}

class FoaasPathBuilder {
	private var operation: FoaasOperation
	private var operationFields: [String : String] = [:]
	private let baseURLString: String = "https://foaas.onrender.com"
	
	var allKeys: [String] { operation.fields.map { $0.key } }
	
	init(operation: FoaasOperation) {
		self.operation = operation
		for field in operation.fields {
			operationFields[field.key] = field.defaultValue
		}
	}
	
	/**
	 Goes through a `FoaasOperation.url` to replace placeholder text with its corresponding value stored in self.operationsField
	 in the correct order. The String is also passed back with percent encoding automatically applied.
	 
	 example:
	 ```
	 self.operationFields = [ "from" : "Grumpy Cat", "name" : "Nala Cat"]
	 self.operation.url = "/bus/:name/:from/"
	 
	 build() // returns "/bus/Nala%20Cat/Grumpy%20Cat"
	 ```
	 
	 - returns: A `String` that contains baseURLString and updated FoaasOperation.url needed to create a `URL` to request a `Foaas` object
	 */
	func build() -> String {
		var urlString = operation.url
		for (k, v) in operationFields {
			urlString = urlString.replacingOccurrences(of: ":\(k)", with: v.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!)
		}
		return baseURLString + urlString
	}
	
	func update(key: String, value: String)  {
		guard allKeys.contains(key) else { return }
		
		var result = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		if result.isEmpty {
			result = operation.fields.first(where: { $0.key == key })?.defaultValue ?? ""
		}
		operationFields[key] = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
	
	/**
	 Utility function to get the index of a specified key in its correct order in the `FoaasOperation.url` property.
	 
	 For example, for the Ballmer operation, its corresponding FoaasOperation.url is `/ballmer/:name/:company/:from`
	 
	 - indexOf(key: "name") // should return 0
	 - indexOf(key: "company") // should return 1
	 - indexOf(key: "from") // should return 2
	 - indexOf(key: ":name") // should return nil
	 - indexOf(key: "tool") // should return nil
	 
	 - parameter key: The key in self.operationFields to search for.
	 - returns: The index position of the key if it exists in self.operationFields. `nil` otherwise.
	 - seealso: `FoaasPathBuilder.allKeys`
	 */
	func indexOf(_ key: String) -> Int? {
		guard
			let index = operation.url.components(separatedBy: "/:").firstIndex(of: key)
		else { return nil }
		return index
	}
	
	func entryIsValid() -> Bool {
		return operationFields.values.allSatisfy({ !$0.isEmpty })
	}
	
}
