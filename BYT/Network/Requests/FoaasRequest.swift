//
//  FoaasRequest.swift
//  BYT
//
//  Created by Louis Tur on 2/12/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import LouisSDK

struct FoaasRequest: HTTPRequest {
	var scheme: String = "https"
	var host: String = "foaas.onrender.com"
	var path: String
	var headers: [String : String] = [
		"Content-Type" : "application/json"
	]
	var params: [String : Any] = [:]
	var urlParams: [String : String?] = [:]
	var addAuthorizationToken: Bool = false
	var requestMethod: HTTPMethod = .get
	
	init(path: String) {
		self.path = path
	}
}
