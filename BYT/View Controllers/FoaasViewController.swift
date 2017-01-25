//
//  FoaasViewController.swift
//  BYT
//
//  Created by Louis Tur on 1/23/17.
//  Copyright © 2017 AccessLite. All rights reserved.
//

import UIKit

class FoaasViewController: UIViewController, FoaasViewDelegate, FoaasSettingMenuDelegate {
    
    // MARK: - View
    let foaasView: FoaasView = FoaasView(frame: CGRect.zero)
    let foaasSettingsMenuView: FoaasSettingsMenuView = FoaasSettingsMenuView(frame: CGRect.zero)
    
    // MARK: - Models
    var foaas: Foaas?
    var colorScheme = [ColorScheme]()
    var versions = [Version]()
    var message = ""
    var subtitle = ""
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForNotifications()
        self.foaasView.delegate = self
        self.foaasSettingsMenuView.delegate = self
        
        setupViewHierarchy()
        configureConstraints()
        addGesturesAndActions()
        registerForNotifications()
        
        makeRequest()
    }
    
    // MARK: - Setup
    private func configureConstraints() {
        self.foaasSettingsMenuView.translatesAutoresizingMaskIntoConstraints = false
        let _ = [
            // foaasSettingMenuView
            foaasSettingsMenuView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 100),
            foaasSettingsMenuView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            foaasSettingsMenuView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            foaasSettingsMenuView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.333),
            
            // foaasView
            foaasView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            foaasView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
