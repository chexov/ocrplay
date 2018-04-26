//
//  ImageUtils.swift
//  test
//
//  Created by Aleksey Sevruk on 4/26/18.
//  Copyright © 2018 Anton Linevych. All rights reserved.
//

import Foundation
import Vision
import CoreML
import CoreImage
import Foundation
import CoreML
import Cocoa
import AppKit

func resizeImage(image: NSImage, width: CGFloat, height: CGFloat) -> NSImage {
    let img = NSImage(size: NSSize(width: width, height: height))
    
    img.lockFocus()
    let ctx = NSGraphicsContext.current
    ctx?.imageInterpolation = .high
    image.draw(in: NSMakeRect(0, 0, width, height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.copy, fraction: 1)
    
    img.unlockFocus()
    
    return img
}

func saveAsPNG(url: URL, image: NSImage) -> Bool {
    guard let tiffData = image.tiffRepresentation else {
        print("failed to get tiffRepresentation. url: \(url)")
        return false
    }
    let imageRep = NSBitmapImageRep(data: tiffData)
    guard let imageData = imageRep?.representation(using: .png, properties: [:]) else {
        print("failed to get PNG representation. url: \(url)")
        return false
    }
    do {
        try imageData.write(to: url)
        return true
    } catch {
        print("failed to write to disk. url: \(url)")
        return false
    }
}
