//
//  ViewController.swift
//  IconMaker
//
//  Created by Charles Oder on 8/24/17.
//  Copyright © 2017 Charles Oder. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    enum Appearance {
        static let maxStickerDimension: CGFloat = 150.0
        static let shadowOpacity: Float =  0.4
        static let shadowOffset: CGFloat = 4
        static let imageCompressionFactor = 1.0
        static let maxRotation: UInt32 = 12
        static let rotationOffset: CGFloat = 6
        static let randomNoise: UInt32 = 200
        static let numStars = 20
        static let maxStarSize: CGFloat = 30
        static let randonStarSizeChange: UInt32 = 25
        static let randomNoiseStar: UInt32 = 100
    }

    @IBOutlet weak var heightField: NSTextField!
    @IBOutlet weak var widthField: NSTextField!
    @IBOutlet weak var destinationField: NSTextField!
    @IBOutlet weak var destinationView: DestinationView!
    @IBOutlet weak var imageView: NSImageView!
    
    var color: NSColor = .black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        destinationView.delegate = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        let path: NSString = destinationField.stringValue as NSString
        let resolvedPath = path.expandingTildeInPath
        let width = widthField.doubleValue
        let height = heightField.doubleValue
        let resizedImage = imageView.image?.resize(toSize: NSSize(width: width, height: height))
        try! resizedImage?.savePngTo(url: URL(fileURLWithPath: resolvedPath))
        
        print("Your image has been saved to \(resolvedPath)")
    }
    
    func setSize(_ size: NSSize) {
        widthField.stringValue = "\(Int(size.width))"
        heightField.stringValue = "\(Int(size.height))"
    }
    
    @IBAction func colorDidChange(_ sender: NSColorWell) {
        color = sender.color
        if let image = imageView.image {
            processImage(image, center: NSPoint.zero)
        }
    }
    

}

extension NSView {
    /**
     Take a snapshot of a current state NSView and return an NSImage
     
     - returns: NSImage representation
     */
    func snapshot() -> NSImage {
        let pdfData = dataWithPDF(inside: bounds)
        let image = NSImage(data: pdfData)
        return image ?? NSImage()
    }
}


extension ViewController: DestinationViewDelegate {
    
    func processImageURLs(_ urls: [URL], center: NSPoint) {
        for (_,url) in urls.enumerated() {
            if let image = NSImage(contentsOf:url) {
                processImage(image, center:center)
            }
        }
    }
    
    func processImage(_ image: NSImage, center: NSPoint) {
        let coloredImage = image
        let tinted = coloredImage.tinted(color: color)
        imageView.image = tinted
        setSize(image.size)
    }
    
    func processAction(_ action: String, center: NSPoint) {
    }

}

extension NSImage {
    func tinted(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        let imageRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        NSColor.white.set()
        NSRectFillUsingOperation(imageRect, .color)
        color.set()
        NSRectFillUsingOperation(imageRect, .color)
        image.unlockFocus()
        return image
    }
}

