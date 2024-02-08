//
//  FoaasAPIManager.swift
//  AC3.2-BiteYourThumb
//
//  Created by Louis Tur on 11/15/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation
import LouisSDK

class SessionManager {
	
	static let shared = SessionManager()
	
	private let manager: RequestManager
	private init() {
		let config = URLSessionConfiguration.default
		config.httpAdditionalHeaders = SessionManager.defaultHeaders
		
		let session = URLSession(configuration: config)
		manager = RequestManagerFactory.make(with: session)
	}
	
	private static let defaultHeaders: [String : String] = {
		let acceptEncoding = "gzip;q=1.0, compress;q=0.5"
		let accept = "application/json"
		let platform = "iphone"
		
		// Add anything else that needs to be part of every request made
		return ["Accept" : accept,
				"Accept-Encoding" : acceptEncoding,
				"Platform-Type" : platform]
	}()
	
	func makeRequest<T>(_ request: FoaasRequest) async throws -> T where T: Mappable {
		return try await manager.perform(request: request)
	}
	
}

struct FoaasRequest: HTTPRequest {
	
	var path: String
	var headers: [String : String] = [:]
	var host: String = "foaas.onrender.com"
	
	init(path: String) {
		self.path = path
	}
}

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
	
	static func getFoassSDK() async throws -> Foaas {
		let request = FoaasRequest(path: "/greed/cat/louis")
		return try await SessionManager.shared.makeRequest(request)
	}
	
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
	
	static func getOpsSDK() async throws -> [FoaasOperation] {
		let request = FoaasRequest(path: "/operations")
		return try await SessionManager.shared.makeRequest(request)
	}
	
	class func getOperations() async throws -> [FoaasOperation] {
		do {
			var request = URLRequest(url: FoaasService.operationsURL)
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			let result = try await URLSession.shared.data(for: request)
			let decoder = JSONDecoder()
			
			return try decoder.decode([FoaasOperation].self, from: result.0)
			
		} catch (let e) {
			print("Error receiving foaas: \(e)")
			return []
		}
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
