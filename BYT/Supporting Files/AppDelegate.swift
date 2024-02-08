//
//  AppDelegate.swift
//  BYT
//
//  Created by Louis Tur on 1/21/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.window?.makeKey()
		
		ColorManager.shared.loadCurrentColorScheme()
		ColorManager.shared.loadColorSchemes()
		
		// let version = VersionManager.load()
		
		FoaasDataManager.prefetchOperations()
		//requestColorSchemes()
		requestVersionInfo()
		
		let navigationVC = FoaasNavigationController(rootViewController: FoaasViewController())
		self.window?.rootViewController = navigationVC
		self.window?.makeKeyAndVisible()
		return true
	}
	
	func requestColorSchemes() {
		//    FoaasDataManager.shared.requestColorSchemeData(endpoint: FoaasService.colorSchemeURL) { (data: Data?) in
		//      guard let validData = data else { return }
		//      guard let colorSchemes = ColorScheme.parseColorSchemes(from: validData) else { return }
		//      ColorManager.shared.colorSchemes = colorSchemes
		//
		//      var colorUpdateNotification = Notification(name: Notification.Name.init(rawValue: FoaasColorPickerView.colorViewsShouldUpdateNotification))
		//      colorUpdateNotification.userInfo = [ FoaasColorPickerView.updatedColorsKey : ColorManager.shared.colorSchemes.map{ $0.primary }]
		//      NotificationCenter.default.post(colorUpdateNotification)
		//    }
	}
	
	func requestVersionInfo() {
		
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		requestColorSchemes()
		requestVersionInfo()
	}
	
}

