//
//  Extension + UIColor.swift
//  BYT
//
//  Created by Tom Seymour on 1/29/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	/**
	 Takes a hex string and converts to RGB or RGBA then a UIColor.  Defaults to black.
	 https://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
	 
	 */
	public convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt32()
		int = UInt32(Scanner(string: hex).scanInt32(representation: .hexadecimal) ?? 0)
		let r, g, b, a: UInt32
		switch hex.count {
		case 3: // RGB (12-bit)
			(r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
		case 6: // RGB (24-bit)
			(r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
		case 8: // ARGB (32-bit)
			(r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, int >> 24)
		default:
			(r, g, b, a) = (0, 0, 0, 255)
		}
		self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
	}
	
	public convenience init(r: Int, g: Int, b: Int, a: Float = 1.0) {
		self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
	}
}
extension UIImage {
	
	func maskWith(color: UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		
		let context = UIGraphicsGetCurrentContext()!
		context.translateBy(x: 0, y: size.height)
		context.scaleBy(x: 1.0, y: -1.0)
		context.setBlendMode(.normal)
		
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		context.clip(to: rect, mask: cgImage!)
		
		color.setFill()
		context.fill(rect)
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()!
		
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
	fileprivate func modifiedImage(_ draw: (CGContext, CGRect) -> ()) -> UIImage {
		
		// using scale correctly preserves retina images
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		let context: CGContext! = UIGraphicsGetCurrentContext()
		assert(context != nil)
		
		// correctly rotate image
		context.translateBy(x: 0, y: size.height)
		context.scaleBy(x: 1.0, y: -1.0)
		
		let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
		
		draw(context, rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image!
	}
	
	func tintPhoto(_ tintColor: UIColor) -> UIImage {
		
		return modifiedImage { context, rect in
			// draw black background - workaround to preserve color of partially transparent pixels
			context.setBlendMode(.normal)
			UIColor.black.setFill()
			context.fill(rect)
			
			// draw original image
			context.setBlendMode(.normal)
			context.draw(cgImage!, in: rect)
			
			// tint image (loosing alpha) - the luminosity of the original image is preserved
			context.setBlendMode(.color)
			tintColor.setFill()
			context.fill(rect)
			
			// mask by alpha values of original image
			context.setBlendMode(.destinationIn)
			context.draw(context.makeImage()!, in: rect)
		}
	}
}
