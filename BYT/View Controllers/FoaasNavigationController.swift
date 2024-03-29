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
	
	var foaasNavigationController: FoaasNavigationController { get }
	
	var foaasNavigationBar: FoassBottomBar { get }
	
	var navigationItems: [NavigationItem] { get set }
	
}

extension FoaasViewController {
	
	var foaasNavigationBar: FoassBottomBar {
		return (self.navigationController as? FoaasNavigationController)?.navbar ?? FoassBottomBar()
	}
	
	var foaasNavigationController: FoaasNavigationController {
		return self.navigationController as? FoaasNavigationController
			?? FoaasNavigationController(rootViewController: UIViewController(nibName: nil, bundle: nil))
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
		navButtons = NavigationItem.allCases
			.sorted(by: { $0.displayPriority < $1.displayPriority })
			.map({ item in
				let button = NavigationButton(navigationItem: item)
				button.contentMode = .scaleAspectFit
				button.addTarget(self, action: #selector(handleButtonTapped(_:)), for: .touchUpInside)
				return button
			})
		navbar.register(navButtons)
	}
	
	func updateNavigationButtons(using to: UIViewController, animated: Bool = true) {
		guard
			let toVC = to as? FoaasViewController
		else { return }
		
		var modifiedItems = toVC.navigationItems
		if !modifiedItems.contains(.back) && toVC !== self.viewControllers.first {
			modifiedItems.append(.back)
		}
		modifiedItems.sort(by: { $0.displayPriority < $1.displayPriority })
		
		navbar.updateButtonBar(modifiedItems)
	}
	
	@objc
	private func handleButtonTapped(_ sender: NavigationButton) {
		switch sender.navigationItem {
			
		case .add:
			let dtvc = FoaasOperationCollectionViewController()
			self.pushViewController(dtvc, animated: true)
			
		case .close:
			print("Close")
			
		case .done:
			self.popViewController(animated: true)
			
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
		stackview.distribution = .equalCentering
		stackview.alignment = .center
		stackview.axis = .horizontal
		stackview.spacing = 12.0
		return stackview
	}()
	
	private var navigationButtons: [NavigationButton] {
		return stackview.arrangedSubviews.compactMap({ $0 as? NavigationButton })
	}

	private let effectsView: UIVisualEffectView = {
		let effect = UIBlurEffect(style: .systemMaterialLight)
		let view = UIVisualEffectView(frame: .zero)
		view.effect = effect
		return view
	}()
	
	private var widthConstraintIdeal: NSLayoutConstraint?
	private var widthConstraintMin: NSLayoutConstraint?
	private var stackWidthConstraintIdeal: NSLayoutConstraint?
	
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)

		self.addSubview(effectsView)
		self.addSubview(stackview)
		self.clipsToBounds = true
		
		stripAutoResizingMasks([self, effectsView, stackview])

		widthConstraintMin = self.widthAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor)
		widthConstraintMin?.priority = UILayoutPriority(rawValue: 999.0)
		
		if let screenWidth = ScenePeeker.shared.rootWindow?.bounds.size.width {
			widthConstraintIdeal = self.widthAnchor.constraint(equalToConstant: screenWidth - 40.0)
			widthConstraintIdeal?.priority = .defaultHigh
			stackWidthConstraintIdeal = stackview.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -28.0)
			stackWidthConstraintIdeal?.priority = .defaultHigh
		} else {
			widthConstraintIdeal = self.widthAnchor.constraint(equalTo: stackview.widthAnchor)
			widthConstraintIdeal?.priority = .defaultHigh
		}
		
		stackWidthConstraintIdeal?.isActive = true
		effectsView.constrainBounds(to: self).activate()
		[
			widthConstraintMin!,
			widthConstraintIdeal!,
			self.heightAnchor.constraint(equalToConstant: buttonSize + 16.0),
			stackview.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			stackview.centerYAnchor.constraint(equalTo: self.centerYAnchor),
		].activate()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Adjusting nav items
	
	fileprivate func updateButtonBar(_ items: [NavigationItem], animated: Bool = true) {
		// Keep the bar circular with 1 button, but let it expand a little to accomodate 1+
		widthConstraintIdeal?.isActive = items.count > 1
		widthConstraintMin?.isActive = items.count == 1
		stackWidthConstraintIdeal?.isActive = widthConstraintIdeal?.isActive ?? false
		
		self.navigationButtons.forEach({ navButton in
			navButton.isHidden = items.contains(navButton.navigationItem) ? false : true
		})
		if animated {
			UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.7, options: [.beginFromCurrentState]) {
				self.navigationButtons.forEach({ navButton in
					navButton.alpha = items.contains(navButton.navigationItem) ? 1.0 : 0.0
				})
				self.layoutIfNeeded()
			}
		} else {
			self.navigationButtons.forEach({ navButton in
				navButton.alpha = items.contains(navButton.navigationItem) ? 1.0 : 0.0
			})
			self.layoutIfNeeded()
		}
	}
	
	fileprivate func register(_ buttons: [NavigationButton]) {
		
		buttons.forEach({ button in
			button.alpha = 0.0
			button.isHidden = true
			button.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				button.widthAnchor.constraint(equalToConstant: buttonSize),
				button.heightAnchor.constraint(equalToConstant: buttonSize)
			])
			stackview.addArrangedSubview(button)
		})
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
		
		static let done = UIImage(systemName: "checkmark.circle.fill")?
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
