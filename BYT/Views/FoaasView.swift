//
//  FoaasView.swift
//  BYT
//
//  Created by Louis Tur on 1/23/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit
import Combine

class FoaasCollectionCell: UICollectionViewCell {
	@Published var foaas: Foaas?
	private var cancellables: Set<AnyCancellable> = []
	
	private var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.Roboto.light(size: 32.0)
		label.textColor = UIColor.white
//		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 0
		
		return label
	}()
	
	private var subtitleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.Roboto.regular(size: 24.0)
		label.textColor = UIColor.white
		label.alpha = 0.7
//		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 0
		return label
	}()
	
	// MARK: - Constructor
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		
		self.contentView.addSubviews([titleLabel, subtitleLabel])
		configureConstraints()
		
		$foaas.sink { foaas in
			guard let foaas else { return }
			self.configure(foaas)
		}.store(in: &cancellables)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func configure(_ foaas: Foaas) {
		self.titleLabel.text = foaas.message
		self.subtitleLabel.text = foaas.subtitle
		
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
	
	private func configureConstraints() {
		stripAutoResizingMasks([titleLabel, subtitleLabel])
		
//		titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//		subtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		
		[
			titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12.0),
			titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12.0),
			titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0),
			
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.0),
			subtitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12.0),
			subtitleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12.0),
		].activate()
		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		configureConstraints()
	}
}
//
//class FoaasView: UIView {
//	@Published var titleText: String?
//	@Published var subtitleText: String?
//
//	var hideHudElements = PassthroughSubject<Bool, Never>()
//
//	var actionButtonPublisher: AnyPublisher<UIButton, Never> {
//		return _actionPassthrough.eraseToAnyPublisher()
//	}
//	private var _actionPassthrough = PassthroughSubject<UIButton, Never>()
//
//	var settingsButtonPublisher: AnyPublisher<UIButton, Never> {
//		return _settingsPassthrough.eraseToAnyPublisher()
//	}
//	private var _settingsPassthrough = PassthroughSubject<UIButton, Never>()
//
//	var subtitleLabelConstraint = CurrentValueSubject<NSLayoutConstraint, Never>(NSLayoutConstraint())
//
//	private var cancellables: Set<AnyCancellable> = []
//
//	// MARK: - Lazy Inits
//	private lazy var resizingView: UIView = {
//		let view: UIView = UIView()
//		view.isAccessibilityElement = false
//		view.backgroundColor = .clear
//		return view
//	}()
//
//
//
////	private lazy var addButton: UIButton = {
////		let button: UIButton = UIButton(type: .custom)
////		button.setImage(UIImage(named: "plus_symbol")!, for: .normal)
////
////		button.backgroundColor = ColorManager.shared.currentColorScheme.accent
////		button.layer.cornerRadius = 26
////		button.layer.shadowColor = UIColor.black.cgColor
////		button.layer.shadowOpacity = 0.8
////		button.layer.shadowOffset = CGSize(width: 0, height: 5)
////		button.layer.shadowRadius = 8
////
////		button.accessibilityLabel = "Add"
////		return button
////	}()
//
////	private lazy var settingsMenuButton: UIButton = {
////		let button = UIButton()
////		button.accessibilityLabel = "Settings"
////		let origImage = UIImage(named: "disclosure_up")
////		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
////		button.setImage(tintedImage, for: .normal)
////		button.tintColor = ColorManager.shared.currentColorScheme.accent
////		return button
////	}()
//
//	// MARK: - Constructor
//
//	override init(frame: CGRect) {
//		super.init(frame: .zero)
//
//		self.contentView.addSubviews([titleLabel, subtitleLabel])
//		configureConstraints()
//
//		$titleText
//			.compactMap({ $0?.filterBadLanguage() })
//			.assign(to: \.text, on: titleLabel)
//			.store(in: &cancellables)
//
//		$subtitleText
//			.compactMap({ $0?.filterBadLanguage() })
//			.assign(to: \.text, on: subtitleLabel)
//			.store(in: &cancellables)
//
//		hideHudElements
//			.sink { [unowned self] hide in
//				self.addButton.isHidden = hide
//				self.settingsMenuButton.isHidden = hide
//			}.store(in: &cancellables)
//
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//	}
//
//	// MARK: - Actions
//
//	@objc
//	private func didTapButton(sender: UIButton) {
//		let newTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//		let originalTransform = sender.imageView!.transform
//
//		UIView.animate(withDuration: 0.1, animations: {
//			sender.layer.transform = CATransform3DMakeAffineTransform(newTransform)
//		}, completion: { (complete) in
//			sender.layer.transform = CATransform3DMakeAffineTransform(originalTransform)
//			self._actionPassthrough.send(sender)
//		})
//
//	}
//
//	@objc
//	private func didTapSettingsButton(sender: UIButton) {
//		self._settingsPassthrough.send(sender)
//	}
//
//
//	// MARK: - Layout
//
//	private func configureConstraints() {
//		stripAutoResizingMasks(self, resizingView, mainTextLabel, subtitleTextLabel , addButton, settingsMenuButton)
//
//		let resizingViewConstraints = [
//			resizingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//			resizingView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//			resizingView.topAnchor.constraint(equalTo: self.topAnchor),
//			resizingView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -48.0)
//		]
//
//		self.subtitleLabelConstraint.value = subtitleTextLabel.leadingAnchor.constraint(greaterThanOrEqualTo: resizingView.leadingAnchor, constant: 16.0)
//
//		let labelConstraints = [
//			mainTextLabel.leadingAnchor.constraint(equalTo: resizingView.leadingAnchor, constant: 16.0),
//			mainTextLabel.topAnchor.constraint(equalTo: resizingView.topAnchor, constant: 16.0),
//			mainTextLabel.trailingAnchor.constraint(equalTo: resizingView.trailingAnchor, constant: -16.0),
//			mainTextLabel.heightAnchor.constraint(equalTo: resizingView.heightAnchor, multiplier: 0.7),
//
//			subtitleLabelConstraint.value,
//			//subtitleTextLabel.leadingAnchor.constraint(equalTo: resizingView.leadingAnchor, constant: 16.0),
//			subtitleTextLabel.trailingAnchor.constraint(equalTo: resizingView.trailingAnchor, constant: -16.0),
//			subtitleTextLabel.topAnchor.constraint(equalTo: self.mainTextLabel.bottomAnchor, constant: 16.0),
//			subtitleTextLabel.bottomAnchor.constraint(equalTo: resizingView.bottomAnchor, constant: -16.0),
//		]
//
//		let buttonConstraints = [
//			addButton.widthAnchor.constraint(equalToConstant: 54.0),
//			addButton.heightAnchor.constraint(equalToConstant: 54.0),
//			addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -48.0),
//			addButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -48.0),
//
//			settingsMenuButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//			settingsMenuButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
//		]
//
//		let _ = [resizingViewConstraints, labelConstraints, buttonConstraints].map{ $0.map{ $0.isActive = true } }
//	}
//
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		self.configureConstraints()
//	}
//
//}
