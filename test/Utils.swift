//
//  Utils.swift
//  test
//
//  Created by Aleksey Sevruk on 4/28/18.
//  Copyright © 2018 Anton Linevych. All rights reserved.
//

import Foundation
import Vision
import Cocoa

func debugImage(image: CGImage, results: Array<VNTextObservation>, path: String) {
    let scale: CGFloat = 1
    let bounds = CGRect(x: 0, y: 0, width: image.width, height: image.height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
    let basedir = getBasedir(path: path)
    let basename = getBasename(path: path)
    
    let context = CGContext(
        data: nil,
        width: Int(bounds.width * scale),
        height: Int(bounds.height * scale),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo
        )!
    
    context.draw(image, in: bounds)
    
    context.setStrokeColor(CGColor(colorSpace: colorSpace, components: [0, 0, 1, 1])!)
    context.setFillColor(CGColor(colorSpace: colorSpace, components: [0, 0, 1, 0.42])!)
    context.setLineWidth(4)
    //                    context.rect
    
    for textObservation in results {
        let rect = getRect(textObservation: textObservation, imgWidth: image.width, imgHeight: image.height)
        context.fill(rect)
    }
    
    let debugimage = context.makeImage()
    let newSize = NSSize(width: (debugimage?.width)!, height: (debugimage?.height)!)
    let imageWithNewSize = NSImage(cgImage: debugimage!, size: newSize)
    
//    print(imageWithNewSize)
//    print("GA1")
    let out = URL(fileURLWithPath: basedir + "/" + basename + "-debug" + ".png")
    saveAsPNG(url: out, image: imageWithNewSize)
}

func getBasename(path: String) -> String {
    let arr = path.components(separatedBy: "/")
    let filename = arr[arr.endIndex - 1]
    let basenameArr = filename.components(separatedBy: ".")
    return basenameArr[0]
}

func getBasedir(path: String) -> String {
    var arr = path.components(separatedBy: "/")
    arr.reverse()
    arr.remove(at: 0)
    arr.reverse()
    
    var res = ""
    for item in arr {
        res.append(item)
        res.append("/")
    }
    
    return res
}

func getRect(textObservation: VNTextObservation, imgWidth: Int, imgHeight: Int) -> CGRect {
    let x = textObservation.boundingBox.origin.x * CGFloat(imgWidth)
    let y = textObservation.boundingBox.origin.y * CGFloat(imgHeight)
    let width = textObservation.boundingBox.size.width * CGFloat(imgWidth)
    let height = textObservation.boundingBox.size.height * CGFloat(imgHeight)
    
    var rect = CGRect()
    rect.origin.x = x
    rect.origin.y = y
    rect.size.width = width
    rect.size.height = height
    
    let s = rect.minX.description + " " + rect.minY.description + " " + rect.maxX.description + " " + rect.maxY.description
//    print(s)
    return rect
}
