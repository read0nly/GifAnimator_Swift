//
//  GifHelper.swift
//  GIFDemo
//
//  Created by jie liu on 2018/6/25.
//  Copyright © 2018年 jie liu. All rights reserved.
//

import Foundation
import UIKit

private let kUTTypeGIF = "kUTTypeGIF"

class GifHelper {
    
    var name:String
    
    init(name:String) {
        self.name = name
        self.prassGif()
    }
    
    var images = [UIImage]()
    var gifDuration:Double = 0
    
    func prassGif() {
        let options: NSDictionary = [kCGImageSourceShouldCache as String: true, kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF]
        
        guard let path = Bundle.main.path(forResource: self.name, ofType: "gif"),
            let data = NSData(contentsOfFile: path),
            let imageSource = CGImageSourceCreateWithData(data, options) else {
            return
        }
        let frameCount = CGImageSourceGetCount(imageSource)
        
        for i in 0 ..<  frameCount {
            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, options) ,
                let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil),
            let gifinfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary] as? NSDictionary,
            let frameDuration = gifinfo[kCGImagePropertyGIFDelayTime] as? Double
            else {
                continue
            }
            if frameCount > 1 {
                gifDuration += frameDuration
            }
            let image = UIImage.init(cgImage: imageRef, scale: UIScreen.main.scale, orientation: UIImageOrientation.up)
            images.append(image)
        }
        
    }
}
