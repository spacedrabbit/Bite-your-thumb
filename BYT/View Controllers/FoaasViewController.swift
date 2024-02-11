//
//  FoaasViewController.swift
//  BYT
//
//  Created by Louis Tur on 1/23/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit
import Combine
import Kingfisher

class FoaasViewController: UICollectionViewController {

	private let backgroundImage: UIImageView = {
		let imageView = UIImageView(frame: .zero)
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	private lazy var refreshControl: UIRefreshControl = {
		let control = UIRefreshControl()
		control.addTarget(self, action: #selector(reload), for: .valueChanged)
		return control
	}()
	
	private struct Identifiers {
		static let foaasCell = "foaasCell"
	}
	
	private var foaas: Foaas?
	private var items: [Item] = []
	private enum Item {
		case foaas(Foaas)
	}
	
	private var cancellables: Set<AnyCancellable> = []
	
	// MARK: - Constructors
	
	override init(collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
		super.init(collectionViewLayout: collectionViewLayout)
		
		self.collectionView.backgroundColor = .green
		// self.collectionView.backgroundView = backgroundImage
		self.collectionView.refreshControl = refreshControl

		self.collectionView.collectionViewLayout = generateLayout()
		self.collectionView.register(FoaasCollectionCell.self, forCellWithReuseIdentifier: Identifiers.foaasCell)
		
		configureConstraints()
		registerForNotifications()
		reload()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	private func configureConstraints() {

	}
	
	// MARK: - Reload
	
	@objc
	private func reload() {
		Task {
			await getLandingMessage()
			// await getBackgroundImage()
		}
	}
	
	private func getLandingMessage() async {
		do {
			let result = try await FoaasService.getFoassSDK()
			foaas = result
			generateItems()
			
			refreshControl.endRefreshing()
			self.collectionView.reloadData()
		} catch {
			refreshControl.endRefreshing()
			print("Error happend: \(error)")
		}
	}
	
	private func getBackgroundImage() async {
		guard let screen = ScenePeeker.shared.rootWindow?.screen else { return }
		do {
			let image = try await UpsplashService.getRandomImage(size: screen.bounds.size, scale: screen.scale)
			self.backgroundImage.image = UIImage(blurHash: image.blurHash, size: screen.bounds.size)
			self.backgroundImage.kf.setImage(with: image.urls.regular)
		} catch {
			print("Error attempting to load image/blurhash: \(error)")
		}
	}
	
	// MARK: - Helpers
	
	private func generateItems() {
		guard let foaas else { return }
		self.items = [.foaas(foaas)]
	}
	
	private func generateLayout() -> UICollectionViewCompositionalLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	// MARK: - Notifications
	
	private func registerForNotifications() {
		
	}
	
	func camerarollButtonTapped() {
		guard let validImage = getScreenShotImage(view: self.view) else { return }
		
		//https://developer.apple.com/reference/uikit/1619125-uiimagewritetosavedphotosalbum
		UIImageWriteToSavedPhotosAlbum(validImage, self, #selector(createScreenShotCompletion(image: didFinishSavingWithError: contextInfo:)), nil)
	}
	
	func shareButtonTapped() {
		guard let validFoaas = self.foaas else { return }
		
		var arrayToShare: [String] = []
		arrayToShare.append(validFoaas.message.filterBadLanguage())
		arrayToShare.append(validFoaas.subtitle.filterBadLanguage())
		
		let activityViewController = UIActivityViewController(activityItems: arrayToShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.view
		
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	func getScreenShotImage(view: UIView) -> UIImage? {
		return nil
		
		//https://developer.apple.com/reference/uikit/1623912-uigraphicsbeginimagecontextwitho
		
		//shortly before the graphics context for the view is determined, the settings menu will animate down (show: false)
		// animateSettingsMenu(show: false, duration: 0.1)
		
		//removing visibility for the add and settings menu button shortly before the screenshot is rendered
		// foaasView.hideHudElements.send(true)

		//initializing and adding the watermark label as a subview
		
		/*
		let label: UILabel = UILabel()
		label.text = "GITHUB: ACCESSLITE/BYT"
		label.textColor = UIColor.white
		label.alpha = 0.50
		
		self.foaasView.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		let _ = [
			label.centerXAnchor.constraint(equalTo: self.foaasView.centerXAnchor),
			label.bottomAnchor.constraint(equalTo: self.foaasView.bottomAnchor, constant: -30.0)
		].map { $0.isActive = true }
		
		//initializing and adding the watermark as a subview
		let octopusImage = UIImage(named: "Octopus")
		let imageView = UIImageView(image: octopusImage)
		imageView.contentMode = .scaleAspectFit
		imageView.tag = 100
		imageView.alpha = 0.50
		
		self.foaasView.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		let _ = [
			imageView.centerXAnchor.constraint(equalTo: self.foaasView.centerXAnchor),
			imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -10.0),
			imageView.heightAnchor.constraint(equalToConstant: 120.0),
			imageView.widthAnchor.constraint(equalToConstant: 120.0)
		].map { $0.isActive = true }
		
		
		//screenshot being taken
		UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, view.layer.contentsScale)
		guard let context = UIGraphicsGetCurrentContext() else{
			return nil
		}
		view.layer.render(in: context)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		//returning visibility to the add Button and remove octopus watermark
		foaasView.hideHudElements.send(false)
		if let octopusView = self.foaasView.viewWithTag(100) {
			octopusView.removeFromSuperview()
		}
		
		//couldnt remove the label from the superview using the tag, as above, so I'm setting the text to ""
		label.text = ""
		
		return image
		 */
	}
	
	///Present appropriate Alert by UIAlertViewController, indicating images are successfully saved or not
	///https://developer.apple.com/reference/uikit/uialertcontroller
	///
	@objc
	internal func createScreenShotCompletion(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: UnsafeMutableRawPointer?) {
		
		if didFinishSavingWithError != nil {
			print("Error in saving image.")
			let alertController = UIAlertController(title: "Failed to save screenshot to photo library", message: nil , preferredStyle: .alert)
			let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
			alertController.addAction(okay)
			// do not dismiss the alert yourself in code this way! add a button and let the user handle it
			present(alertController, animated: true, completion: nil)
		}
		else {
			// this has to be in an else clause. because if error is !nil, you're going to be presenting 2x of these alerts
			print("Image saved.")
			let alertController = UIAlertController(title: "Successfully saved screenshot to photo library", message: nil , preferredStyle: .alert)
			let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
			alertController.addAction(okay)
			
			present(alertController, animated: true, completion: nil)
		}
	}
}

extension FoaasViewController: UICollectionViewDelegateFlowLayout {
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch items[indexPath.item] {
		case .foaas(let f):
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.foaasCell, for: indexPath) as! FoaasCollectionCell
			cell.foaas = f
			return cell
		}
	}

}