//            foaasView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            foaasView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            foaasView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            foaasView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ].map{ $0.isActive = true }
    }
    
    private func setupViewHierarchy() {
        self.view.backgroundColor = .white
        self.view.addSubview(foaasSettingsMenuView)
        self.view.addSubview(foaasView)
    }
    
    private func addGesturesAndActions() {
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(toggleMenu(sender:)))
        swipeUpGesture.direction = .up
        foaasView.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(toggleMenu(sender:)))
        swipeDownGesture.direction = .down
        foaasView.addGestureRecognizer(swipeDownGesture)
    }
    
    
    // MARK: - Notifications
    private func registerForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateFoaas(sender:)), name: Notification.Name(rawValue: "FoaasObjectDidUpdate"), object: nil)
    }
    
    internal func updateFoaas(sender: Any) {
        // TODO
    }
    
    
    // MARK: - Updating Foaas
    // TODO: replace this
    internal func makeRequest() {
        
        FoaasDataManager.shared.requestFoaas(url: FoaasDataManager.foaasURL!) { (foaas: Foaas?) in
            if let validFoaas = foaas {
                self.foaas = validFoaas
                var message = validFoaas.message
                var subtitle = validFoaas.subtitle
                
                if self.filterIsOn {
                    message = FoulLanguageFilter.filterFoulLanguage(text: message)
                    subtitle = FoulLanguageFilter.filterFoulLanguage(text: subtitle)
                }
                
                DispatchQueue.main.async {
                    self.foaasView.mainTextLabel.text = message
                    self.foaasView.subtitleTextLabel.text = subtitle
                }
            }
            FoaasDataManager.shared.requestColorSchemeData(endpoint: FoaasAPIManager.colorSchemeURL) { (data: Data?) in
                guard let validData = data else { return }
                guard let colorScheme = ColorScheme.parseColorSchemes(from: validData) else { return }
                DispatchQueue.main.async {
                    self.colorScheme = colorScheme
                    self.foaasSettingsMenuView.view1.backgroundColor = colorScheme[0].primary
                    self.foaasSettingsMenuView.view2.backgroundColor = colorScheme[1].primary
                    self.foaasSettingsMenuView.view3.backgroundColor = colorScheme[2].primary
                }
            }
            
            FoaasDataManager.shared.requestVersionData(endpoint: FoaasAPIManager.versionURL) { (data: Data?) in
                guard let validData = data else { return }
                guard let version = Version.parseVersion(from: validData) else { return }
                DispatchQueue.main.async {
                    self.versions = version
                }
            }
        }
    }
    
    
    // MARK: - View Delegate
    func didTapActionButton() {
        guard let navVC = self.navigationController else { return }
        
        let dtvc = FoaasOperationsTableViewController()
        navVC.pushViewController(dtvc, animated: true)
    }
    
    
    // MARK: - Animating Menu
    internal func toggleMenu(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.up:
            print("UP")
            animateMenu(show: true, duration: 0.35, dampening: 0.7, springVelocity: 0.6)
            
        case UISwipeGestureRecognizerDirection.down:
            print("DOWN")
            animateMenu(show: false, duration: 0.1)
            
        default: print("Not interested")
        }
    }
    
    private func animateMenu(show: Bool, duration: TimeInterval, dampening: CGFloat = 0.005, springVelocity: CGFloat = 0.005) {
        // ignore toggle request if already in proper position
        switch show {
        case true:
            if self.foaasView.frame.origin.y == 0 {
                
                // you want to "show" the settings menu AND the frame of the foaasView.origin isn't 0
                print("now show settings")
                self.foaasView.removeConstraints(self.foaasView.constraints)
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                    
                    let _ = [
                       
                        
                        // foaasView
                        self.foaasView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -200),
                        self.foaasView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
                        //            foaasView.topAnchor.constraint(equalTo: self.view.topAnchor),
                        //            foaasView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                        self.foaasView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                        self.foaasView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                        ].map{ $0.isActive = true }

                    self.view.layoutIfNeeded()
                }, completion: nil)
                
            }
        case false:
            if self.foaasView.frame.origin.y != 0 {
                print("now go up")

            
            }
        }
        
        let multiplier: CGFloat = show ? -1 : 1
        let originalFrame = self.foaasView.frame
        
        // TODO: Adjust and update this animation
        //    let newFrame = originalFrame.offsetBy(dx: 0.0, dy: self.foaasSettingsView.frame.size.height * multiplier)
        //    UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: dampening, initialSpringVelocity: springVelocity, options: [], animations: {
        //      self.foaasView.frame = newFrame
        //    }, completion: nil)
    }
    
    
    // MARK: - FoaasSettingMenuDelegate Method
    var filterIsOn: Bool {
        get {
            return self.foaasSettingsMenuView.profanitySwitch.isOn
        }
        set (newValue) {
            foaasSettingsMenuView.profanitySwitch.isOn = newValue
        }
    }
    
    func colorSwitcherScrollViewScrolled(color: UIColor) {
        self.foaasView.backgroundColor = color
    }
    
    func profanitfySwitchChanged() {
        print("switch changed")
        
        guard let validFoaas = self.foaas else { return }
        var message = validFoaas.message
        var subtitle = validFoaas.subtitle
        
        if self.filterIsOn {
            message = FoulLanguageFilter.filterFoulLanguage(text: validFoaas.message)
            subtitle = FoulLanguageFilter.filterFoulLanguage(text: validFoaas.subtitle)
        }
        self.foaasView.mainTextLabel.text = message
        self.foaasView.subtitleTextLabel.text = subtitle
    }
    
    func twitterButtonTapped() {
        print("twitter button tapped")
    }
    
    func facebookButtonTapped() {
        print("facebook button tapped")
    }
    
    func camerarollButtonTapped() {
        print("cameraroll button tapped")
        guard let vaidImage = getScreenShotImage(view: self.view) else { return }
        //https://developer.apple.com/reference/uikit/1619125-uiimagewritetosavedphotosalbum
        UIImageWriteToSavedPhotosAlbum(vaidImage, self, #selector(createScreenShotCompletion(image: didFinishSavingWithError: contextInfo:)), nil)
    }
    
    func shareButtonTapped() {
        print("share button tapped")
        guard let validFoaas = self.foaas else { return }
        var arrayToShare: [String] = []
        var message = validFoaas.message
        var subtitle = validFoaas.subtitle
        
        if self.filterIsOn {
            message = FoulLanguageFilter.filterFoulLanguage(text: validFoaas.message)
            subtitle = FoulLanguageFilter.filterFoulLanguage(text: validFoaas.subtitle)
            arrayToShare.append(message)
            arrayToShare.append(subtitle)
        } else {
            arrayToShare.append(message)
            arrayToShare.append(subtitle)
        }
        
        let activityViewController = UIActivityViewController(activityItems: arrayToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func uploadData() {
        self.view.reloadInputViews()
    }
    
    //MARK: - Helper functions
    ///Get current screenshot
    func getScreenShotImage(view: UIView) -> UIImage? {
        //https://developer.apple.com/reference/uikit/1623912-uigraphicsbeginimagecontextwitho
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, view.layer.contentsScale)
        guard let context = UIGraphicsGetCurrentContext() else{
            return nil
        }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    ///Present appropriate Alert by UIAlertViewController, indicating images are successfully saved or not
    ///https://developer.apple.com/reference/uikit/uialertcontroller
    internal func createScreenShotCompletion(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        
        if didFinishSavingWithError != nil {
            print("Error in saving image.")
            let alertController = UIAlertController(title: "Failed to save screenshot to photo library", message: nil , preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertController.addAction(okay)
            // do not dismiss the alert yourself in code this way! add a button and let the user handle it
            present(alertController, animated: true, completion: nil)
        }
        else {
            // this has to be in an else clause. because if error is !nil, you're going to be presenting 2x of these alerts
            print("Image saved.")
            let alertController = UIAlertController(title: "Successfully saved screenshot to photo library", message: nil , preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertController.addAction(okay)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}

class FoulLanguageFilter {
    ///Filter foul language of given text with foulWords in a default foulWordsArray
    static func filterFoulLanguage(text: String) -> String {
        let foulWordsArray = Set(["fuck", "dick", "cock", "crap", "asshole", "pussy", "shit", "vittupää", "motherfuck"])
        var wordsArr = text.components(separatedBy: " ")
        for f in foulWordsArray {
            wordsArr = wordsArr.map { (word) -> String in
                if word.lowercased().hasPrefix(f) || word.lowercased().hasSuffix(f) {
                    return multateFoulLanguage(word: word)
                } else {
                    return word
                }
            }
        }
        let string = wordsArr.joined(separator: " ")
        return string
    }
    
    ///Replaces word's first vowel into *
    static func multateFoulLanguage(word: String) -> String {
        let vowels = Set(["a","e","i","o","u"])
        for c in word.lowercased().characters {
            if vowels.contains(String(c)) {
                if word.lowercased().hasPrefix("motherfuck") {
                    return word.replacingOccurrences(of: "u", with: "*")
                }
                return word.replacingOccurrences(of: String(c), with: "*")
            }
        }
        return word
    }
}
