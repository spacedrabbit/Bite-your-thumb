//
//  FoaasPreviewView.swift
//  BYT
//
//  Created by Louis Tur on 1/24/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit
import Kingfisher
import Combine

class EditBiteView: UIButton {
	
	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				UIView.animate(withDuration: 0.20, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut]) {
					self.contentView.transform = CGAffineTransform.identity.concatenating(.init(scaleX: 0.93, y: 0.93))
				}
			} else {
				UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut]) {
					self.contentView.transform = CGAffineTransform.identity
				}
			}
		}
	}
	
	private var contentView: UIView = {
		let view = UIView()
		view.clipsToBounds = true
		view.layer.cornerRadius = 16.0
		
		view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 16.0).cgPath
		view.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
		view.layer.shadowRadius = 6.0
		view.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
		view.isUserInteractionEnabled = false
		
		return view
	}()
	
	private let backgroundImage: ImageView = {
		let imageView = ImageView(frame: .zero)
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	private var previewLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.Roboto.light(size: 24.0)
		label.textColor = .white
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	private var previewTextView: UITextView = {
		let textView: UITextView = UITextView()
		textView.font = UIFont.Roboto.light(size: 24.0)
		textView.textColor = .white
		textView.isEditable = false
		textView.isScrollEnabled = false
		textView.backgroundColor = .clear
		
		return textView
	}()
	
	let foaasSubject: CurrentValueSubject<Foaas, Never> = CurrentValueSubject(Foaas(message: "", subtitle: ""))
	let imageSubject: CurrentValueSubject<UpsplashImage?, Never> = CurrentValueSubject(nil)
	
	private var bag: Set<AnyCancellable> = []
	
	init() {
		super.init(frame: .zero)
		
		self.addSubview(contentView)
		contentView.addSubview(backgroundImage)
		contentView.addSubview(previewTextView)
		
		configureConstraints()
		
		foaasSubject
			.dropFirst(1)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { new in
				self.previewTextView.text = new.description
				self.layoutIfNeeded()
			}).store(in: &bag)
		
		imageSubject
			.dropFirst(1)
			.compactMap({ $0 })
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { new in
				self.backgroundImage.setImage(with: new.urls.regular)
			})
			.store(in: &bag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureConstraints() {
		stripAutoResizingMasks([self, contentView, backgroundImage, previewTextView])
		previewTextView.setContentHuggingPriority(UILayoutPriority(991.0), for: .vertical)
		
		backgroundImage.constrainBounds(to: contentView).activate()
		[
			contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
			contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),
			contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
			contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0),
			
			previewTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0),
			previewTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0),
			previewTextView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, constant: -20.0),
			previewTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			
//			previewTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0),
//			previewTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0),
//			previewTextView.heightAnchor.constraint(equalToConstant: 400.0).withPriority(UILayoutPriority(990.0))
		].activate()
	}
}

/*
 import UIKit
 import Foundation
 
 for later

 class ViewController: UIViewController, UITextViewDelegate {

	 override func viewDidLoad() {
		 super.viewDidLoad()
		 
		 let textView = UITextView(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 400))
		 textView.delegate = self
		 view.addSubview(textView)
		 
		 // Ensure the text view looks like a label
		 textView.isEditable = false
		 textView.isScrollEnabled = false
		 textView.backgroundColor = .clear
		 
		 // Create the attributed string
		 let attributedString = NSMutableAttributedString(string: "Here is a link to OpenAI's website.")
		 
		 // Add attributes for the hyperlink
		 if let url = URL(string: "https://www.openai.com") {
			 attributedString.setAttributes([.link: url], range: NSRange(location: 17, length: 4))
		 }
		 
		 textView.attributedText = attributedString
		 
		 // Optional: Disable text selection
		 textView.isUserInteractionEnabled = true
		 textView.isSelectable = true
	 }
	 
	 // UITextViewDelegate method to handle hyperlink taps
	 func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		 UIApplication.shared.open(URL)
		 return false
	 }
 }

 */


protocol FoaasPrevewViewDelegate {
	func backButtonPressed()
	func doneButtonPressed()
	func tapGestureDismissKeyboard(_ sender: UITapGestureRecognizer)
}

class FoaasPreviewView: UIView, UIGestureRecognizerDelegate {
	internal private(set) var slidingTextFields: [FoaasTextField] = []
	
	internal var delegate: FoaasPrevewViewDelegate?
	
	private var scrollviewBottomConstraint: NSLayoutConstraint? = nil
	
