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
		
		let root = FoaasLandingCollectionViewController()
		let nav = FoaasNavigationController(rootViewController: root)
		self.window?.rootViewController = nav
		self.window?.makeKeyAndVisible()
		
		ImageDataManager.initialize()
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
