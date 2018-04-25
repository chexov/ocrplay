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

func detectText(image: CGImage) {
    let convertedImage = image ;// |> adjustColors |> convertToGrayscale
    let handler = VNImageRequestHandler(cgImage: image)
    //VNImageRequestHandler* handler = [[VNImageRequestHandler alloc]initWithCVPixelBuffer:bufferRefer options:@{}];

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
                
                let scale: CGFloat = 2
                let bounds = CGRect(x: 0, y: 0, width: 2000, height: 1500)
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

                
//                let context = NSGraphicsContext.current
//                context?.setStrokeColor(UIColor.red.cgColor)
//                context?.translateBy(x: 0, y: image.size.height)
//                context?.scaleBy(x: 1, y: -1)
//                context?.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
                
                var numberOfWords = 0
                for textObservation in results {
//                    print(textObservation)
//                    print(textObservation.characterBoxes)
                    
                    let rect: CGRect = {
                        var rect = CGRect()
                        rect.origin.x = textObservation.boundingBox.origin.x * CGFloat(image.width)
                        rect.origin.y = textObservation.boundingBox.origin.y * CGFloat(image.height)
                        rect.size.width = textObservation.boundingBox.size.width * CGFloat(image.width)
                        rect.size.height = textObservation.boundingBox.size.height * CGFloat(image.height)
                        return rect
                    }()
                    // Draw square
                    context.setStrokeColor(CGColor(colorSpace: colorSpace, components: [0, 0, 1, 1])!)
                    context.setFillColor(CGColor(colorSpace: colorSpace, components: [0, 0, 1, 0.42])!)
                    context.setLineWidth(4)
//                    context.rect
                    
                    context.fill(rect)
                    
//                    print(textObservation)
                    
//                    var numberOfCharacters = 0
//                    for rectangleObservation in textObservation.characterBoxes! {
//                        let croppedImage = crop(image: image, rectangle: rectangleObservation)
//                        if let croppedImage = croppedImage {
//                            let processedImage = preProcess(image: croppedImage)
//                            self.classifyImage(image: processedImage,
//                                               wordNumber: numberOfWords,
//                                               characterNumber: numberOfCharacters)
//                            numberOfCharacters += 1
//                        }
//                    }
                    numberOfWords += 1
                }

                let cgImage = context.makeImage()!
                let newSize = NSSize(width: 2000, height: 1500)
                let imageWithNewSize = NSImage(cgImage: cgImage, size: newSize)
                
                print(imageWithNewSize)
                print("GA1")
                let out = URL(fileURLWithPath:"/tmp/o.jpg")
                saveAsPNG(url: out, image: imageWithNewSize)
                
                
            }
        })
    request.reportCharacterBoxes = true
    do {
        try handler.perform([request])
    } catch {
        print(error)
    }
}

let image1Path = "/Users/chexov/Downloads/10851778.jpg"
let image1Url = URL(fileURLWithPath: image1Path)
let image = NSImage(contentsOfFile: image1Url.path)

// Cast the NSImage to a CGImage
var imageRect:CGRect = CGRect(origin: CGPoint(x:0, y:0), size: NSSize(width: Int(2000), height: Int(1500)))
let imageRef = image?.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)

detectText(image:imageRef!)
sleep(1000)
print("Bye, World!")
//let resizedImage = ImageUtil.resizeImage(image: image1!, size: size)

