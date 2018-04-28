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

func saveBBox(textObservation: VNTextObservation, image: CGImage, path: String, idx: Int) {
    var rect = getRect(textObservation: textObservation, imgWidth: image.width, imgHeight: image.height)
    let basename = getBasename(path: path)
    let basedir = getBasedir(path: path)
    
    // Please be careful here!!!
    rect.size.width = rect.size.width + 50
    rect.size.height = rect.size.height + 50
    
    rect.origin.y = CGFloat(image.height) -  rect.origin.y - rect.size.height + 25
    rect.origin.x = rect.origin.x - 25
    
    let imgcopy = image.copy()
    var croppedImage = imgcopy!.cropping(to: rect)
    let croppedSize = NSSize(width: rect.width, height: rect.height)
    
    let nsimgcopy = NSImage(cgImage: croppedImage!, size: croppedSize)
    let out = URL(fileURLWithPath: basedir + "/" + basename + "-" + String(idx) + ".png")
    saveAsPNG(url: out, image: nsimgcopy)
}

/*
 * image: cgimage
 * basename: filename without extension
 * path: dir for basename results
 * debug: fill rect's on image and save res in /tmp/o.png
 */

func detectText(image: CGImage, path: String, debug: Bool) {
    let convertedImage = image ;// |> adjustColors |> convertToGrayscale
    let handler = VNImageRequestHandler(cgImage: image)
    let basename = getBasename(path: path)
    let basedir = getBasedir(path: path)
    var bboxes = ""

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
                    saveBBox(textObservation: textObservation, image: image, path: path, idx: idx)
                    
                    let bbox = getRect(textObservation: textObservation, imgWidth: image.width, imgHeight: image.height)
                    let s = bbox.minX.description + " " + bbox.minY.description + " " + bbox.maxX.description + " " + bbox.maxY.description + "\n"
                    bboxes.append(s)
                    idx = idx + 1
                }
                
                if (debug) {
                    debugImage(image: image, results: results, path: path)
                }
            }
        })
    request.reportCharacterBoxes = true
    do {
        try handler.perform([request])
    } catch {
        print(error)
    }
    try? bboxes.write(to: URL(fileURLWithPath: basedir + "/" + "bboxes-" + basename + ".txt"), atomically: true, encoding: String.Encoding.utf8)
}

//let image1Path = "/Users/aleksey/Downloads/10851778.jpg"
let prod = "/Users/aleksey/dataset/platesmania/orig/dataset/dataset.txt"
let debug = "/tmp/ocr/dataset.txt"

if let aStreamReader = StreamReader(path: prod) {
    defer {
        aStreamReader.close()
    }
    
    while let line = aStreamReader.nextLine() {
        print(line)
        let image1Url = URL(fileURLWithPath: line)
        let image = NSImage(contentsOfFile: image1Url.path)
        
        // Cast the NSImage to a CGImage
        var imageRect:CGRect = CGRect(origin: CGPoint(x:0, y:0), size: NSSize(width: (image?.size.width)!, height: (image?.size.height)!))
        let imageRef = image?.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        detectText(image:imageRef!, path: line, debug: true)
        
        // filepath; bbox1; path_to_bbox1; bbox2; path_to_bbox2
    }
}
