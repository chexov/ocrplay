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

func pixelData(image: NSImage) -> [UInt8]? {
    let dataSize = image.size.width * image.size.height * 4
    var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let context = CGContext(data: &pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(image.size.width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    
    var imageRect:CGRect = CGRect(origin: CGPoint(x:0, y:0), size: NSSize(width: (image.size.width), height: (image.size.height)))
    
    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    context?.draw(cgImage!, in: imageRect)
    return pixelData
}

func rgbToGray(image: NSImage) -> NSImage {
    var pixels = pixelData(image: image)
    
    let height = Int(image.size.height)
    let width = Int(image.size.width)
    let channel = 1
    let numBytes = height * width * channel
    var graypixels = [UInt8]()

    var idx = 0
    for h in 0..<height {
        for w in 0..<width {
            let r = pixels![idx]
            idx = idx + 1
            let g = pixels![idx]
            idx = idx + 1
            let b = pixels![idx]
            idx = idx + 1
            let a = pixels![idx]
            idx = idx + 1
            
            let r_modified = 0.2126 * Double(r) / 255
            let g_modified = 0.7152 * Double(g) / 255
            let b_modified = 0.0722 * Double(b) / 255
            var c_linear = r_modified + g_modified  + b_modified

            if (c_linear <= 0.0031308) {
                c_linear = 12.92 * c_linear
            } else {
                c_linear = pow(1.055 * c_linear, 1.0 / 2.4) - 0.055
            }

            graypixels.append(UInt8(c_linear * 255))
        }
    }
    
    var colorspace = CGColorSpaceCreateDeviceGray()
    if (channel == 3) {
        colorspace = CGColorSpaceCreateDeviceRGB()
    }
    
    let grayData = CFDataCreate(nil, graypixels, numBytes)!
    let provider = CGDataProvider(data: grayData)!
    let rgbImageRef = CGImage(width: width,
                              height: height,
                              bitsPerComponent: 8,
                              bitsPerPixel: 8 * channel,
                              bytesPerRow: width * channel,
                              space: colorspace,
                              bitmapInfo: CGBitmapInfo(rawValue: 0),
                              provider: provider,
                              decode: nil,
                              shouldInterpolate: false,
                              intent: CGColorRenderingIntent.defaultIntent)!
    let outputImage = NSImage(cgImage: rgbImageRef, size: NSSize(width: width, height: height))

    return outputImage
}
