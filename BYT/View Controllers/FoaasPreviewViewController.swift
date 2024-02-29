
//
//  FoaasPreviewViewController.swift
//  BYT
//
//  Created by Louis Tur on 1/23/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit
import Combine

class CreateBiteViewController: UIViewController, FoaasViewController {
	var navigationItems: [NavigationItem] = [.profanity, .done]
	
	private let op: FoaasOperation
	private let builder: FoaasPathBuilder
	
	private let foaasSubject: PassthroughSubject<Foaas, Never> = PassthroughSubject()
	private let imageSubject: PassthroughSubject<UpsplashImage, Never> = PassthroughSubject()

	private let preview = EditBiteView()
	private let blurHashBackground = UIImageView()
	
	private var bag: Set<AnyCancellable> = []
	
	init(operation: FoaasOperation) {
		self.op = operation
		self.builder = FoaasPathBuilder(operation: op)
		super.init(nibName: nil, bundle: nil)
		
		let keyboardShowPublisher = NotificationCenter.default
			.publisher(for: UIResponder.keyboardWillShowNotification)
		let keyboardHidePublisher = NotificationCenter.default
			.publisher(for: UIResponder.keyboardWillHideNotification)
		
		keyboardShowPublisher
			.receive(on: DispatchQueue.main)
			.compactMap(KeyboardNotificationContext.init(notification:))
			.sink(receiveValue: handleKeyboardEvent)
			.store(in: &bag)
		
		keyboardHidePublisher
			.receive(on: DispatchQueue.main)
			.compactMap(KeyboardNotificationContext.init(notification:))
			.sink(receiveValue: handleKeyboardEvent)
			.store(in: &bag)
		
		foaasSubject
			.combineLatest(imageSubject)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] (foaas, image) in
				self?.preview.foaasSubject.send(foaas)
				self?.preview.imageSubject.send(image)
			}.store(in: &bag)
		
		self.blurHashBackground.alpha = 0.0
		imageSubject
			.receive(on: DispatchQueue.main)
			.sink { [weak self] image in
				self?.blurHashBackground.image = UIImage(blurHash: image.blurHash, size: CGSize(width: 50, height: 125))
				UIView.animate(withDuration: 0.25) {
					self?.blurHashBackground.alpha = 1.0
				}
			}.store(in: &bag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(blurHashBackground)
		self.view.addSubview(preview)
		configureConstraints()
		reload()
	}
	
	// MARK: - Keyboard
	
	private func handleKeyboardEvent(_ ctx: KeyboardNotificationContext) {
		if ctx.state.isPresenting {
			print("Keyboard is presenting: \(ctx.state)")
		} else {
			print("Keyboard is dismissing: \(ctx.state)")
		}
	}
	
	// MARK: - Reload
	
	private func reload() {
		Task {
			async let foaas = FoaasService.getFoaas(from: self.builder.buildPath())
			async let image = ImageDataManager.getRandomImage()
			
			do {
				let result = (try await foaas, await image)
				self.foaasSubject.send(result.0)
				if let image = result.1 {
					self.imageSubject.send(image)
				}
				
			} catch {
				print("Error occurred: \(error)")
			}
		}
	}
	
	
	
	// MARK: - Layout
	
	private func configureConstraints() {
		stripAutoResizingMasks([preview, blurHashBackground])
		blurHashBackground.constrainBounds(to: self.view).activate()
		
		let layoutGuide = UILayoutGuide()
		self.view.addLayoutGuide(layoutGuide)
		
		[
			layoutGuide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			layoutGuide.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, constant: -foaasNavigationBar.h),
			layoutGuide.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			layoutGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor),
			
			preview.heightAnchor.constraint(equalTo: layoutGuide.heightAnchor).withPriority(.defaultHigh),
			preview.heightAnchor.constraint(lessThanOrEqualTo: layoutGuide.heightAnchor),
			preview.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor),
			preview.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
			preview.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
		].activate()
	}
	
}

