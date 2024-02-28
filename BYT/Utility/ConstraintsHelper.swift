//
//  ConstraintsHelper.swift
//  BYT
//
//  Created by Louis Tur on 2/28/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit

extension UIView {

	func constrainBounds(to otherView: UIView) -> [NSLayoutConstraint] {
		guard let superview,
				otherView.superview === superview
				|| superview === otherView else { return [] }
		stripAutoResizingMasks([self])
		
		return [
			self.centerYAnchor.constraint(equalTo: otherView.centerYAnchor),
			self.centerXAnchor.constraint(equalTo: otherView.centerXAnchor),
			self.heightAnchor.constraint(equalTo: otherView.heightAnchor),
			self.widthAnchor.constraint(equalTo: otherView.widthAnchor)
		]
	}
	
}