	private var previewTextViewHeightConstraint: NSLayoutConstraint? = nil
	private var slidingTextFieldBottomConstraint: NSLayoutConstraint? = nil
	private var newTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
	
	
	// -------------------------------------
	// MARK: Initializer
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViewHierarchy()
		configureConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
	// -------------------------------------
	// MARK: - Config
	private func configureConstraints() {
		stripAutoResizingMasks(self, scrollView, contentContainerView, previewTextView/*, previewLabel*/, backButton, doneButton)
		
		// the previewTextViewHeightConstraint changes with the length of the foaas operation preview text
		previewTextViewHeightConstraint = previewTextView.heightAnchor.constraint(equalToConstant: 0.0)
		
		[// scroll view
			scrollView.topAnchor.constraint(equalTo: self.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0),
			
			// container view
			contentContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -72),
			contentContainerView.widthAnchor.constraint(equalTo: self.widthAnchor),
			
			// preview text view
			previewTextView.topAnchor.constraint(equalTo: self.contentContainerView.topAnchor, constant: 24.0),
			previewTextView.leadingAnchor.constraint(equalTo: self.contentContainerView.leadingAnchor, constant: 16.0),
			previewTextView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -32.0),
			previewTextViewHeightConstraint!,
		].activate()
	}
	
	private func setupViewHierarchy() {
		self.backgroundColor = .white
		self.scrollView.backgroundColor = ColorManager.shared.currentColorScheme.primary
		self.previewTextView.backgroundColor = ColorManager.shared.currentColorScheme.primary
		
		self.addSubview(scrollView)
		scrollView.addSubview(contentContainerView)
		scrollView.addSubviews([backButton, doneButton])
		
		contentContainerView.addSubview(previewTextView)
		scrollView.accessibilityIdentifier = "ScrollView"
		contentContainerView.accessibilityIdentifier = "ContentContainerView"
		previewTextView.accessibilityIdentifier = "PreviewTextView"
	}
	
	
	// -------------------------------------
	// MARK: - FoaasTextFields
	
	/// Creates the same number of `FoaasTextFields` as the `.count` of the `keys` parameter. Each `FoaasTextField` is given
	/// an identifier `String` with the same value as the key at that index. Each `FoaasTextField` created is added to the
	/// `contentContainerView` and given constraints.
	/// - Parameters:
	///   - keys: The keys to be used to generate `FoaasTextField`
	internal func createTextFields(for keys: [String]) {
		for key in keys {
			let newSlidingTextField = FoaasTextField(placeHolderText: key.uppercased())
			newSlidingTextField.textLabel.alpha = 0.34
			newSlidingTextField.identifier = key // used to later identify the textfields if needed
			
			slidingTextFields.append(newSlidingTextField)
			self.contentContainerView.addSubview(newSlidingTextField)
		}
		arrangeSlidingTextFields()
	}
	
	/// This dynamically lays out as many `FoaasTextField` as needed, based on the contents of `self.slidingTextFields`
	private func arrangeSlidingTextFields() {
		guard self.slidingTextFields.count != 0 else { return }
		
		var priorTextField: FoaasTextField?
		for (idx, textField) in slidingTextFields.enumerated() {
			
			switch idx {
				// first view needs to be pinned to preview view
			case 0:
				textField.topAnchor.constraint(equalTo: previewTextView.bottomAnchor, constant: 8.0).isActive = true
				textField.leadingAnchor.constraint(equalTo: previewTextView.leadingAnchor).isActive = true
				textField.widthAnchor.constraint(equalTo: previewTextView.widthAnchor).isActive = true
				if slidingTextFields.count == 1 {
					// if there is only 1 textfield, we need to fallthrough to the "last" textfield case
					fallthrough
				}
				
				// last view needs to be pinned to the bottom, in addition to all of the other constraints
			case slidingTextFields.count - 1:
				textField.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -16.0).isActive = true
				if slidingTextFields.count > 1 {
					// we only have to fallthrough for more constraints if this is textField #1 or greater AND it's the last one
					fallthrough
				}
				
				// middle views need to be pinned to prior view
			default:
				textField.topAnchor.constraint(equalTo: priorTextField!.bottomAnchor, constant: 8.0).isActive = true
				textField.leadingAnchor.constraint(equalTo: priorTextField!.leadingAnchor).isActive = true
				textField.widthAnchor.constraint(equalTo: priorTextField!.widthAnchor).isActive = true
				
			}
			priorTextField = textField
		}
	}
	
	internal func setTextFieldsDelegate(_ delegate: FoaasTextFieldDelegate) {
		slidingTextFields.forEach { (textField) in
			textField.foaasTextFieldDelegate = delegate
		}
	}
	
	
	// MARK: - Updating Text
	internal func updateLabel(text: String) {
		DispatchQueue.main.async {
			self.previewTextView.text = text
			self.updateTextViewdHeight(animated: true)
		}
	}
	
	internal func updateAttributedText(text: NSMutableAttributedString) {
		DispatchQueue.main.async {
			self.previewTextView.attributedText = text
			self.updateTextViewdHeight(animated: true)
		}
	}
	
	/// See https://medium.com/@louistur/dynamic-sizing-of-uitextview-with-autolayout-6dbcfa8e5e2d#.rhnheioqn for details
	private func updateTextViewdHeight(animated: Bool) {
		let textContainterInsets = self.previewTextView.textContainerInset
		let textContainer = self.previewTextView.textContainer
		
		// ensureLayout must be called for the bounding rect of attributed text to be properly accounted for
		self.previewTextView.layoutManager.ensureLayout(for: textContainer)
		let usedRect = self.previewTextView.layoutManager.usedRect(for: textContainer)
		
		self.previewTextViewHeightConstraint?.constant = usedRect.height + textContainterInsets.top + textContainterInsets.bottom
		
		if !animated { return }
		UIView.animate(withDuration: 0.2, animations: {
			self.layoutIfNeeded()
		})
	}
	
	func tapGestureDismissKeyboard(_ sender: UITapGestureRecognizer) {
		self.delegate?.tapGestureDismissKeyboard(sender)
	}
	
	
	// MARK: - Lazy Inits
	internal lazy var previewTextView: UITextView = {
		let textView: UITextView = UITextView()
		
		//updating font and color according to PM notes
		textView.font = UIFont.Roboto.light(size: 24.0)
		textView.textColor = .white
		textView.alpha = 1.0
		
		textView.isEditable = false
		return textView
	}()
	
	internal lazy var scrollView: UIScrollView = {
		let scroll: UIScrollView = UIScrollView()
		scroll.keyboardDismissMode = .none
		scroll.alwaysBounceVertical = true
		return scroll
	}()
	
	internal lazy var contentContainerView: UIView = {
		let view = UIView()
		return view
	}()
	
	internal lazy var doneButton: UIButton = {
		let button = UIButton(type: .custom)
		button.addTarget(self, action: #selector(doneButtonClicked(sender:)), for: .touchUpInside)
		button.setImage(UIImage(named: "checkmark_symbol")!, for: .normal)
		button.backgroundColor = ColorManager.shared.currentColorScheme.accent
		button.layer.cornerRadius = 26
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOpacity = 0.8
		button.layer.shadowOffset = CGSize(width: 0, height: 5)
		button.layer.shadowRadius = 5
		button.clipsToBounds = false
		return button
	}()
	
	internal lazy var backButton: UIButton = {
		let button = UIButton(type: .custom)
		button.addTarget(self, action: #selector(backButtonClicked(sender:)), for: .touchUpInside)
		button.setImage(UIImage(named: "arrow_symbol")!, for: .normal)
		button.backgroundColor = ColorManager.shared.currentColorScheme.accent
		button.layer.cornerRadius = 26
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOpacity = 0.8
		button.layer.shadowOffset = CGSize(width: 0, height: 5)
		button.layer.shadowRadius = 5
		button.clipsToBounds = false
		return button
	}()
	
	
	//MARK: Button Actions
	@objc
	internal func backButtonClicked(sender: UIButton) {
		let originalTransform = sender.imageView!.transform
		UIView.animate(withDuration: 0.1, animations: {
			sender.layer.transform = CATransform3DMakeAffineTransform(self.newTransform)
		}, completion: { (complete) in
			sender.layer.transform = CATransform3DMakeAffineTransform(originalTransform)
			self.delegate?.backButtonPressed()
		})
	}
	
	@objc
	internal func doneButtonClicked(sender: UIButton) {
		let originalTransform = sender.imageView!.transform
		
		UIView.animate(withDuration: 0.1, animations: {
			sender.layer.transform = CATransform3DMakeAffineTransform(self.newTransform)
		}, completion: { (complete) in
			sender.layer.transform = CATransform3DMakeAffineTransform(originalTransform)
			self.delegate?.doneButtonPressed()
		})
		
	}
	
}
