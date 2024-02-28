//
//  FoaasAPIManager.swift
//  AC3.2-BiteYourThumb
//
//  Created by Louis Tur on 11/15/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation
import LouisSDK

class FoaasService {

	static func getFoassSDKSample() async throws -> Foaas {
		let request = FoaasRequest(path: "/greed/cat/louis")
		return try await SessionManager.shared.makeRequest(request)
	}
	
	static func getFoaas(from path: String) async throws -> Foaas {
		let request = FoaasRequest(path: path)
		return try await SessionManager.shared.makeRequest(request)
	}

	static func getMotD() async throws -> Foaas {
		let request = FoaasRequest(path: "/mod")
		return try await SessionManager.shared.makeRequest(request)
	}
	
	static func getOpsSDK() async throws -> [FoaasOperation] {
		let request = FoaasRequest(path: "/operations")
		return try await SessionManager.shared.makeRequest(request)
	}
	
}
