//
//  ImageDataManager.swift
//  BYT
//
//  Created by Louis Tur on 2/12/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit
import Combine
import Kingfisher

final class ImageDataManager: ObservableObject {
	
	private static let shared = ImageDataManager()
	private static let imageDefaultsKey = "com.byt.upsplash-images"
	
	private static let defaultDownloadSize: Int = 4
	
	@Published
	private (set) var cachedImages: [UpsplashImage] = [] {
		didSet {
			saveImages(cachedImages)
			ImageDataManager.cachedImagePublisher.send(cachedImages)
		}
	}
	
	private(set) var blurHashedImages: [String : UIImage] = [:]
	
	private var screen: UIScreen {
		DispatchQueue.main.sync {
			return ScenePeeker.shared.rootWindow?.screen ?? UIScreen()
		}
	}
	
	private static let cachedImagePublisher = PassthroughSubject<[UpsplashImage], Never>()
	static var imagePublisher: AnyPublisher<[UpsplashImage], Never> {
		return cachedImagePublisher.eraseToAnyPublisher()
	}
	
	private var bag: Set<AnyCancellable> = []
	
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
				//  note this is being done asynchronously.. i shuold probably kick off the download after this finishes. probably fine with the small size of images total
				clearImages()
				downloadImages(count: Self.defaultDownloadSize)
				return
			}
			
			print("We have cached images, and we're all set!")
			cachedImages = loadedImages
			
			DispatchQueue.global().async {
				for image in self.cachedImages {
					if !ImageCache.default.memoryStorage.isCached(forKey: image.id) {
						self.preloadBlurHashImage(from: image)
					}
				}
			}
		}
	}
	
	func preloadBlurHashImage(from image: UpsplashImage) {
		BlurHashHelper.start(image.blurHash, size: CGSize(width: 275.0, height: 450.0))
			.receive(on: DispatchQueue.global())
			.sink(receiveCompletion: { _ in
				
			}, receiveValue: { value in
				print("Storing value for id: \(image.id)")
				ImageCache.default.memoryStorage.store(value: value, forKey: image.id)
			}).store(in: &bag)
	}
	
	static func getBlurHashImage(for id: String) -> AnyPublisher<UIImage?, Never> {
		if ImageCache.default.memoryStorage.isCached(forKey: id) {
			return Just(ImageCache.default.memoryStorage.value(forKey: id)).eraseToAnyPublisher()
		} else {
			let future: AnyPublisher<UIImage?, Never> = Future<UpsplashImage?, BlurHashingError> { promise in
				Task {
					let result = await getRandomImage()
					if let r = result {
						promise(.success(r))
					} else {
						promise(.failure(BlurHashingError()))
					}
				}
			}
			.replaceError(with: nil)
			.compactMap({ $0 })
			.flatMap({ (upsplashImage) -> AnyPublisher<UIImage?, Never> in
				return BlurHashHelper.start(upsplashImage.blurHash, size: CGSize(width: 275.0, height: 450.0))
					.map({
						ImageCache.default.memoryStorage.store(value: $0, forKey: id)
						return Optional.init($0)
					})
					.replaceError(with: nil)
					.eraseToAnyPublisher()
			})
			.eraseToAnyPublisher()
			
			return future
		}
	}
	
	static func getRandomImage() async -> UpsplashImage? {
		if shared.cachedImages.count > 0 {
			print("Returning random image from cache")
			return shared.cachedImages.randomElement()
			
		} else {
			print("Returning random image from network service")
			let result = try? await UpsplashService.getRandomImage(size: shared.screen.bounds.size, scale: shared.screen.scale)
			guard let result else { return nil }
			shared.cachedImages = [result]
			return result
		}
	}
	
	static func availableImages() async -> [UpsplashImage] {
		if shared.cachedImages.count > 0 {
			return shared.cachedImages
		} else {
			let results = try? await UpsplashService.getRandomImages(size: shared.screen.bounds.size, scale: shared.screen.scale, count: 20)
			
			guard let results else { return [] }
			shared.cachedImages = results
			
			return results
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
