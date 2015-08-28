//
//  PowerUpController.swift
//  Power Pong
//
//  Created by Gabriel Neves Ferreira on 21/08/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import SpriteKit

class PowerUpController: NSObject {
    
    
    
    func getRandomPowerUp(screenSize: CGSize) -> SKSpriteNode
    {
        var randomPower = ""
        let x = random() % 3
        println(x)
        switch x
        {
        case 0: randomPower = "flamingBall"
        case 1: randomPower = "multiBall"
        case 2: randomPower = "barrier"
        default: randomPower = "flamingBall"
        }
        var ballWidth: CGFloat = kBallRadius * 2.0
        var ballHeight: CGFloat = kBallRadius * 2.0
        var ballRadius: CGFloat = kBallRadius
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            ballWidth *= kIpadMultFactor;
            ballHeight *= kIpadMultFactor;
            ballRadius *= kIpadMultFactor;
        }
        
        
        var node =  SKSpriteNode(imageNamed: randomPower)
        node.size = CGSizeMake(screenSize.height/10, screenSize.height/10)
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
        if x == 1
        {
            node = NodesCreator.createBall(ballWidth, ballHeight: ballHeight, ballRadius: ballRadius, category: ballCategory, contact: cornerCategory | paddleCategory, xPos: screenSize.width / 2.0, yPos: screenSize.height / 2.0)
        }
        node.name = randomPower
        node.position = getRandomPosition(randomPower, withScreenSize: screenSize)
        
        return node
    }
    
    private func getRandomPosition(forPowerUp:String , withScreenSize:CGSize) -> CGPoint
    {
        
        var location = CGPoint()
        let y = arc4random_uniform(UInt32(withScreenSize.height - 20.0)) + 20
        
      //  if forPowerUp == "flamingBall"
       // {
        location = CGPointMake(withScreenSize.width / 2.0, CGFloat(y))
       // }
      //  else
     //   {
       //     CGPointMake(CGFloat(random()) % withScreenSize.width, CGFloat(random()) % withScreenSize.height )
//        }
        
        return location
        
    }

}
