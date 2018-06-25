//
//  AnimatedImageView.swift
//  GIFDemo
//
//  Created by jie liu on 2018/6/25.
//  Copyright © 2018年 jie liu. All rights reserved.
//

import Foundation
import UIKit

class AnimatedImageView: UIImageView {
    /// 是否自动播放
    public var autoPlayAnimatedImage = true
    /// `Animator` 对象 将帧和指定图片存储内存中
    private var animator:Animator?
    /// displayLink 为懒加载 避免还没有加载好的时候使用了 造成异常
    private var displayLinkInitialized: Bool = false
    
    private lazy var displayLink:CADisplayLink = {
       self.displayLinkInitialized = true
        let displayLink = CADisplayLink.init(target: TargetProxy.init(target: self), selector: #selector(TargetProxy.onScreenUpdate))
        displayLink.add(to: RunLoop.main, forMode: self.runLoopMode)
        displayLink.isPaused = true
        return displayLink
    }()
    
    public var runLoopMode = RunLoopMode.defaultRunLoopMode {
        willSet {
            if runLoopMode == newValue {
                return
            } else {
                stopAnimating()
                displayLink.remove(from: RunLoop.main, forMode: runLoopMode)
                displayLink.add(to: RunLoop.main, forMode: newValue)
                startAnimating()
            }
        }
    }
    
    public var gifData:NSData? {
        didSet {
            if let _gifData = gifData {
                animator = nil
                animator = Animator()
                animator?.createImageSource(data: _gifData)
                animator?.prepareFrames()
                
                didMove()
                setNeedsDisplay()
                layer.setNeedsDisplay()
            }
        }
    }
    
    func didMove() {
        if autoPlayAnimatedImage && animator != nil {
            if let _ = superview , let _ = window {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    func updateFrame() {
        if animator?.updateCurrentFrame(duration: displayLink.duration) ?? false {
            layer.setNeedsDisplay()
        }
    }
    
    override func display(_ layer: CALayer) {
        if let currentFrame = animator?.currentFrame {
            layer.contents = currentFrame.cgImage
        } else {
            layer.contents = image?.cgImage
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        didMove()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        didMove()
    }
    

    override var isAnimating: Bool {
        if displayLinkInitialized {
            return !displayLink.isPaused
        }else {
            return super.isAnimating
        }
    }
    
    /// Starts the animation.
    override public func startAnimating() {
        if self.isAnimating {
            return
        } else {
            displayLink.isPaused = false
        }
    }
    
    /// Stops the animation.
    override public func stopAnimating() {
        super.stopAnimating()
        if displayLinkInitialized {
            displayLink.isPaused = true
        }
    }
    
    deinit {
        if displayLinkInitialized {
            displayLink.invalidate()
        }
    }
    
}

fileprivate class TargetProxy {
    private weak var target: AnimatedImageView?
    
    init(target:AnimatedImageView) {
        self.target = target
    }
    
    @objc func onScreenUpdate() {
        target?.updateFrame()
    }
}
