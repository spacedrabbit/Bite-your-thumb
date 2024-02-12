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
										 "topics" : UpsplashTopic.wallpapers.id,
										 "w" : "\(size.width)",
										 "h" : "\(size.height)",
										 "dpr" : "\(Int(scale))"]
		let request = UpsplashRequest(path: "/photos/random", urlParams: params)
		
		return try await UpsplashSessionManager.shared.makeRequest(request)
	}
	
	class func getRandomImages(size: CGSize, scale: CGFloat, count: Int = 30) async throws -> [UpsplashImage] {
		let params: [String : String] = ["orientation" : "portrait",
										 "topics" : UpsplashTopic.wallpapers.id,
										 "w" : "\(size.width)",
										 "h" : "\(size.height)",
										 "dpr" : "\(Int(scale))",
										 "count" : "\(count)" ]
		let request = UpsplashRequest(path: "/photos/random", urlParams: params)
	
		return try await UpsplashSessionManager.shared.makeRequest(request)
	}
	
}

// It'll make sense to move this into it's own Mappable object type if I want to make new backgrounds available
fileprivate struct UpsplashTopic {
	let id: String
	let name: String
	
	// These are just some hardcoded values I got from requesting GET /topics from the upsplash API
	static let wallpapers = UpsplashTopic(id: "bo8jQKTaE0Y", name: "Wallpapers")
	static let coolTones = UpsplashTopic(id: "iXRd8cmpUDI", name: "Cool Tones")
	static let nature = UpsplashTopic(id: "6sMVjTLSkeQ", name: "Nature")
	static let renders3D = UpsplashTopic(id: "CDwuwXJAbEw", name: "3D Renders")
	static let textures = UpsplashTopic(id: "iUIsnVtjB0Y", name: "Textures")
	static let streetPhotography = UpsplashTopic(id: "xHxYTMHLgOc", name: "Street Photography")
	static let experimental = UpsplashTopic(id: "qPYsDzvJOYc", name: "Experimental")
}
