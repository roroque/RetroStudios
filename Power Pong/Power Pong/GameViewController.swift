//
//  GameViewController.swift
//  Power Pong
//
//  Created by Gabriel Neves Ferreira on 17/08/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import UIKit
import SpriteKit

//extension SKNode {
//    class func unarchiveFromFile(file : String) -> SKNode? {
//        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
//            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
//            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
//            
//            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
//            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
//            archiver.finishDecoding()
//            return scene
//        } else {
//            return nil
//        }
//    }
//}

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        var skView: SKView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        var w: CGFloat = skView.bounds.size.width
        var h: CGFloat = skView.bounds.size.height
        var sceneSize: CGSize = CGSizeMake(w, h)
        if h > w {
            sceneSize = CGSizeMake(h, w)
        }
        var scene: SKScene = GameScene(size: sceneSize)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        skView.presentScene(scene)
    }
    

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
