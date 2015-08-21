//
//  PaddleCreator.swift
//  Power Pong
//
//  Created by Igor Avila Amaral de Souza on 8/21/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import SpriteKit

enum Side {
    case left
    case right
}


class PaddleCreator: NSObject {
    
    static func create(paddleSide: Side, paddleWidth: CGFloat, paddleHeight: CGFloat, color: SKColor, category: UInt32, initialYPos: CGFloat, initialXPos: CGFloat) -> SKShapeNode {
        //Depending on the side, change some variables
        var mult: CGFloat = 1
        var startAngle = CGFloat(4.5*M_PI_4)
        var endAngle = CGFloat(3.5*M_PI_4)
        if(paddleSide == .left){
            mult = -1
            startAngle = CGFloat(0.5*M_PI_4)
            endAngle = CGFloat(-0.5*M_PI_4)
        }

        //Create the shape of the player 1 paddle
        var path = CGPathCreateMutable();
        //Make the top part
        CGPathMoveToPoint(path, nil, mult*paddleWidth, 0);
        CGPathAddLineToPoint(path, nil, mult*paddleWidth, paddleHeight/2)
        CGPathAddLineToPoint(path, nil, 0, paddleHeight/2)
        //Make the arc
        CGPathAddArc(path, nil, mult*(paddleHeight/(2*CGFloat(tan(0.5*M_PI_4)))), CGFloat(0), CGFloat(paddleHeight/(2*CGFloat(sin(0.5*M_PI_4)))), startAngle, endAngle, true)
        //Make the bottom part
        CGPathAddLineToPoint(path, nil, 0, -paddleHeight/2)
        CGPathAddLineToPoint(path, nil, mult*paddleWidth, -paddleHeight/2)
        CGPathAddLineToPoint(path, nil, mult*paddleWidth, 0)
        
        var paddle = SKShapeNode(path: path)
        paddle.position = CGPointMake(initialXPos, initialYPos)
        paddle.lineWidth = 0
        paddle.fillColor = color
        paddle.physicsBody = SKPhysicsBody(edgeChainFromPath: path)
        paddle.physicsBody!.categoryBitMask = category
        paddle.physicsBody!.dynamic = false
        
        return paddle
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
}

