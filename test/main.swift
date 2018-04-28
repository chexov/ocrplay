//
//  main.swift
//  test
//
//  Created by Anton Linevych on 4/25/18.
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


func drawBbox(textObservation: VNTextObservation, image: CGImage, basename: String, idx: Int) {
    let rect: CGRect = {
        var rect = CGRect()
        rect.origin.x = textObservation.boundingBox.origin.x * CGFloat(image.width)
        rect.origin.y = textObservation.boundingBox.origin.y * CGFloat(image.height)
        rect.size.width = textObservation.boundingBox.size.width * CGFloat(image.width)
        rect.size.height = textObservation.boundingBox.size.height * CGFloat(image.height)
        return rect
    }()
    
    var imgcopy = image.cropping(to: rect)
    let imgcopysize = NSSize(width: rect.width, height: rect.height)
    
    let nsimgcopy = NSImage(cgImage: imgcopy!, size: imgcopysize)
    let out = URL(fileURLWithPath:"/tmp/" + basename + "-" + String(idx) + ".png")
    saveAsPNG(url: out, image: nsimgcopy)
}

func debugImage(image: CGImage, results: Array<VNTextObservation>) {
    let scale: CGFloat = 2
    let bounds = CGRect(x: 0, y: 0, width: image.width, height: image.height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
    
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
        let rect: CGRect = {
            var rect = CGRect()
            rect.origin.x = textObservation.boundingBox.origin.x * CGFloat(image.width)
            rect.origin.y = textObservation.boundingBox.origin.y * CGFloat(image.height)
            rect.size.width = textObservation.boundingBox.size.width * CGFloat(image.width)
            rect.size.height = textObservation.boundingBox.size.height * CGFloat(image.height)
            return rect
        }()
    
        context.fill(rect)
        
    }
    
    let debugimage = context.makeImage()
    let newSize = NSSize(width: (debugimage?.width)!, height: (debugimage?.height)!)
    let imageWithNewSize = NSImage(cgImage: debugimage!, size: newSize)
    
    print(imageWithNewSize)
    print("GA1")
    let out = URL(fileURLWithPath:"/tmp/o.png")
    saveAsPNG(url: out, image: imageWithNewSize)
}

func detectText(image: CGImage, basename: String, path: String, debug: Bool) {
    let convertedImage = image ;// |> adjustColors |> convertToGrayscale
    let handler = VNImageRequestHandler(cgImage: image)

    let request: VNDetectTextRectanglesRequest =
        VNDetectTextRectanglesRequest(completionHandler: { (request, error) in
            if (error != nil) {
                print("Got Error In Run Text Dectect Request :(")
            } else {
                guard let results = request.results as? Array<VNTextObservation> else {
                    fatalError("Unexpected result type from VNDetectTextRectanglesRequest")
                }
                if (results.count == 0) {
                    
                    return
                }

                var idx = 0
                for textObservation in results {
                    drawBbox(textObservation: textObservation, image: image, basename: basename, idx: idx)
                    
                    idx = idx + 1
                }
                
                if (debug) {
                    debugImage(image: image, results: results)
                }
            }
        })
    request.reportCharacterBoxes = true
    do {
        try handler.perform([request])
    } catch {
        print(error)
    }
}

//let image1Path = "/Users/aleksey/Downloads/10851778.jpg"

func getBasename(path: String) -> String {
    let arr = path.components(separatedBy: "/")
    let filename = arr[arr.endIndex - 1]
    let basenameArr = filename.components(separatedBy: ".")
    return basenameArr[0]
}

if let aStreamReader = StreamReader(path: "/tmp/templates.txt") {
    defer {
        aStreamReader.close()
    }
    
    while let line = aStreamReader.nextLine() {
        let image1Url = URL(fileURLWithPath: line)
        let image = NSImage(contentsOfFile: image1Url.path)
        let basename = getBasename(path: line)
        
        // Cast the NSImage to a CGImage
        var imageRect:CGRect = CGRect(origin: CGPoint(x:0, y:0), size: NSSize(width: (image?.size.width)!, height: (image?.size.height)!))
        let imageRef = image?.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        detectText(image:imageRef!, basename: basename, path: "", debug: true)
        
        // filepath; bbox1; path_to_bbox1; bbox2; path_to_bbox2
    }
}
