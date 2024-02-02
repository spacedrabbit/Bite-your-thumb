//
//  FoaasAPIManager.swift
//  AC3.2-BiteYourThumb
//
//  Created by Louis Tur on 11/15/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

class FoaasService {
	private static let backgroundSessionIdentifier: String = "foaasBackgroundSession"
	
	private static let debugURL = URL(string: "https://foaas.onrender.com/awesome/louis")!
	private static let extendedDebugURL = URL(string: "https://foaas.onrender.com/greed/cat/louis")!
	private static let extendedTwoDebugURL = URL(string: "https://foaas.onrender.com/madison/louis/paul")!
	private static let operationsURL = URL(string: "https://foaas.onrender.com/operations")!
	static let colorSchemeURL = "https://api.fieldbook.com/v1/5873aaf1bc9912030079d388/color_schemes"
	static let versionURL = "https://api.fieldbook.com/v1/5873aaf1bc9912030079d388/version"
	
	private static let defaultSession = URLSession(configuration: .default)

	// MARK: - GET Requests -
	
	class func getFoass(url: URL = FoaasService.extendedTwoDebugURL) async throws -> Foaas? {
		do {
			var request = URLRequest(url: url)
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			let result = try await URLSession.shared.data(for: request)
			let decoder = JSONDecoder()
			let foaas = try decoder.decode(Foaas.self, from: result.0)
			
			return foaas
		} catch (let e) {
			print("Error receiving foaas: \(e)")
			return nil
		}
	}
	
	// MARK: Operations GET
	internal class func getOperations(completion: @escaping ([FoaasOperation]?)->Void ) {
		
		defaultSession.dataTask(with: FoaasService.operationsURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
			guard error == nil else {
				print("Error: \(error.unsafelyUnwrapped)")
				return
			}
			
			guard let validData = data else {
				print("Error: Data returned was nil")
				return
			}
			
			do {
				guard let operationsJson = try JSONSerialization.jsonObject(with: validData, options: []) as? [Any]
				else {
					print("Error attempting to serialize JSON")
					return
				}
				
				var operations: [FoaasOperation]? = []
				for case let operation as [String : AnyObject] in operationsJson {
					guard let foaasOp = FoaasOperation(json: operation) else { continue }
					operations?.append(foaasOp)
				}
				completion(operations?.sorted{ $0.name < $1.name })
			}
			catch {
				print("Error attempting to deserialize operations json: \(error)")
			}
		}).resume()
	}
	
	// MARK: - Helpers
	// TODO: have this take custom error types to better handle issues before fully implementing - @Liam
	private static func handle(_ error: Error?, response: URLResponse?) {
		if let e = error{
			print(e.localizedDescription)
		}
		if let httpReponse = response as? HTTPURLResponse {
			print(httpReponse.statusCode)
		}
	}
	
	static func getData(endpoint: String, complete: @escaping (Data?) -> Void){
		guard let url = URL(string: endpoint) else { return }
		defaultSession.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
			if error != nil {
				print(error!)
			}
			if data != nil {
				complete(data)
			}
		}.resume()
	}
	
}
