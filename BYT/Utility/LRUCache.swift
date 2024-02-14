//
//  LRUCache.swift
//  BYT
//
//  Created by Louis Tur on 2/14/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit

/**
 Super simple implementation of a generic "Least Recently Used" cache.
 
 */
public class LRUCache<K: Hashable, V>: CustomStringConvertible {
	private var cache: [K: V]
	private let capacity: Int
	public var clearsCacheOnMemoryWarnings = false
	
	public private(set) var keys = [K]()
	
	// MARK: - Constructors
	
	public init(capacity: Int) {
		self.capacity = capacity
		self.cache = [K: V](minimumCapacity: self.capacity)
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleLowMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Methods
	
	public subscript(key: K) -> V? {
		get {
			guard let value = cache[key], let index = keys.firstIndex(of: key) else { return nil }
			if index > 0 {
				keys.remove(at: index)
				keys.insert(key, at: 0)
			}
			return value
		}
		set(value) {
			if let _ = cache[key], let index = keys.firstIndex(of: key) {
				// existing value
				cache[key] = value
				if let _ = value, index > 0 {
					// move to head
					keys.remove(at: index)
					keys.insert(key, at: 0)
				} else if value == nil {
					// remove
					keys.remove(at: index)
				}
			} else if let value = value {
				// new value
				if keys.count >= capacity {
					// remove tail
					let tailKey = keys.removeLast()
					cache[tailKey] = nil
				}
				// add to head
				cache[key] = value
				keys.insert(key, at: 0)
			}
		}
	}
	
	public func removeAll() {
		cache.removeAll()
		keys.removeAll()
	}
	
	// MARK: - Notifications
	
	@objc
	private func handleLowMemoryWarning() {
		guard clearsCacheOnMemoryWarnings else { return }
		removeAll()
	}
	
	// MARK: - CustomStringConvertible
	
	public var description: String {
		return "Keys: \(keys)\nCache: \(cache)\nCapacity: \(capacity)"
	}
}
