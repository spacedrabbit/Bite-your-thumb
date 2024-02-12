//
//  UpsplashImage.swift
//  BYT
//
//  Created by Louis Tur on 2/12/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import Foundation
import LouisSDK

struct UpsplashImage: Codable, Mappable {
	let id: String
	let slug: String
	let blurHash: String
	let width: Int
	let height: Int
	let description: String?
	let altDescription: String?
	
	let urls: URLBundle
	let links: LinksBundle
	let user: User?
	
	struct URLBundle: Codable, Mappable {
		let full: URL
		let regular: URL
		let small: URL
		let thumb: URL
	}
	
	// ⚠️ Production Consideration:
	// 	https://help.unsplash.com/en/articles/2511258-guideline-triggering-a-download
	//
	//	According the upsplash api, the downloadLocation url must be used to download images in order
	//  to properly credit the author. However, this requires an api request and since I'm limitied
	// 	to 50/hr, I'm not going to do that for a pet project. I'm leaving this note here for the future
	// 	should I decide to submit this to the app store, I will need to switch to using this API for
	//  caching images to disk
	// 	Alternatively, it sounds like I could defer this operation until/if a user shares, screenshots,
	//  or otherwise saves the foaas they create.
	struct LinksBundle: Codable, Mappable {
		let downloadLocation: URL
	}
	
	struct User: Codable, Mappable {
		let id: String
		let username: String
		let name: String?
		let firstName: String?
		let lastName: String?
		
		let links: UpsplashLinks
		let profileImage: ProfileImageLinks
		let social: SocialLinks
		
		struct UpsplashLinks: Codable, Mappable {
			let profile: URL?
			
			enum CodingKeys: String, CodingKey {
				case profile = "html"
			}
		}
		
		struct ProfileImageLinks: Codable, Mappable {
			let small: URL?
			let medium: URL?
			let large: URL?
		}
		
		struct SocialLinks: Codable, Mappable {
			let instagram: String?
			let portfolio: String?
			let twitter: String?
		}
	}
}

extension UpsplashImage {
	
	var imageCacheKey: String {
		return urls.regular.absoluteString
	}
	
}
