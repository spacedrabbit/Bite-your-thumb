//
//  FoaasSettingsMenuView.swift
//  BYT-anama118118
//
//  Created by Ana Ma on 1/13/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

protocol FoaasSettingMenuDelegate {
    func colorSwitcherScrollViewScrolled()
    func profanitfySwitchToggled(on: Bool)
    
    func twitterButtonTapped()
    func facebookButtonTapped()
    func camerarollButtonTapped()
    func shareButtonTapped()
    func uploadData()
    func aboutButtonTapped()
}

class FoaasSettingsMenuView: UIView, UIScrollViewDelegate, FoaasColorPickerViewDelegate {
    
    @IBOutlet weak var profanitySwitch: UISwitch!
    @IBOutlet weak var shareImageButton: UIButton!
    @IBOutlet weak var cameraRollButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var versionMessageLabel: UILabel!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var onLabel: UILabel!
    @IBOutlet weak var profanityLabel: UILabel!
    @IBOutlet weak var colorPaletteLabel: UILabel!
    
    internal private(set) var foaasColorPickerView: FoaasColorPickerView?
    
    var delegate : FoaasSettingMenuDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let view = Bundle.main.loadNibNamed("FoaasSettingsMenuView", owner: self, options: nil)?.first as? UIView {
            self.addSubview(view)
            view.frame = self.bounds
            
            setupViewHierarchy()
            configureConstraints()
            updateSwitch()
            updateButtonColors()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateVersionLabels() {
        self.versionNumberLabel.text = "V1.0" // "V\(VersionManager.shared.currentVersion.number)"
        self.versionMessageLabel.text = "Fieldbook is no longer" // "\(VersionManager.shared.currentVersion.message.uppercased())"
    }
    
    private func configureConstraints() {
        foaasColorPickerView?.translatesAutoresizingMaskIntoConstraints = false
        [ foaasColorPickerView!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16.0),
          foaasColorPickerView!.centerYAnchor.constraint(equalTo: self.colorPaletteLabel.centerYAnchor),
          ].activate()
    }
    
    private func setupViewHierarchy() {
        self.versionNumberLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(87.0) // literals. ¯\_(ツ)_/¯
        self.versionMessageLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(87.0)
        
        let colorManagerColors = ColorManager.shared.colorSchemes.map { $0.primary }
        foaasColorPickerView = FoaasColorPickerView(colors: colorManagerColors, baseUnit: 60.0)
        foaasColorPickerView?.delegate = self
        
        self.addSubview(foaasColorPickerView!)
    }
    
    
    // MARK: - Color Picker Functions
    func didChangeColorPickerIndex(to index: Int) {
        // TODO: there should be a funciton to update the color scheme rather that directly assigning it
        //       to the singleton, from the singleton.
        ColorManager.shared.currentColorScheme = ColorManager.shared.colorSchemes[index]
        self.profanitySwitch.tintColor = ColorManager.shared.currentColorScheme.accent
        self.profanitySwitch.onTintColor = ColorManager.shared.currentColorScheme.accent
        self.delegate?.colorSwitcherScrollViewScrolled()
    }
    
    
    // MARK: - Actions
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
        self.delegate?.aboutButtonTapped()
    }
    
    @IBAction func profanitySwitchDidChange(_ sender: UISwitch) {
        self.delegate?.profanitfySwitchToggled(on: sender.isOn)
        print("Profanity Switch Did Change")
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        self.delegate?.shareButtonTapped()
        print("shareButtonTapped")
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        self.delegate?.camerarollButtonTapped()
        print("cameraButtonTapped")
    }
    
    @IBAction func facebookButtonTapped(_ sender: UIButton) {
        self.delegate?.facebookButtonTapped()
        print("facebookButtonTapped")
    }
    
    @IBAction func twitterButtonTapped(_ sender: UIButton) {
        self.delegate?.twitterButtonTapped()
        print("twitterButtonTapped")
    }
    
    //MARK: - Helper Function
    func updateSwitch () {
        self.profanitySwitch.isOn = LanguageFilter.profanityAllowed
        self.profanitySwitch.onTintColor = ColorManager.shared.currentColorScheme.accent
        self.profanitySwitch.tintColor = ColorManager.shared.currentColorScheme.accent
    }
    
    func updateButtonColors() {
        updateButtonIcon(button: facebookButton, imageName: "facebook_icon_inverted")
        updateButtonIcon(button: twitterButton, imageName: "twitter_icon_inverted")
        updateButtonIcon(button: cameraRollButton, imageName: "camera_icon_inverted")
        updateButtonIcon(button: shareImageButton, imageName: "upload_icon_inverted")
    }
    
    func updateButtonIcon(button: UIButton, imageName: String) {
        let image = UIImage(named: imageName)
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = ColorManager.shared.currentColorScheme.accent
    }
    
}


