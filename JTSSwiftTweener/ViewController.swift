//
//  ViewController.swift
//  JTSSwiftTweener
//
//  Created by Joshua Sullivan on 12/10/16.
//  Copyright © 2016 Josh Sullivan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 24.0, weight: UIFont.Weight.light)
            label.layer.borderWidth = 1.0
            label.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func animateTapped() {
        button.isEnabled = false
        Tweener.tween(duration: 4.0, delay: 1.0, from: 0.0, to: 100.0, progress: {
            [weak self] (progress, tweener) in
            let string = String(format: "%0.1f", progress)
            self?.label.text = string
        }, completion: {
            [weak self] completed, _ in
            self?.button.isEnabled = completed
        })
    }
}

