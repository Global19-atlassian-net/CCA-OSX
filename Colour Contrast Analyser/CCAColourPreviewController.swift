//
//  CCAColourPreviewController.swift
//  Colour Contrast Analyser
//
//  Created by Cédric Trévisan on 08/02/2016.
//  Copyright © 2016 Cédric Trévisan. All rights reserved.
//

import Cocoa

class CCAColourPreviewController: NSView, NSTextFieldDelegate {

    var color: CCAColour!

    @IBOutlet var view: NSView!
    @IBOutlet weak var formatTextField: NSTextField!
    @IBOutlet weak var warning: NSImageView!
    @IBOutlet weak var formatPopup: NSPopUpButton!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    // init for Ibuilder
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "ColourPreviewView"), owner: self, topLevelObjects: nil)
        
        self.formatTextField.delegate = self
        
        // Makes XIB View size same
        self.view.frame = self.bounds
        // add XIB's view to Custom NSView Subclass
        self.addSubview(self.view)
        self.view.wantsLayer = true
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.formatTextField.drawsBackground = true
        
        // these are 10.11-only APIs, but you can use the visual format language or any other autolayout APIs
        self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    @objc func update(_ notification: Notification) {
        self.updateTextField()
        self.updatePreview()
    }
       
    @IBAction func formatPopupChanged(_ sender: Any) {
        let format = self.formatPopup.selectedItem?.title
        if (format == "RGB") {
            self.formatTextField.stringValue = self.color.rgbString
        } else if (format == "HSL") {
            self.formatTextField.stringValue = self.color.hslString
        } else if (format == "Name") {
            self.formatTextField.stringValue = self.color.nameString
        } else {
            self.formatTextField.stringValue = self.color.hexString
        }
    }
    
    func updatePreview() {
        self.view.alphaValue = 1
        self.view.layer?.backgroundColor = self.color.colorWithOpacity.cgColor
    }
    
    func updateTextField() {
        let format = self.formatPopup.selectedItem?.title
        if (format == "HEX") {
            if (self.formatTextField.stringValue.isEmpty) {
                self.formatTextField.stringValue = self.color.hexString
            } else {
                if (!self.color.isHexStringEqual(string: self.formatTextField.stringValue)) {
                    self.formatTextField.stringValue = self.color.hexString
                }
            }
        } else if (format == "RGB") {
            if (self.formatTextField.stringValue.isEmpty) {
                self.formatTextField.stringValue = self.color.rgbString
            } else {
                if (!self.color.isRGBStringEqual(string: self.formatTextField.stringValue)) {
                    self.formatTextField.stringValue = self.color.rgbString
                }
            }
        } else if (format == "HSL") {
            if (self.formatTextField.stringValue.isEmpty) {
                self.formatTextField.stringValue = self.color.hslString
            } else {
                if (!self.color.isHSLStringEqual(string: self.formatTextField.stringValue)) {
                    self.formatTextField.stringValue = self.color.hslString
                }
            }
        } else if (format == "Name") {
            if (self.formatTextField.stringValue.isEmpty) {
                self.formatTextField.stringValue = self.color.nameString
            } else {
                if (!self.color.isNameStringEqual(string: self.formatTextField.stringValue)) {
                    self.formatTextField.stringValue = self.color.nameString
                }
            }
        }

        // Reset Warning status
        self.formatTextField.backgroundColor = NSColor.white
        self.warning.isHidden = true
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        let string = self.formatTextField.stringValue
        if (self.validateColor(self.formatTextField.stringValue)) {
            self.formatTextField.backgroundColor = NSColor.white
            self.warning.isHidden = true
            self.color.update(NSColor(string: string)!)
        } else {
            self.warning.isHidden = false
            self.formatTextField.backgroundColor = NSColor.red
        }
    }

    
    func validateColor(_ value: String) -> Bool {
        let format = self.formatPopup.selectedItem?.title
        if (format == "RGB") {
            return NSColor.isRGB(string: value)
        } else if (format == "HSL") {
            return NSColor.isHSL(string: value)
        } else if (format == "Name") {
            return NSColor.isName(string: value)
        } else {
            return NSColor.isHex(string: value)
        }
    }

}

class CCAForegroundColourPreviewController: CCAColourPreviewController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.color = CCAColourForeground.sharedInstance
        self.updateTextField()
        self.updatePreview()
        NotificationCenter.default.addObserver(self, selector: #selector(CCAColourPreviewController.update(_:)), name: NSNotification.Name(rawValue: "ForegroundColorChangedNotification"), object: nil)
    }
}

class CCABackgroundColourPreviewController: CCAColourPreviewController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.color = CCAColourBackground.sharedInstance
        self.updateTextField()
        self.updatePreview()
        NotificationCenter.default.addObserver(self, selector: #selector(CCAColourPreviewController.update(_:)), name: NSNotification.Name(rawValue: "BackgroundColorChangedNotification"), object: nil)
    }
}
