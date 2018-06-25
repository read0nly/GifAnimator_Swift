//
//  ViewController.swift
//  GIFDemo
//
//  Created by jie liu on 2018/6/25.
//  Copyright © 2018年 jie liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: AnimatedImageView!
    
    
    @IBAction func start(_ sender: Any) {
        if !imageView.isAnimating {
            imageView.startAnimating()
        }
    }
    @IBAction func stop(_ sender: Any) {
        if imageView.isAnimating {
            imageView.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let path = Bundle.main.path(forResource: "acer01", ofType: "gif")
        let data = NSData.init(contentsOfFile: path!)
        self.imageView.gifData = data
    }
}

