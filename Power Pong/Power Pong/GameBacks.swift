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
        "spaceBack.png",
        "usa.png",
        "brFlag.png"]
    
    var dataTitle:NSArray =  ["black",
        "grassBack",
        "basketBack",
        "spaceBack",
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
            dropDownMenu.menuIconImage = UIImage(named: "black")
        }
        dropDownMenu.dropDownItems = dropdownItems as [AnyObject]
        dropDownMenu.paddingLeft = 10
        dropDownMenu.frame = CGRectMake((self.frame.size.width/2) - 150, 0, 50, 40)
        dropDownMenu.delegate = self
        dropDownMenu.type = DropDownMenuType.Stack
        dropDownMenu.gutterY = 5
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
