//
//  FoaasNavigationController.swift
//  BYT
//
//  Created by Louis Tur on 1/23/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit

struct FoaasNavImages {
	static let addButton: UIImage = UIImage(named: "add_button_grayscale")!
	static let backButton: UIImage = UIImage(named: "back_button_grayscale")!
	static let closeButton: UIImage = UIImage(named: "close_button_grayscale")!
	static let doneButton: UIImage = UIImage(named: "done_button_grayscale")!
}

enum FoaasNavType {
	case add, back, close, done, none
}

protocol FoaasNavigationActionDelegate {
	func leftAction()
	func rightAction()
}

protocol FoaasViewController: UIViewController {
	
	var navBar: FoassBottomBar { get }
	
}

extension UIViewController: FoaasViewController {
	
	var navBar: FoassBottomBar {
		return (self.navigationController as? FoaasNavigationController)?.navbar ?? FoassBottomBar()
	}
	
}

// square.and.arrow.up.circle.fill

struct NavigationButton {
	
	static let add: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "plus.circle.fill")?
			.resized(toWidth: 32.0)?.withTintColor(.systemBlue), for: .normal)
		button.contentMode = .scaleAspectFit
		button.imageView?.contentMode = .scaleAspectFit
		return button
	}()
	
	static let back: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "arrow.backward.circle.fill"), for: .normal)
		button.contentMode = .scaleAspectFit
		button.imageView?.contentMode = .scaleAspectFit
		return button
	}()
	
	static let share: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "square.and.arrow.up.circle.fill"), for: .normal)
		button.contentMode = .scaleAspectFit
		button.imageView?.contentMode = .scaleAspectFit
		return button
	}()
	
	static let profanity: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "exclamationmark.bubble.circle.fill"), for: .normal)
		button.contentMode = .scaleAspectFit
		button.imageView?.contentMode = .scaleAspectFit
		return button
	}()
	
}

class FoaasNavigationController: UINavigationController, UINavigationControllerDelegate {
	let navbar: FoassBottomBar = FoassBottomBar(frame: .zero)
	
	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.addSubview(navbar)
		self.delegate = self
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
			
			
//			navbar.frame = CGRect(x: (self.view.w - navbar.w) / 2.0, y: self.view.h - 100.0, width: 200.0, height: 60.0)
		}
		
	}
	
	private func configureConstraints() {
	}
	
	/// Called just before viewWillAppear in order to place the buttons over all other views
	private func bringFloatingButtonsToTop() {

	}
	
	
	// MARK: - Actions
	@objc private func runLeftAction() {

	}
	
	@objc private func runRightAction() {
	}
	
	
	// MARK: - Navigation Changes
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		positionNavbar()
		// TODO: the current implementation works for positioning, but the buttons need actions, methods to update images & actions and shadows
	}
	
	
	// MARK: Lazy Inits
	internal lazy var leftFloatingButton: UIButton = UIButton()
	internal lazy var rightFloatingButton: UIButton =  UIButton()
}

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
		let add = NavigationButton.add
		
		self.clipsToBounds = true
		stackview.addArrangedSubview(add)
		add.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
		
		stackview.translatesAutoresizingMaskIntoConstraints = false
		[
			self.widthAnchor.constraint(greaterThanOrEqualToConstant: 60.0),
			self.widthAnchor.constraint(equalTo: stackview.widthAnchor),
			self.topAnchor.constraint(equalTo: stackview.topAnchor, constant: -8.0),
			self.bottomAnchor.constraint(equalTo: stackview.bottomAnchor,constant: 8.0),
			
			add.widthAnchor.constraint(equalToConstant: buttonSize),
			add.heightAnchor.constraint(equalToConstant: buttonSize),
		].activate()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Adjusting nav items
	
	@objc private func handleAddButton() {
		let new = UIButton()
		new.backgroundColor = .orange
		
		addButton(new)
	}
	
	private func addButton(_ button: UIButton) {
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
	
	private func removeButton(_ button: UIButton) {
		UIView.animate(withDuration: 0.3) {
			self.stackview.removeArrangedSubview(button)
			button.removeFromSuperview()
			self.layoutIfNeeded()
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
