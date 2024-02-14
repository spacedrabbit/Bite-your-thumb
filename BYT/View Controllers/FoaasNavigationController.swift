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
		
		var modifiedItems = foaasVC.navigationItems
		if !modifiedItems.contains(.back) && foaasVC !== self.viewControllers.first {
			modifiedItems.append(.back)
		}
		
		let buttons = navButtons.filter({ modifiedItems.contains($0.navigationItem) })
		navbar.updateButtons(buttons)
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
			self.popViewController(animated: true)
			
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
	private typealias ButtonBundle = (button: NavigationButton, index: Int)
	
	private let buttonSize: CGFloat = 48.0
	
	private let stackview: UIStackView = {
		let stackview = UIStackView(frame: .zero)
		stackview.distribution = .equalSpacing
		stackview.alignment = .center
		stackview.axis = .horizontal
		stackview.spacing = 12.0
		return stackview
	}()
	
	private var navigationButtons: [NavigationButton] {
		return stackview.arrangedSubviews.compactMap({ $0 as? NavigationButton })
	}

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
		
		self.translatesAutoresizingMaskIntoConstraints = false
		stackview.translatesAutoresizingMaskIntoConstraints = false
		
		let widthConstraintMin = self.widthAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor)
		widthConstraintMin.priority = UILayoutPriority(rawValue: 999.0)
		
		let widthConstraintIdeal = self.widthAnchor.constraint(equalTo: stackview.widthAnchor)
		widthConstraintIdeal.priority = .defaultHigh
		
		[
			widthConstraintMin,
			widthConstraintIdeal,
			stackview.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.topAnchor.constraint(equalTo: stackview.topAnchor, constant: -8.0),
			self.bottomAnchor.constraint(equalTo: stackview.bottomAnchor,constant: 8.0),
		].activate()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Adjusting nav items
	
	fileprivate func updateButtons(_ buttons: [NavigationButton]) {
		// if we already have the button we need, ignore for now
		var remaining = buttons.filter({ !navigationButtons.contains($0) })
		
		while let newBttn = remaining.popLast() {
			if navigationButtons.isEmpty {
				addButton(newBttn)
				continue
			}
			
			for (idx, navBttn) in navigationButtons.enumerated() {
				if newBttn.navigationItem.displayPriority <= navBttn.navigationItem.displayPriority {
					addButton(newBttn, at: idx)
					continue
				} else if idx == remaining.count - 1 {
					addButton(newBttn, at: idx)
				}
			}
		}
	}
	
	private func displayButtons(_ show: [ButtonBundle], hide: [ButtonBundle], animated: Bool = true) {
		
	}
	
	fileprivate func addButton(_ button: NavigationButton, at index: Int = 0, animated: Bool = true) {
			button.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				button.widthAnchor.constraint(equalToConstant: buttonSize),
				button.heightAnchor.constraint(equalToConstant: buttonSize)
			])
		
		if animated {
			button.alpha = 0.0
			stackview.insertArrangedSubview(button, at: index)
			UIView.animate(withDuration: 0.3) {
				button.alpha = 1.0
				self.layoutIfNeeded()
			}
		} else {
			stackview.insertArrangedSubview(button, at: index)
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
