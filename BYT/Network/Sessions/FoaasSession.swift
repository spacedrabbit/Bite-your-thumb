//
//  FoaasSession.swift
//  BYT
//
//  Created by Louis Tur on 2/12/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import Foundation
import LouisSDK

final class SessionManager {
	
	static let shared = SessionManager()
	
	private let manager: RequestManager
	private let printRequest: Bool
	private init() {
		#if DEBUG
		printRequest = true
		#else
		printRequest = false
		#endif
		
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
		if printRequest {
			request.debugPrint()
		}
		
		return try await manager.perform(request: request)
	}
	
}
