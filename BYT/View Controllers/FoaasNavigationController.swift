//
//  FoaasNavigationController.swift
//  BYT
//
//  Created by Louis Tur on 1/23/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit

// MARK: - FoaasViewController Protocol

protocol FoaasViewController: UIViewController {
	
	var foaasNavigationBar: FoassBottomBar { get }
	
	var navigationItems: [NavigationItem] { get set }
	
}

extension FoaasViewController {
	
	var foaasNavigationBar: FoassBottomBar {
		return (self.navigationController as? FoaasNavigationController)?.navbar ?? FoassBottomBar()
	}

}

// MARK: - FoaasNavigationController

class FoaasNavigationController: UINavigationController, UINavigationControllerDelegate {
	
	fileprivate let navbar: FoassBottomBar = FoassBottomBar(frame: .zero)
	private var navButtons: [NavigationButton] = []
	
	override init(rootViewController: UIViewController) {
		super.init(rootViewController: rootViewController)
		
		self.view.addSubview(navbar)
		self.delegate = self
		makeButtons()
		updateNavigationButtons(using: rootViewController, animated: false)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setNavigationBarHidden(true, animated: false)
		positionNavbar()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		positionNavbar()
	}
	
	// MARK: - Setup
	
	private func positionNavbar() {
		if self.isViewLoaded, let sv = navbar.superview, sv == self.view {
			self.view.bringSubviewToFront(navbar)
			
			navbar.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				navbar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
				navbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
			])
		}
	}
	
	private func makeButtons() {
		navButtons = NavigationItem.allCases.map({ item in
			let button = NavigationButton(navigationItem: item)
			button.contentMode = .scaleAspectFit
			button.addTarget(self, action: #selector(handleButtonTapped(_:)), for: .touchUpInside)
			return button
		})
	}
	
	func updateNavigationButtons(using to: UIViewController, animated: Bool = true) {
		guard
			let foaasVC = to as? FoaasViewController
		else { return }
		
		let buttons = navButtons.filter({ foaasVC.navigationItems.contains($0.navigationItem) })
		buttons.forEach({
			navbar.addButton($0)
		})
		
		// If there is more than 1 on stack, we must have a back button
		// Otherwise, the view controller will decide what to use
	}
	
	@objc
	private func handleButtonTapped(_ sender: NavigationButton) {
		switch sender.navigationItem {
			
		case .add:
			let dtvc = FoaasOperationsTableViewController()
			self.pushViewController(dtvc, animated: true)
			
		case .close:
			print("Close")
			
		case .done:
			print("Done")
			
		case .profanity:
			print("Profanity Toggle")
			
		case .back:
			print("Back")
			
		case .share:
			print("Share")
			
		}
	}
	
	// MARK: - Navigation Changes
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		positionNavbar()
		updateNavigationButtons(using: viewController)
	}
	
	
}

// MARK: - FoassBottomBar

final class FoassBottomBar: UIView {
	private let buttonSize: CGFloat = 48.0
	
	private let stackview: UIStackView = {
		let stackview = UIStackView(frame: .zero)
		stackview.distribution = .equalSpacing
		stackview.alignment = .center
		stackview.axis = .horizontal
		stackview.spacing = 12.0
		return stackview
	}()
	
//	private let effectsView: UIVisualEffectView = {
//		let effect = UIBlurEffect(style: .extraLight)
//
//		let view = UIVisualEffectView(frame: .zero)
//		view.effect = effect
//		return view
//	}()
	
	
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		
//		self.addSubview(effectsView)
//		effectsView.contentView.addSubview(stackview)
		self.backgroundColor = .red
		self.addSubview(stackview)
		self.clipsToBounds = true

		stackview.translatesAutoresizingMaskIntoConstraints = false
		[
			self.widthAnchor.constraint(greaterThanOrEqualToConstant: 60.0),
			self.widthAnchor.constraint(equalTo: stackview.widthAnchor),
			self.topAnchor.constraint(equalTo: stackview.topAnchor, constant: -8.0),
			self.bottomAnchor.constraint(equalTo: stackview.bottomAnchor,constant: 8.0),
		].activate()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Adjusting nav items
	
	fileprivate func addButton(_ button: UIButton) {
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: buttonSize),
			button.heightAnchor.constraint(equalToConstant: buttonSize)
		])
		
		button.alpha = 0.0
		self.stackview.addArrangedSubview(button)
		UIView.animate(withDuration: 0.3) {
			button.alpha = 1.0
			self.layoutIfNeeded()
		}
	}
	
	fileprivate func removeButton(_ button: UIButton) {
		UIView.animate(withDuration: 0.3, animations: {
			button.alpha = 0.0
			self.layoutIfNeeded()
		}) { _ in
			self.stackview.removeArrangedSubview(button)
		}
	}
	
	override var intrinsicContentSize: CGSize {
		return stackview.intrinsicContentSize
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.cornerRadius = self.h / 2.0
	}
}

fileprivate class NavigationButton: UIButton {
	
	let navigationItem: NavigationItem
	
	init(navigationItem: NavigationItem) {
		self.navigationItem = navigationItem
		super.init(frame: .zero)
		
		self.setImage(navigationItem.image, for: .normal)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

enum NavigationItem: CaseIterable, Equatable {
	case add, close, done, profanity, back, share
	
	var image: UIImage? {
		switch self {
		case .add: return NavigationItemImage.add
		case .back: return NavigationItemImage.back
		case .close: return NavigationItemImage.close
		case .profanity: return NavigationItemImage.profanity
		case .share: return NavigationItemImage.share
		case .done: return NavigationItemImage.done
		}
	}
	
	var displayPriority: Int {
		switch self {
		case .back: return 0
		case .share: return 1
		case .add: return 2
		case .profanity: return 3
		case .close: return 999
		case .done: return 999
		}
	}
	
	struct NavigationItemImage {
		
		static let add = UIImage(systemName: "plus.circle.fill")?
			.resized(toWidth: 32.0)?
			.withTintColor(.systemBlue)
		
		static let back = UIImage(systemName: "arrow.backward.circle.fill")?
			.resized(toWidth: 32.0)?
			.withTintColor(.systemBlue)
		
		static let close = UIImage(systemName: "xmark.circle.fill")?
			.resized(toWidth: 32.0)?
			.withTintColor(.systemBlue)
		
		static let done = UIImage(named: "checkmark.circle.fill")?
			.resized(toWidth: 32.0)?
			.withTintColor(.systemBlue)
		
		static let share = UIImage(systemName: "square.and.arrow.up.circle.fill")?
			.resized(toWidth: 32.0)?
			.withTintColor(.systemBlue)
		
		static let profanity = UIImage(systemName: "exclamationmark.bubble.circle.fill")?
			.resized(toWidth: 32.0)?
			.withTintColor(.systemBlue)
		
	}
}
