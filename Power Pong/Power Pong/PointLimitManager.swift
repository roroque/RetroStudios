//
//  PointLimitManager.swift
//  Power Pong
//
//  Created by Igor Avila Amaral de Souza on 8/25/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import UIKit

class PointLimitManager : UIViewController {
    
    @IBOutlet weak var playerOneText: UITextField!
    @IBOutlet weak var playerTwoText: UITextField!
    
    @IBOutlet weak var pointLimitLabel: UILabel!
    @IBOutlet weak var pointLimitStepper: UIStepper!
    
    override func viewDidLoad() {
        
        playerOneText.backgroundColor = UIColor.clearColor()
        playerTwoText.backgroundColor = UIColor.clearColor()
        
        
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
            pointLimitLabel.text = "Point limit: 5"
        }
        
        if ((defaults.stringForKey("playerOneName")) != nil){
            playerOneText.text = defaults.stringForKey("playerOneName")
        }else{
            defaults.setValue("Player 1" as String, forKey: "playerOneName")
            playerOneText.text = "Player 1"
        }
        
        if ((defaults.stringForKey("playerTwoName")) != nil){
            playerTwoText.text = defaults.stringForKey("playerTwoName")
        }else{
            defaults.setValue("Player 2" as String, forKey: "playerTwoName")
            playerTwoText.text = "Player 2"
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