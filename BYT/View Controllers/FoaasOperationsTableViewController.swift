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
	var navigationItems: [NavigationItem] = [.done]
	
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
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.75))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		// group.interItemSpacing = .fixed(12.0)
		
		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = 12.0
		section.contentInsets = NSDirectionalEdgeInsets(top: 20.0, leading: 12.0, bottom: 20.0, trailing: 12.0)
		
		return UICollectionViewCompositionalLayout(section: section)
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
}

fileprivate class FoaasOperationCollectionViewCell: UICollectionViewCell {
	
	@Published var operation: FoaasOperation?
	@Published var previewImage: UpsplashImage?
	private var cancellables: Set<AnyCancellable> = []
	
	private let effectsView: UIVisualEffectView = {
		let effect = UIBlurEffect(style: .systemThinMaterial)
		
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
		label.textColor = .black
		label.font = UIFont.systemFont(ofSize: 16.0)
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		self.contentView.clipsToBounds = true
		self.contentView.layer.cornerRadius = 10.0
		
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
		
		self.contentView.addSubview(imagePreview)
		self.contentView.addSubview(effectsView)
		self.contentView.addSubview(titleLabel)
		
		stripAutoResizingMasks(effectsView, imagePreview, titleLabel)
		
		NSLayoutConstraint.activate([
			effectsView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			effectsView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			effectsView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			effectsView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
	
			imagePreview.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			imagePreview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			imagePreview.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
			imagePreview.heightAnchor.constraint(equalTo: self.contentView.heightAnchor),

			titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			titleLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.9),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
