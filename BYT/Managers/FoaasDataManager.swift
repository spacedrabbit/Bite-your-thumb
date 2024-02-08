//
//  FoaasDataManager.swift
//  AC3.2-BiteYourThumb
//
//  Created by Louis Tur on 11/20/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

class FoaasDataManager {
	static let shared = FoaasDataManager()
	static let foaasURL = URL(string: "https://foaas.onrender.com/awesome/Someone")
	
	private(set) var operations: [FoaasOperation] = []
	
	private static let opsKey: String = "com.byt.ops"
	
	private init() {}
	
	// MARK: API Request
	
	/// Opportunistically loads `[FoaasOperation]` from `UserDefaults` if present. Otherwise, makes an API
	/// request to `FoaasAPIManager` to retrieve data. Additionally, saves valid `FoaasOperation`.
	///
	/// - Parameter operations: If located in `UserDefaults` or the API call is successful,
	///    the converted `[FoaasOperation]` based on latest server info
	static func getOperations() async -> [FoaasOperation] {
		if shared.operations.count > 0 {
			return shared.operations
		}
		
		do {
			return try await FoaasService.getOpsSDK()
		} catch (let e) {
			print("Error encountered getting operations: \(e)")
			return []
		}
	}
	
	static func prefetchOperations() {
		Task { await getOperations() }
	}
	
	// MARK: - Save/Load
	
	/// Saves `[FoaasOperation]` to `UserDefaults`
	///
	/// - Parameter operations: The array of `FoaaasOperation` to store to `UserDefaults`
	static func save(operations: [FoaasOperation]) {
		shared.operations = operations

		let result = shared.operations.compactMap({ try? JSONEncoder().encode($0) })
		UserDefaults.standard.set(result, forKey: Self.opsKey)
	}
	
	static func load() -> [FoaasOperation] {
		guard let result = UserDefaults.standard.object(forKey: Self.opsKey) as? [Data] else { return [] }
		
		return result.compactMap({ try? JSONDecoder().decode(FoaasOperation.self, from: $0) })
	}
	
	static func deleteStoredOperations() {
		UserDefaults.standard.removeObject(forKey: Self.opsKey)
		shared.operations = []
	}
	
}
