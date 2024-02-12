//
//  UpsplashRequest.swift
//  BYT
//
//  Created by Louis Tur on 2/12/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import LouisSDK

struct UpsplashRequest: HTTPRequest {
	var scheme: String = "https"
	var host: String = "api.unsplash.com"
	var path: String
	var urlParams: [String : String?]
	
	var params: [String : Any] = [:]
	var headers: [String : String] = [
		"Content-Type" : "application/json"
	]
	var addAuthorizationToken: Bool = false
	var requestMethod: HTTPMethod
	
	init(path: String, headers: [String : String] = [:], urlParams: [String : String] = [:], method: HTTPMethod = .get) {
		self.path = path
		self.headers = headers
		self.urlParams = urlParams
		self.requestMethod = method
	}
	
}
