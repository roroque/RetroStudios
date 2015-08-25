//
//  PointLimitManager.swift
//  Power Pong
//
//  Created by Igor Avila Amaral de Souza on 8/25/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import UIKit

class PointLimitManager : UIViewController {
    
   // var pointLimitLabel = UILabel()
    
    @IBOutlet weak var pointLimitLabel: UILabel!
    @IBOutlet weak var pointLimitStepper: UIStepper!
    
    override func viewDidLoad() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("PointLimit") != nil){
            let limit: Int = defaults.integerForKey("PointLimit")
            pointLimitStepper.value = Double(limit)
            if limit == 0 {
                pointLimitLabel.text = "Point limit: ∞"
            }else{
                pointLimitLabel.text = "Point limit: \(limit)"
            }
            
        }else{
            defaults.setInteger(5, forKey: "PointLimit")
            pointLimitStepper.value = 5
        }
        
    }
    
    @IBAction func pointLimitChanged(sender: UIStepper) {
        println(sender.value)
        
        if Int(sender.value) == 0 {
            pointLimitLabel.text = "Point limit: ∞"
        }else{
            pointLimitLabel.text = "Point limit: \(Int(sender.value))"
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(Int(sender.value), forKey: "PointLimit")
    }
}