/*

class FoaasPreviewViewController: UIViewController, FoaasViewController {
	var navigationItems: [NavigationItem] = [.profanity, .done]
	
	internal private(set) var operation: FoaasOperation?
	private var pathBuilder: FoaasPathBuilder?
	private let foaas: Foaas = Foaas(message: "", subtitle: "")
	
	var previewText: NSString = ""
	var previewAttributedText: NSAttributedString = NSAttributedString()
	
	var tapGestureRecognizer: UITapGestureRecognizer!
	var bottomConstraint: NSLayoutConstraint? = nil
	
	convenience init(operation: FoaasOperation) {
		self.init(nibName: nil, bundle: nil)
		self.operation = operation
		self.pathBuilder = FoaasPathBuilder(operation: operation)
	}
	
	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupViewHierarchy()
		self.configureConstraints()
		
		self.foaasPreviewView.createTextFields(for: self.pathBuilder!.allKeys())
		self.foaasPreviewView.setTextFieldsDelegate(self)
		self.foaasPreviewView.delegate = self
	}
	
	
	// MARK: - View Setup
	internal func setupViewHierarchy() {
		self.view.addSubview(foaasPreviewView)
		
		let rightSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(backButtonPressed))
		rightSwipe.direction = .right
		self.view.addGestureRecognizer(rightSwipe)
		
		//Add tapGestureRecognizer to view
		tapGestureRecognizer = UITapGestureRecognizer(target: self.foaasPreviewView, action: #selector(tapGestureDismissKeyboard(_:)))
		self.view.isUserInteractionEnabled = true
		self.foaasPreviewView.isUserInteractionEnabled = true
		tapGestureRecognizer.cancelsTouchesInView = false
		tapGestureRecognizer.numberOfTapsRequired = 1
		tapGestureRecognizer.numberOfTouchesRequired = 1
		tapGestureRecognizer.delegate = self.foaasPreviewView
		self.foaasPreviewView.addGestureRecognizer(tapGestureRecognizer)
	}
	
	internal func configureConstraints() {
		self.edgesForExtendedLayout = []
		
		bottomConstraint = foaasPreviewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0)
		let _ = [
			foaasPreviewView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
			foaasPreviewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0),
			foaasPreviewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
			bottomConstraint!,
		].map { $0.isActive = true }
	}
	
	
	// -------------------------------------
	// MARK: - FoaasButtonDelegateMethods
	
	@objc
	internal func backButtonPressed() {
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	@objc
	internal func doneButtonPressed() {
		guard let validPath = self.pathBuilder else { return }
		if !validPath.entryIsValid() {
			let alertController = UIAlertController(title: "Oops!", message: "Please fill out all fields", preferredStyle: .alert)
			let okayAlertAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
			alertController.addAction(okayAlertAction)
			self.present(alertController, animated: true, completion: nil)
		} else {
			let messageAndSubtitle = self.foaasPreviewView.previewTextView.text.components(separatedBy: "\n")
			let notificationCenter = NotificationCenter.default
			notificationCenter.post(name: Notification.Name(rawValue: "FoaasObjectDidUpdate"), object: Foaas(message: messageAndSubtitle[0], subtitle: messageAndSubtitle[1..<messageAndSubtitle.count].joined(separator: "\n")))
			_ = navigationController?.popToRootViewController(animated: true)
		}
	}
	
	// MARK: - Other
	internal func set(operation: FoaasOperation?) {
		guard let validOp = operation else { return }
		
		self.operation = validOp
		self.pathBuilder = FoaasPathBuilder(operation: validOp)
		
		Task { await self.request(operation: validOp) } 
	}
	
	internal func request(operation: FoaasOperation) async {
		guard
			let validPathBulder = self.pathBuilder,
			let url = URL(string: validPathBulder.build()),
			let foaas = try? await FoaasService.getFoass(url: url)
		else { return }
		
		self.foaas = foaas
		let message = self.foaas.message.filterBadLanguage()
		let subtitle = self.foaas.subtitle.filterBadLanguage()
		DispatchQueue.main.async {
			
			let attributedString = NSMutableAttributedString(string: message,
															 attributes: [.foregroundColor : UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0),
																		  .font : UIFont.Roboto.light(size: 24.0)! ])
			let fromAttribute = NSMutableAttributedString(string: "\n\n" + "From,\n" + subtitle,
														  attributes: [ .foregroundColor : UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0),
																		.font : UIFont.Roboto.light(size: 24.0)!])
			
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .right
			
			let textLength = fromAttribute.string.count
			let range = NSRange(location: 0, length: textLength)
			
			fromAttribute.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
			attributedString.append(fromAttribute)
			
			self.foaasPreviewView.updateAttributedText(text: attributedString)
			self.previewText = attributedString.mutableString
			self.previewAttributedText = attributedString
			
			if let validFoaasPath = self.pathBuilder {
				let keys = validFoaasPath.allKeys()
				for key in keys {
					let range = self.previewText.range(of: key)
					let attributedStringToReplace = NSMutableAttributedString(string: validFoaasPath.operationFields[key]! ,
																			  attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,
																						   .foregroundColor : ColorManager.shared.currentColorScheme.accent,
																						   .font : UIFont.Roboto.light(size: 24.0)!])
					
					let attributedTextWithGreenFields = NSMutableAttributedString.init(attributedString: self.previewAttributedText)
					attributedTextWithGreenFields.replaceCharacters(in: range, with: attributedStringToReplace)
					
					self.foaasPreviewView.updateAttributedText(text: attributedTextWithGreenFields)
					self.previewAttributedText = attributedTextWithGreenFields
				}
			}
		}
	}
	
	
	// MARK: - UITextField Delegate
	func foaasTextField(_ textField: FoaasTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		guard let validFoaasPath = self.pathBuilder else { return false }
		guard var validText = textField.textField.text else { return false }
		if textField.textField.text == "" {
			validText = " "
		}
		let updatedString = (validText as NSString).replacingCharacters(in: range, with: string)
		validFoaasPath.update(key: textField.identifier, value: updatedString)
		
		updateAttributedTextInput()
		return true
	}
	
	func foaasTextFieldShouldReturn(_ textField: FoaasTextField) -> Bool {
		self.view.endEditing(true)
		return true
	}
	
	func foaasTextFieldDidEndEditing(_ textField: FoaasTextField) {
		self.view.endEditing(true)
	}
	
	
	// MARK: - TapGestureRecognizer Function
	
	@objc
	func tapGestureDismissKeyboard(_ sender: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	
	
	// -------------------------------------
	// MARK: - Keyboard Notification
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc
	internal func keyboardDidAppear(notification: Notification) {
		self.shouldShowKeyboard(show: true, notification: notification, completion: nil)
	}
	
	@objc
	internal func keyboardWillDisappear(notification: Notification) {
		self.shouldShowKeyboard(show: false, notification: notification, completion: nil)
	}
	
	private func shouldShowKeyboard(show: Bool, notification: Notification, completion: ((Bool) -> Void)? ) {
		if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
		   let animationNumber = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
		   let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
			let animationOption = UIView.AnimationOptions(rawValue: animationNumber.uintValue)
			
			bottomConstraint?.constant = keyboardFrame.size.height * (show ? -1 : 1)
			UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOption, animations: {
				self.view.layoutIfNeeded()
			}, completion: completion)
		}
	}
	
	func updateAttributedTextInput() {
		if let validFoaasPath = self.pathBuilder {
			let attributedText = NSMutableAttributedString.init(attributedString: self.previewAttributedText)
			let keys = validFoaasPath.allKeys()
			for key in keys {
				let string = attributedText.string as NSString
				let rangeOfWord = string.range(of: key)
				
				let attrib: [NSAttributedString.Key : Any] =  [.underlineStyle: NSUnderlineStyle.single.rawValue,
															   .foregroundColor : ColorManager.shared.currentColorScheme.accent,
															   .font : UIFont.Roboto.light(size: 24.0)!]
				let attributedStringToReplace = NSMutableAttributedString(string: validFoaasPath.operationFields[key]!, attributes: attrib)
				attributedText.replaceCharacters(in: rangeOfWord, with: attributedStringToReplace)
			}
			self.foaasPreviewView.updateAttributedText(text: attributedText)
		}
	}
	
	// -------------------------------------
	// MARK: - Lazy Inits
	internal lazy var foaasPreviewView: FoaasPreviewView = {
		let previewView = FoaasPreviewView()
		return previewView
	}()
}
*/
