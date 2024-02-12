//
//  SceneDelegate.swift
//  BYT
//
//  Created by Louis Tur on 2/10/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit
import Kingfisher

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

		guard let windowScene = (scene as? UIWindowScene) else { return }
		window = UIWindow(frame: windowScene.coordinateSpace.bounds)
		window?.windowScene = windowScene
		
		ScenePeeker.shared.setWindow(window)
		
		let root = FoaasViewController()
		let nav = FoaasNavigationController(rootViewController: root)
		self.window?.rootViewController = nav
		self.window?.makeKeyAndVisible()
		
		Task { await downloadBackgroundImages() }
	}
	
	private func downloadBackgroundImages() async {
		guard let screen = window?.screen else { return }
		
		let optImages = try? await UpsplashService.getRandomImages(size: screen.bounds.size, scale: screen.scale, count: 4)
		
		let urls = optImages?.map({ $0.urls.regular }) ?? []
		ImagePrefetcher(urls: urls, options: [.diskCacheExpiration(.days(7))]) { _, _, completedResources in
			self.checkCacheStatus(completedResources.map({ $0.cacheKey }))
		}.start()
		
		
	}
	
	private func checkCacheStatus(_ cacheKeys: [String]) {
		for key in cacheKeys {
			if ImageCache.default.diskStorage.isCached(forKey: key) {
				print("\nKey: \(key)")
				print(ImageCache.default.imageCachedType(forKey: key))
			}
			
		}
	}

}

final class ScenePeeker {
	static let shared = ScenePeeker()
	
	var rootWindow: UIWindow? { return _root }
	
	private unowned var _root: UIWindow?
	private init() {}
	fileprivate func setWindow(_ window: UIWindow?) {
		_root = window
	}
}
