//
//  NSLayoutConstraint+Extensions.swift
//  BYT
//
//  Created by Louis Tur on 2/29/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
	
	func withPriority(_ priority: UILayoutPriority) -> Self {
		self.priority = priority
		return self
	}
	
}
