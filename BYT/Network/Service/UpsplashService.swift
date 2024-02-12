//
//  UpsplashService.swift
//  BYT
//
//  Created by Louis Tur on 2/10/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit
import LouisSDK

final class UpsplashService {
	
	class func getRandomImage(size: CGSize, scale: CGFloat) async throws -> UpsplashImage {
		let params: [String : String] = ["orientation" : "portrait",
										 "topics" : "bo8jQKTaE0Y",
										 "w" : "\(size.width)",
										 "h" : "\(size.height)",
										 "dpr" : "\(Int(scale))"]
		let request = UpsplashRequest(path: "/photos/random", urlParams: params)
		
		return try await UpsplashSessionManager.shared.makeRequest(request)
	}
	
	class func getRandomImages(size: CGSize, scale: CGFloat, count: Int = 30) async throws -> [UpsplashImage] {
		let params: [String : String] = ["orientation" : "portrait",
										 "topics" : "bo8jQKTaE0Y",
										 "w" : "\(size.width)",
										 "h" : "\(size.height)",
										 "dpr" : "\(Int(scale))",
										 "count" : "\(count)" ]
		let request = UpsplashRequest(path: "/photos/random", urlParams: params)
	
		return try await UpsplashSessionManager.shared.makeRequest(request)
	}
	
}

