//
//  LabelsCreator.swift
//  Power Pong
//
//  Created by Igor Avila Amaral de Souza on 8/21/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import SpriteKit

class NodesCreator: NSObject {
    
    static func createScoreLabel(font: String, fontSize: CGFloat, color: SKColor, xPos: CGFloat, yPos: CGFloat) -> SKLabelNode {
        var label = SKLabelNode(fontNamed: font)
        label.fontColor = color
        label.fontSize = fontSize
        label.position = CGPointMake(xPos, yPos)
        return label
    }
    
 
    static func createInfoLabel(font: String, fontSize: CGFloat, color: SKColor, xPos: CGFloat, yPos: CGFloat, text: String) -> SKLabelNode{
        var label = SKLabelNode(fontNamed: "Helvetica")
        label.fontColor = color
        label.fontSize = fontSize
        label.position = CGPointMake(xPos, yPos)
        label.text = text
        
        return label
    }
    
    
    static func createRestartGameNode(image: String, height: CGFloat, width: CGFloat, xPos: CGFloat, yPos: CGFloat) -> SKSpriteNode{
        var restartGameNode = SKSpriteNode(imageNamed: image)
        restartGameNode.size = CGSizeMake(height, width)
        restartGameNode.position = CGPointMake(xPos, yPos)
        restartGameNode.hidden = true
        
        return restartGameNode
        
    }
    
    static func createBall(ballWidth: CGFloat, ballHeight: CGFloat, ballRadius: CGFloat, category: UInt32, contact: UInt32, xPos: CGFloat, yPos: CGFloat) -> SKSpriteNode {
        let defaults = NSUserDefaults.standardUserDefaults()
        var ballNode : SKSpriteNode
        if let name = defaults.stringForKey("Ball"){
            ballNode = SKSpriteNode(imageNamed: "\(name).png")
        }else{
            ballNode = SKSpriteNode(imageNamed: "circleNode.png")
        }
        ballNode.size = CGSizeMake(ballWidth, ballHeight)
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ballNode.physicsBody!.categoryBitMask = category
        ballNode.physicsBody!.contactTestBitMask = contact
        ballNode.physicsBody!.linearDamping = 0.0
        ballNode.physicsBody!.angularDamping = 0.0
        ballNode.physicsBody!.restitution = 1.0
        ballNode.physicsBody!.dynamic = true
        ballNode.physicsBody!.friction = 0.0
        ballNode.physicsBody!.allowsRotation = false
        ballNode.position = CGPointMake(xPos, yPos)
        
        return ballNode
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
}

