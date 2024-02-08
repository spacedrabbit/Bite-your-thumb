//
//  VersionManager.swift
//  BYT
//
//  Created by Tom Seymour on 1/29/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import Foundation

class VersionManager {
	
	static let versionKey: String = "com.byt.version.key"
	private lazy var _currentVersion: Version = defaultVersion
    
	static var currentVersion: Version { shared._currentVersion }
	static let shared = VersionManager()
	
    private init() {}

	private var defaultVersion: Version {
		Version(version: "1.0.0",
				message: "Made with 🤖",
				date: Date())
	}
	
	static func update(_ version: Version) {
		guard let existing = Self.load() else {
			Self.save(version)
			return
		}
		
		Self.save(version)
		if existing.version != version.version {
			NotificationCenter.default.post(name: .versionDidUpdateNotification, object: [Self.versionKey : version])
		}
	}
	
	static func save(_ version: Version) {
		shared._currentVersion = version
		guard let data = try? JSONEncoder().encode(version) else { return }
		UserDefaults.standard.set(data, forKey: Self.versionKey)
	}
	
	static func load() -> Version? {
		guard
			let existingData = UserDefaults.standard.object(forKey: versionKey) as? Data,
			let version = try? JSONDecoder().decode(Version.self, from: existingData)
		else {
			shared._currentVersion = shared.defaultVersion
			return nil
		}
		return version
	}

}

extension Notification.Name {
	
	static let versionDidUpdateNotification = Notification.Name("com.byt.version.updated")
}
