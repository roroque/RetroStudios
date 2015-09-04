//
//  PointLimitManager.swift
//  Power Pong
//
//  Created by Igor Avila Amaral de Souza on 8/25/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import UIKit
import iAd

//iAd
var adBannerMainView: ADBannerView!

class PointLimitManager : UIViewController, ADBannerViewDelegate{
    
    @IBOutlet weak var playerOneText: UITextField!
    @IBOutlet weak var playerTwoText: UITextField!
    
    @IBOutlet weak var pointLimitLabel: UILabel!
    @IBOutlet weak var pointLimitStepper: UIStepper!
    
    override func viewDidLoad() {
        
        loadAds()
        
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
    
    func loadAds() {
        adBannerMainView = ADBannerView(frame: CGRectZero)
        adBannerMainView.delegate = self
        adBannerMainView.hidden = true
        view.addSubview(adBannerMainView)
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        println("Ad about to load")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBannerMainView.center = CGPoint(x: adBannerMainView.center.x, y: view!.bounds.size.height - view!.bounds.size.height + adBannerMainView.frame.size.height / 2)
        
        adBannerMainView.layer.position = CGPoint(x: view.layer.position.x, y: 20)
        
        adBannerMainView.hidden = false
        println("Displaying the Ad")
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        println("Leave the application to the Ad")
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        //move off bounds when add didnt load
        
        adBannerMainView.center = CGPoint(x: adBannerMainView.center.x, y: view!.bounds.size.height + view!.bounds.size.height)
        
        println("Ad is not available")
    }
}