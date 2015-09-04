//
//  GameBacks.swift
//  Power Pong
//
//  Created by Igor Avila Amaral de Souza on 8/24/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import Foundation

import UIKit

@IBDesignable class GameBacks: UIView, DropDownMenuDelegate {
    var dropDownMenu = DropDownMenu()
    
    var dataImage:NSArray = ["black.png",
        "grassBack.png",
        "basketBack.png",
        "snooker",
        "usa.png",
        "brFlag.png"]
    
    var dataTitle:NSArray =  ["black",
        "grassBack",
        "basketBack",
        "snooker",
        "usa",
        "brFlag"]
    
    var item:DropDownItem!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupInit()
    }
    
    override func prepareForInterfaceBuilder() {
        setupInit()
    }
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupInit() {
        
        var dropdownItems:NSMutableArray = NSMutableArray()
        
        for i in 0...(dataTitle.count-1) {
            var item = DropDownItem()
            item.iconImage = UIImage(named: "\(dataImage[i])")
            item.text = "\(dataTitle[i])"
            dropdownItems.addObject(item)
        }
        
        //dropDownMenu.menuText = ""
        //dropDownMenu.menuIconImage = UIImage(named: "ball_default.png")
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("Back"){
            dropDownMenu.menuIconImage = UIImage(named: "\(name).png")
        }else{
            dropDownMenu.menuIconImage = UIImage(named: "black.png")
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            dropDownMenu.direction = DropDownMenuDirection.Right
        }
        else{
            dropDownMenu.direction = DropDownMenuDirection.Down
        }
        
        //Use the sizes of the view to know what is the best size to the items
        //Big side of the view, width -10 is a bug of the class
        let bigSide: CGFloat = ((self.frame.size.width-10) > self.frame.size.height) ? (self.frame.size.width-10) : self.frame.size.height
        //Small side of the view, width -10 is a bug of the class
        let smallSide: CGFloat = ((self.frame.size.width-10) < self.frame.size.height) ? (self.frame.size.width-10) : self.frame.size.height
        //Check if the problem is the big or the small side
        var size: CGFloat = (smallSide < bigSide/CGFloat(self.dataImage.count+1)) ? smallSide : bigSide/CGFloat(self.dataImage.count+1)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            dropDownMenu.frame = CGRectMake(0, 0, size, size)
        }
        else{
            //40 because iPhone the sizes dont work, I dont know why
            dropDownMenu.frame = CGRectMake(0, 0, 40, 40)
        }
        
        dropDownMenu.dropDownItems = dropdownItems as [AnyObject]
        dropDownMenu.paddingLeft = 0
        //dropDownMenu.frame = CGRectMake((self.frame.size.width/2) - 150, 0, 50, 40)
        dropDownMenu.delegate = self
        dropDownMenu.type = DropDownMenuType.Stack
        dropDownMenu.gutterY = 0
        dropDownMenu.itemAnimationDelay = 0.1
        dropDownMenu.reloadView()
        
        addSubview(self.dropDownMenu)
    }
    
    func dropDownMenu(dropDownMenu: DropDownMenu!, selectedItemAtIndex index: Int) {
        self.item = dropDownMenu.dropDownItems[index] as! DropDownItem
        defaults.setObject("\(item.text)", forKey: "Back")
        println("Selected back: \(item.text)")
    }
    
}
