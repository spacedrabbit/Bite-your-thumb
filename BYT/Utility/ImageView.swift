//
//  ImageView.swift
//  BYT
//
//  Created by Louis Tur on 2/11/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import UIKit
import Kingfisher

typealias ImageDownloadTask = DownloadTask

class ImageView: UIImageView {
	
	@discardableResult
	open func setImage(with url: URL?, placeholder: UIImage? = nil, progress: ((Float) -> Void)? = nil) -> ImageDownloadTask? {
		
		let options: KingfisherOptionsInfo = [.transition(.fade(0.2))]
		
		return self.kf.setImage(with: url, placeholder: placeholder, options: options, progressBlock: { receivedSize, totalSize in
			guard let progress else { return }
			progress(Float(receivedSize) / Float(totalSize))
		}) { result in
			
			switch result {
			case .success(let value):
				if let url {
					let lastComponent = url.lastPathComponent
					// print("Last componetn was: \(lastComponent)")
					ImageCache.default.store(value.image, forKey: lastComponent, toDisk: true)
				}
				
			case .failure(let error):
				print("Error occurred for setting image: \(error)")
			}
		}
	}
	
}
