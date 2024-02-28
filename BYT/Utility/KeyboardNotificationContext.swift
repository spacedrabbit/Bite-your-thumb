//
//  KeyboardNotificationContext.swift
//  BYT
//
//  Created by Louis Tur on 2/28/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import Foundation
import UIKit

fileprivate let willShowNotification = UIResponder.keyboardWillShowNotification
fileprivate let didShowNotification = UIResponder.keyboardDidShowNotification
fileprivate let willHideNotification = UIResponder.keyboardWillHideNotification
fileprivate let didHideNotification = UIResponder.keyboardDidHideNotification

fileprivate let willShowKey = willShowNotification.rawValue
fileprivate let didShowKey = didShowNotification.rawValue
fileprivate let willHideKey = willHideNotification.rawValue
fileprivate let didHideKey = didHideNotification.rawValue

fileprivate let frameStartKey = UIResponder.keyboardFrameBeginUserInfoKey
fileprivate let frameEndKey = UIResponder.keyboardFrameEndUserInfoKey
fileprivate let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
fileprivate let animationKey = UIResponder.keyboardAnimationCurveUserInfoKey

struct KeyboardNotificationContext {
	
	enum PresentationState {
		case willHide
		case willShow
		case didHide
		case didShow
		
		init?(_ key: String) {
			switch key {
			case willShowKey: self = .willShow
			case didShowKey: self = .didShow
			case willHideKey: self = .willHide
			case didHideKey: self = .didHide
			default: return nil
			}
		}
		
		var isPresenting: Bool {
			switch self {
			case .willShow, .didShow: return true
			case .willHide, .didHide: return false
			}
		}
		
		var isDismissing: Bool { !isPresenting }
	}
	
	let state: PresentationState
	
	let startFrame: CGRect
	let endFrame: CGRect
	
	let animationCurve: UIView.AnimationOptions
	let animationDuration: TimeInterval
	
	static let validNotifications: [Notification.Name] = [
		willShowNotification, didShowNotification, willHideNotification, didHideNotification
	]
	
	init?(notification: Notification) {
		guard
			Self.validNotifications.contains(notification.name),
			let start = notification.userInfo?[frameStartKey] as? CGRect,
			let end = notification.userInfo?[frameEndKey] as? CGRect,
			let animationNumber = notification.userInfo?[animationKey] as? NSNumber,
			let duration = notification.userInfo?[durationKey] as? TimeInterval,
			let _state = PresentationState(notification.name.rawValue)
		else { return nil }
		state = _state
		startFrame = start
		endFrame = end
		animationCurve = UIView.AnimationOptions(rawValue: animationNumber.uintValue)
		animationDuration = duration
	}
	
}
