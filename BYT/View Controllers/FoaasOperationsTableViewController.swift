//
//  FoaasOperationsTableViewController.swift
//  BYT
//
//  Created by Louis Tur on 1/23/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit
import Combine

class FoaasOperationCollectionViewController: UICollectionViewController, FoaasViewController {
	var navigationItems: [NavigationItem] = [.profanity, .done]
	
	private lazy var refreshControl: UIRefreshControl = {
		let control = UIRefreshControl()
		control.addTarget(self, action: #selector(reload), for: .valueChanged)
		return control
	}()
	
	private struct Identifiers {
		static let foaasOperationCell = "foaasOperationCell"
	}
	
	private var items: [Item] = []
	private enum Item {
		case operation(FoaasOperation)
	}
	
	private var activeTask: Task<Void, Never>? {
		willSet {
			activeTask?.cancel()
		}
	}
	
	private var images: [UpsplashImage] = []
	private var cancellables: Set<AnyCancellable> = []
	
	// MARK: - Constructors
	
	override init(collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
		super.init(collectionViewLayout: collectionViewLayout)
		self.collectionView.refreshControl = refreshControl
		self.collectionView.delaysContentTouches = false

		self.collectionView.collectionViewLayout = generateLayout()
		self.collectionView.register(FoaasOperationCollectionViewCell.self, forCellWithReuseIdentifier: Identifiers.foaasOperationCell)
		
		Task { images = await ImageDataManager.availableImages() }
		ImageDataManager.imagePublisher
			.sink { images in
				self.images = images
				self.collectionView.reloadData()
			}.store(in: &cancellables)
		
		reload()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Reload
	
	@objc
	private func reload() {
		
		activeTask = Task {
			do {
				
				let result = try await FoaasService.getOpsSDK()
				
				self.items = result.map({ Item.operation($0) })
				self.collectionView.reloadData()
				
			} catch {
				print("Error occured getting ops: \(error)")
			}
		}
		
	}
	
	// MARK: - Helpers
	
	private func generateLayout() -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { section, layoutEnvironment in
			let spacing: CGFloat = 12.0
			let contentInsets = NSDirectionalEdgeInsets(top: 20.0, leading: 12.0, bottom: 20.0, trailing: 12.0)
			let itemCount: CGFloat = 2
			
			let totalHorizontalInsets = contentInsets.leading + contentInsets.trailing
			let totalAvailableWidth = layoutEnvironment.container.effectiveContentSize.width - totalHorizontalInsets
			let totalSpacing = spacing * (itemCount - 1)
			
			// Calculate the available width for each item
			let adjustedItemWidth = (totalAvailableWidth - totalSpacing) / itemCount
			let itemFractionalWidth = adjustedItemWidth / totalAvailableWidth

			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemFractionalWidth), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.75))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			group.interItemSpacing = .fixed(spacing)
			
			let section = NSCollectionLayoutSection(group: group)
			section.interGroupSpacing = 12.0
			section.contentInsets = NSDirectionalEdgeInsets(top: 20.0, leading: 12.0, bottom: 20.0, trailing: 12.0)
			
			return section
		}
		
		return layout
	}

}

extension FoaasOperationCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch items[indexPath.item] {
		case .operation(let op):
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.foaasOperationCell, for: indexPath) as! FoaasOperationCollectionViewCell
			cell.operation = op
			cell.previewImage = images[indexPath.item % images.count]
			
			return cell
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch items[indexPath.item] {
		case .operation(let op):
			let dtvc = FoaasPrevewViewController(operation: op)
			self.navigationController?.pushViewController(dtvc, animated: true)
		}
	}
}

fileprivate class FoaasOperationCollectionViewCell: UICollectionViewCell {
	
	// I think I like it better just on highlight
//	override var isSelected: Bool {
//		didSet {
//			if isSelected || isHighlighted {
//				UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState]) {
//					self.animatedContainer.transform = CGAffineTransform.identity.concatenating(CGAffineTransform(scaleX: 0.92, y: 0.92))
//				}
//			} else {
//				UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState]) {
//					self.animatedContainer.transform = .identity
//				}
//			}
//		}
//	}
	
	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState]) {
					self.animatedContainer.transform = CGAffineTransform.identity.concatenating(CGAffineTransform(scaleX: 0.92, y: 0.92))
				}
			} else {
				UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState]) {
					self.animatedContainer.transform = .identity
				}
			}
		}
	}
	
	@Published var operation: FoaasOperation?
	@Published var previewImage: UpsplashImage?
	
	private var cancellables: Set<AnyCancellable> = []
	
	private var animatedContainer = UIView()
	
	private let effectsView: UIVisualEffectView = {
		let effect = UIBlurEffect(style: .light)
		
		let view = UIVisualEffectView(effect: effect)
		
		return view
	}()
	
	private let imagePreview: ImageView = {
		let imageView = ImageView(frame: .zero)
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		animatedContainer.clipsToBounds = true
		animatedContainer.layer.cornerRadius = 10.0
		effectsView.layer.cornerRadius = 4.0
		effectsView.clipsToBounds = true
		
		$operation
			.compactMap{ $0 }
			.sink { ops in
				self.titleLabel.text = ops.shortname
				self.setNeedsLayout()
				self.layoutIfNeeded()
			}.store(in: &cancellables)
		
		$previewImage
			.compactMap({ $0 })
			.sink { image in
				self.imagePreview.setImage(with: image.urls.small)
			}.store(in: &cancellables)
		
		self.contentView.addSubview(animatedContainer)
		animatedContainer.addSubview(imagePreview)
		animatedContainer.addSubview(effectsView)
		animatedContainer.addSubview(titleLabel)
		
		stripAutoResizingMasks(animatedContainer, effectsView, imagePreview, titleLabel)
		
		NSLayoutConstraint.activate([
			animatedContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			animatedContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			animatedContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			animatedContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			
			effectsView.leadingAnchor.constraint(equalTo: animatedContainer.leadingAnchor, constant: 12.0),
			effectsView.trailingAnchor.constraint(equalTo: animatedContainer.trailingAnchor,constant: -12.0),
			effectsView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12.0),
			effectsView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.0),
	
			imagePreview.topAnchor.constraint(equalTo: animatedContainer.topAnchor),
			imagePreview.leadingAnchor.constraint(equalTo: animatedContainer.leadingAnchor),
			imagePreview.widthAnchor.constraint(equalTo: animatedContainer.widthAnchor),
			imagePreview.heightAnchor.constraint(equalTo: animatedContainer.heightAnchor),

			titleLabel.centerXAnchor.constraint(equalTo: animatedContainer.centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: animatedContainer.centerYAnchor),
			titleLabel.widthAnchor.constraint(equalTo: animatedContainer.widthAnchor, multiplier: 0.86),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
