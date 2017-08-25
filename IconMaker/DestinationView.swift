//
//  DestinationView.swift
//  IconMaker
//
//  Created by Charles Oder on 8/24/17.
//  Copyright © 2017 Charles Oder. All rights reserved.
//

import Cocoa

protocol DestinationViewDelegate {
    func processImageURLs(_ urls: [URL], center: NSPoint)
    func processImage(_ image: NSImage, center: NSPoint)
    func processAction(_ action: String, center: NSPoint)
}

class DestinationView: NSView {
    
    var delegate: DestinationViewDelegate?
    
    let lineWidth: CGFloat = 10.0
    var nonURLTypes: Set<String>  { return [String(kUTTypeTIFF)] }
    var acceptableTypes: Set<String> { return nonURLTypes.union([NSURLPboardType]) }
    let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey:NSImage.imageTypes()]

    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        register(forDraggedTypes: Array(acceptableTypes))
    }
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        } else if let types = pasteBoard.types, nonURLTypes.intersection(types).count > 0 {
            canAccept = true
        }
        
        return canAccept
        
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = lineWidth
            path.stroke()
        }
        
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        let point = convert(draggingInfo.draggingLocation(), from: nil)

        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            delegate?.processImageURLs(urls, center: point)
            return true
        } else if let image = NSImage(pasteboard: pasteBoard) {
            delegate?.processImage(image, center: point)
            return true
        }
        return false
        
    }
    
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }

}
