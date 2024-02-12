//
//  UpsplashSession.swift
//  BYT
//
//  Created by Louis Tur on 2/12/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import Foundation
import LouisSDK

final class UpsplashSessionManager {
	
	static let shared = UpsplashSessionManager()
	
	private let manager: RequestManager
	private init() {
		let config = URLSessionConfiguration.default
		config.httpAdditionalHeaders = UpsplashSessionManager.defaultHeaders
		
		let session = URLSession(configuration: config)
		manager = RequestManagerFactory.make(with: session)
	}
	
	private static let defaultHeaders: [String : String] = {
		let acceptEncoding = "gzip;q=1.0, compress;q=0.5"
		let accept = "application/json"
		let auth = "Client-ID R65z2gc-B2soZEF1O3o4HvlMqVW6bRk2XsgH0b9TqZg"
		let acceptVersion = "v1"
		
		// Add anything else that needs to be part of every request made
		return ["Accept" : accept,
				"Accept-Encoding" : acceptEncoding,
				"Authorization" : auth,
				"Accept-Version" : acceptVersion]
	}()
	
	func makeRequest<T>(_ request: UpsplashRequest) async throws -> T where T: Mappable {
		do {
			return try await manager.perform(request: request)
		} catch (let error) {
			print("Error encountered on upsplash request: \(error)")
			throw error
		}
	}
	
}
