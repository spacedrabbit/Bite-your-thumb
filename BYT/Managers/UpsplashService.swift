//
//  UpsplashService.swift
//  BYT
//
//  Created by Louis Tur on 2/10/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit
import Kingfisher
import LouisSDK
import Combine

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

final class ImageDataManager: ObservableObject {
	
	private static let shared = ImageDataManager()
	private static let imageDefaultsKey = "com.byt.upsplash-images"
	
	private static let defaultDownloadSize: Int = 4
	
	@Published
	private (set) var cachedImages: [UpsplashImage] = [] {
		didSet {
			saveImages(cachedImages)
		}
	}
	
	private var screen: UIScreen {
		DispatchQueue.main.sync {
			return ScenePeeker.shared.rootWindow?.screen ?? UIScreen()
		}
	}
	
	private init() {}
	
	static func initialize() {
		shared.loadImages()
	}
	
	 private func loadImages() {
		print("Image loading has begun...")
		let loadedImages = loadData()
		
		if loadedImages.isEmpty {
			print("No images exist yet, downloading some now")
			downloadImages(count: Self.defaultDownloadSize)
		} else {
			// Might be better in this case to take what is cached, if any, and return that but them also kick
			// off the request to get the remaining difference
			guard loadedImages.allSatisfy({ ImageCache.default.diskStorage.isCached(forKey: $0.imageCacheKey )}) else {
				// Something went wrong, let's retry it all
				
				print("Hm, we have some images but not all of them were cached. Restarting the process")
				clearImages() //  note this is being done asynchronously.. i shuold probably kick off the download after this finishes. probably fine with the small size of images total
				downloadImages(count: Self.defaultDownloadSize)
				return
			}
			
			print("We have cached images, and we're all set!")
			cachedImages = loadedImages
		}
	}
	
	static func getRandomImage() async -> UpsplashImage? {
		if shared.cachedImages.count > 0 {
			print("Returning random image from cache")
			return shared.cachedImages.randomElement()
		} else {
			// TODO: Might be good to cache this image as it gets received
			print("Returning random image from network service")
			return try? await UpsplashService.getRandomImage(size: shared.screen.bounds.size, scale: shared.screen.scale)
		}
	}
	
	private func downloadImages(count: Int) {
		Task {
			print("Starting to download out images")
			let images = (try? await UpsplashService.getRandomImages(size: screen.bounds.size, scale: screen.scale, count: count)) ?? []
			let urls = images.map({ $0.urls.regular })
			
			ImagePrefetcher(urls: urls, options: [.diskCacheExpiration(.never)]) { skipped, failed, completedResources in
				print("Completed download of \(completedResources.count) images")
				if (skipped + failed).count > 0 {
					print("Had some issues. Failed or Skipped: \((skipped + failed).count)")
					let unsuccessful = (skipped + failed).map({ $0.downloadURL })
					ImageDataManager.shared.cachedImages = images.filter({ unsuccessful.contains($0.urls.regular) })
				} else {
					ImageDataManager.shared.cachedImages = images
				}
				
			}.start()
		}
		
	}
	
	private func loadData() -> [UpsplashImage] {
		guard let datas = UserDefaults.standard.object(forKey: Self.imageDefaultsKey) as? [Data] else {
			print("No data was found in user defaults")
			return []
		}
		
		let located = datas.compactMap({ datum in
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			
			return try? decoder.decode(UpsplashImage.self, from: datum)
		})
		
		print("Hurray, there was some data found in defaults! \(located.count) items total")
		return located
	}
	
	private func saveImages(_ images: [UpsplashImage]) {
		let data = images.compactMap({ image in
			let encoder = JSONEncoder()
			encoder.keyEncodingStrategy = .convertToSnakeCase
			
			return try? encoder.encode(image)
		})
		
		print("Saving \(data.count) image items to user defaults")
		UserDefaults.standard.set(data, forKey: Self.imageDefaultsKey)
	}
	
	private func clearImages() {
		print("Images being cleared from cache")
		ImageCache.default.clearCache()
		UserDefaults.standard.set(nil, forKey: Self.imageDefaultsKey)
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
	
	final class func getRandomImages(size: CGSize, scale: CGFloat, count: Int = 30) async throws -> [UpsplashImage] {
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
		do {
			return try await manager.perform(request: request)
		} catch (let error) {
			print("Error encountered on upsplash request: \(error)")
			throw error
		}
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
