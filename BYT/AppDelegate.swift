//
//  AppDelegate.swift
//  BYT
//
//  Created by Louis Tur on 1/21/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		
		ColorManager.shared.loadCurrentColorScheme()
		ColorManager.shared.loadColorSchemes()
		FoaasDataManager.prefetchOperations()
		
		let config = UISceneConfiguration(name: nil, sessionRole: .windowApplication)
		config.sceneClass = UIWindowScene.self
		config.delegateClass = SceneDelegate.self
		
		return config
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
	
}
