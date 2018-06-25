//
//  Animator.swift
//  GIFDemo
//
//  Created by jie liu on 2018/6/25.
//  Copyright © 2018年 jie liu. All rights reserved.
//

import Foundation
import UIKit

struct  AnimatedFrame {
    var image:UIImage?
    let duration:TimeInterval
    
    static func null() -> AnimatedFrame {
        return AnimatedFrame.init(image: nil, duration: 0.0)
    }
}

private let kUTTypeGIF = "kUTTypeGIF"

class  Animator {
    private let maxFrameCount:Int = 100
    private var imageSource:CGImageSource!
    private var animatedFrames = [AnimatedFrame]()
    private var frameCount = 0
    private var currentFrameIndex = 0
    private var currentPreloadIndex = 0
    private var timeSinceLastFrameChange: TimeInterval = 0.0
    
    private var loopCount = 0
    private var maxTimeStep:TimeInterval = 1.0
    
    var currentFrame: UIImage? {
        return frameAtIndex(index: currentFrameIndex)
    }
    
    var contentMode: UIViewContentMode = .scaleToFill
    
    /**
     根据data创建 CGImageSource
     
     - parameter data: gif data
     */
    func createImageSource(data:NSData){
        let options: NSDictionary = [kCGImageSourceShouldCache as String:true , kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF]
        imageSource = CGImageSourceCreateWithData(data, options)
    }

    /// 准备某帧 的 frame
    func prepareFrame(index: Int) -> AnimatedFrame {
        // 获取对应帧的 CGImage
        guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, index , nil) else {
            return AnimatedFrame.null()
        }
        // 获取到 gif每帧时间间隔
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index , nil) ,let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
            let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? Double) else
        {
            return AnimatedFrame.null()
        }
        
        let image = UIImage.init(cgImage: imageRef, scale: UIScreen.main.scale, orientation: .up)
        return AnimatedFrame(image: image, duration: frameDuration)
    }
    /*
    预备所有frames
    */
    func prepareFrames() {
        frameCount = CGImageSourceGetCount(imageSource)
        
        if let properties = CGImageSourceCopyProperties(imageSource, nil),
            let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
            let loopCount = gifInfo[kCGImagePropertyGIFLoopCount as String] as? Int {
            self.loopCount = loopCount
        }
        
        // 总共帧数
        let frameToProcess = min(frameCount, maxFrameCount)
        
        animatedFrames.reserveCapacity(frameToProcess)
        
        // 相当于累加
        animatedFrames = (0..<frameToProcess).reduce([]) { $0 + pure(value: prepareFrame(index: $1))}
        
        // 上面相当于这个
        //        for i in 0..<frameToProcess {
        //            animatedFrames.append(prepareFrame(i))
        //        }
        
    }
    
    private func pure<T>(value: T) -> [T] {
        return [value]
    }
    
    /**
     根据下标获取帧
     */
    func frameAtIndex(index: Int) -> UIImage? {
        return animatedFrames[index].image
    }
    
    func updateCurrentFrame(duration:CFTimeInterval) -> Bool {
        // 计算距离上一帧 改变的时间 每次进来都累加 直到frameDuration  <= timeSinceLastFrameChange 时候才继续走下去
        timeSinceLastFrameChange += min(maxTimeStep, duration)
        let frameDuration = animatedFrames[currentFrameIndex].duration
        if frameDuration > timeSinceLastFrameChange  {
            return false
        }
        // 减掉 我们每帧间隔时间
        timeSinceLastFrameChange -= frameDuration
        let lastFrameIndex = currentFrameIndex
        currentFrameIndex += 1 // 一直累加
        // 这里取了余数
        currentFrameIndex = currentFrameIndex % animatedFrames.count
        
        if animatedFrames.count < frameCount {
            animatedFrames[lastFrameIndex] = prepareFrame(index: currentPreloadIndex)
            currentPreloadIndex += 1
            currentFrameIndex = currentPreloadIndex % frameCount
        }
        return true
    }
 
}
