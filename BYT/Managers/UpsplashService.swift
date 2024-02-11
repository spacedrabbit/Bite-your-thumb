//
//  UpsplashService.swift
//  BYT
//
//  Created by Louis Tur on 2/10/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit
import LouisSDK

struct UpsplashImage: Decodable, Mappable {
	let id: String
	let slug: String
	let blurHash: String
	let width: Int
	let height: Int
	let description: String
	
	struct URLBundle: Decodable, Mappable {
		let full: URL
		let small: URL
		let thumb: URL
	}
}

class UpsplashService {
	
	final class func getRandomImage(size: CGSize, scale: CGFloat) async throws -> UpsplashImage {
		let params: [String : String] = ["orientation" : "portrait",
										 "topics" : "bo8jQKTaE0Y",
										 "w" : "\(size.width)",
										 "h" : "\(size.height)",
										 "dpr" : "\(Int(scale))"]
		let request = UpsplashRequest(path: "/photos/random", urlParams: params)
		
		return try await UpsplashSessionManager.shared.makeRequest(request)
	}
	
}

class UpsplashSessionManager {
	
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
		return try await manager.perform(request: request)
	}
	
}

struct UpsplashRequest: HTTPRequest {
	var host: String = "api.unsplash.com"
	var path: String
	var urlParams: [String : String?]
	
	var params: [String : Any] = [:]
	var headers: [String : String] = [:]
	var addAuthorizationToken: Bool = false
	var requestMethod: HTTPMethod
	
	init(path: String, headers: [String : String] = [:], urlParams: [String : String] = [:], method: HTTPMethod = .get) {
		self.path = path
		self.headers = headers
		self.urlParams = urlParams
		self.requestMethod = method
	}
	
}
