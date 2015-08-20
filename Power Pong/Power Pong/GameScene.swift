//
//  GameScene.swift
//  Power Pong
//
//  Created by Gabriel Neves Ferreira on 17/08/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import SpriteKit

let kPaddleWidth: CGFloat = 20.0 //width of the paddles
let kPaddleHeight: CGFloat = 80.0 //height of the paddles
let kBallRadius: CGFloat = 15.0 //radius of the moving ball
let kStartingVelocityX: CGFloat = 300.0 //starting velocity x value for moving the ball
let kStartingVelocityY: CGFloat = -300.0 //starting velocity y value for moving the ball
let kVelocityMultFactor: CGFloat = 1.05 //multiply factor for speeding up the ball after some time
let kIpadMultFactor: CGFloat = 2.0 //multiply factor for ipad object scaling
let kSpeedupInterval: CGFloat = 5.0 //interval after which the speedUpTheBall method is called
let kScoreFontSize: CGFloat = 30.0 //font size of score label nodes
let kRestartGameWidthHeight: CGFloat = 50.0 //width and height of restart node
let kPaddleMoveMult: CGFloat = 1.5 //multiply factor when moving fingers to move the paddles, by moving finger for N pt it will move it for N * kPaddleMoveMult

//categories for detecting contacts between nodes
let  ballCategory : UInt32 = 0x1 << 0
let cornerCategory : UInt32 = 0x1 << 1
let paddleCategory : UInt32  = 0x1 << 2

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var isPlayingGame: Bool = false
    //ball node
    var ballNode : SKSpriteNode?
    var fireBall : SKEmitterNode?
    //paddle nodes
    var playerOnePaddleNode : SKSpriteNode!
    var playerTwoPaddleNode : SKSpriteNode!
    //score label nodes
    var playerOneScoreNode : SKLabelNode!
    var playerTwoScoreNode : SKLabelNode!
    //restart game node
    var restartGameNode : SKSpriteNode!
    //start game info node
    var startGameInfoNode : SKLabelNode!
    //touches
    var playerOnePaddleControlTouch : UITouch?
    var playerTwoPaddleControlTouch : UITouch?
    //score
    var playerOneScore : Int = 0
    var playerTwoScore : Int = 0
    //timer for speed-up
    var speedupTimer : NSTimer?
    //sounds
    var bounceSoundAction : SKAction?
    var failSoundAction : SKAction?
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //Setup the scene
        self.backgroundColor = SKColor.blackColor()
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        //Setup physics body for scene
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody!.categoryBitMask = cornerCategory
        self.physicsBody!.dynamic = false
        self.physicsBody!.friction = 0.0
        self.physicsBody!.restitution = 1.0
        
        //Dimensions
        var paddleWidth: CGFloat = kPaddleWidth
        var paddleHeight: CGFloat = kPaddleHeight
        var middleLineWidth: CGFloat = 4.0
        var middleLineHeight: CGFloat = 20.0
        var scoreFontSize: CGFloat = kScoreFontSize
        var restartNodeWidthHeight: CGFloat = kRestartGameWidthHeight
        
        //Scale for iPad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            paddleWidth *= kIpadMultFactor
            paddleHeight *= kIpadMultFactor
            middleLineWidth *= kIpadMultFactor
            middleLineHeight *= kIpadMultFactor
            scoreFontSize *= kIpadMultFactor
            restartNodeWidthHeight *= kIpadMultFactor
        }
        
        //Middle line 
        var numberOfLines = Int(size.height / (2 * middleLineHeight))
        var linePosition: CGPoint = CGPointMake(size.width / 2.0, middleLineHeight * 1.5)
        for var i = 0; i < numberOfLines; i++ {
            var lineNode: SKSpriteNode = SKSpriteNode(color: SKColor(white: 1.0, alpha: 0.5), size: CGSizeMake(middleLineWidth, middleLineHeight))
            lineNode.position = linePosition
            linePosition.y += 2 * middleLineHeight
            self.addChild(lineNode)
        }
        
        //Paddles
        self.playerOnePaddleNode = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(paddleWidth, paddleHeight))
        self.playerTwoPaddleNode = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(paddleWidth, paddleHeight))
        self.playerOnePaddleNode.position = CGPointMake(self.playerOnePaddleNode.size.width, CGRectGetMidY(self.frame))
        self.playerTwoPaddleNode.position = CGPointMake(CGRectGetMaxX(self.frame) - self.playerTwoPaddleNode.size.width, CGRectGetMidY(self.frame))
        self.playerOnePaddleNode.physicsBody = SKPhysicsBody(rectangleOfSize: self.playerOnePaddleNode.size)
        self.playerOnePaddleNode.physicsBody!.categoryBitMask = paddleCategory
        self.playerTwoPaddleNode.physicsBody = SKPhysicsBody(rectangleOfSize: self.playerTwoPaddleNode.size)
        self.playerTwoPaddleNode.physicsBody!.categoryBitMask = paddleCategory
        self.playerOnePaddleNode.physicsBody!.dynamic = false
        self.playerTwoPaddleNode.physicsBody!.dynamic = false
        self.addChild(self.playerOnePaddleNode)
        self.addChild(self.playerTwoPaddleNode)
        
        //Score Labels
        self.playerOneScoreNode = SKLabelNode(fontNamed: "Helvetica")
        self.playerTwoScoreNode = SKLabelNode(fontNamed: "Helvetica")
        self.playerOneScoreNode.fontColor = SKColor.whiteColor()
        self.playerTwoScoreNode.fontColor = SKColor.whiteColor()
        self.playerOneScoreNode.fontSize = scoreFontSize
        self.playerTwoScoreNode.fontSize = scoreFontSize
        self.playerOneScoreNode.position = CGPointMake(size.width * 0.25, size.height - scoreFontSize * 2.0)
        self.playerTwoScoreNode.position = CGPointMake(size.width * 0.75, size.height - scoreFontSize * 2.0)
        self.addChild(self.playerOneScoreNode)
        self.addChild(self.playerTwoScoreNode)

        //Restart node
        self.restartGameNode = SKSpriteNode(imageNamed: "restartNode.png")
        self.restartGameNode.size = CGSizeMake(restartNodeWidthHeight, restartNodeWidthHeight)
        self.restartGameNode.position = CGPointMake(size.width / 2.0, size.height - restartNodeWidthHeight)
        self.restartGameNode.hidden = true
        self.addChild(self.restartGameNode)
        
        //start game info node
        self.startGameInfoNode = SKLabelNode(fontNamed: "Helvetica")
        self.startGameInfoNode.fontColor = SKColor.whiteColor()
        self.startGameInfoNode.fontSize = scoreFontSize
        self.startGameInfoNode.position = CGPointMake(size.width / 2.0, size.height / 2.0)
        self.startGameInfoNode.text = "Tap to start!"
        self.addChild(self.startGameInfoNode)
        
        //set scores to 0
        self.playerOneScore = 0
        self.playerTwoScore = 0
        self.updateScoreLabels()
        
        //sound actions
        //self.bounceSoundAction = [SKAction playSoundFileNamed:@"app_game_interactive_alert_tone_026.mp3" waitForCompletion:NO];
        //self.failSoundAction = [SKAction playSoundFileNamed:@"synth_stab.mp3" waitForCompletion:NO];
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    func startPlayingTheGame() {
        
        self.isPlayingGame = true
        self.startGameInfoNode.hidden = true
        self.restartGameNode.hidden = false
        
        var ballWidth: CGFloat = kBallRadius * 2.0
        var ballHeight: CGFloat = kBallRadius * 2.0
        var ballRadius: CGFloat = kBallRadius
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            ballWidth *= kIpadMultFactor;
            ballHeight *= kIpadMultFactor;
            ballRadius *= kIpadMultFactor;
        }
        
        
        
        
        //Create the ball
        self.ballNode = SKSpriteNode(imageNamed: "circleNode.png")
        self.ballNode!.size = CGSizeMake(ballWidth, ballHeight)
        self.ballNode!.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        self.ballNode!.physicsBody!.categoryBitMask = ballCategory
        self.ballNode!.physicsBody!.contactTestBitMask = cornerCategory | paddleCategory
        self.ballNode!.physicsBody!.linearDamping = 0.0
        self.ballNode!.physicsBody!.angularDamping = 0.0
        self.ballNode!.physicsBody!.restitution = 1.0
        self.ballNode!.physicsBody!.dynamic = true
        self.ballNode!.physicsBody!.friction = 0.0
        self.ballNode!.physicsBody!.allowsRotation = false
        self.ballNode!.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0)
        self.addChild(self.ballNode!)

        
        
        var startingVelocityX: CGFloat = kStartingVelocityX
        var startingVelocityY: CGFloat = kStartingVelocityY
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            startingVelocityX *= kIpadMultFactor
            startingVelocityY *= kIpadMultFactor
        }
        if self.playerOneScore > self.playerTwoScore {
            startingVelocityX = -startingVelocityX
        }
        self.ballNode!.physicsBody!.velocity = CGVectorMake(startingVelocityX, startingVelocityY)
        self.speedupTimer = NSTimer(timeInterval: NSTimeInterval(kSpeedupInterval), target: self, selector: "speedUpTheBall", userInfo: nil, repeats: true)
        
        //Create fire

        
        
        self.fireBall = SKEmitterNode(fileNamed: "exampleFire")
        self.ballNode!.addChild(self.fireBall!)
        //self.fireBall?.emissionAngle = 2 - atan(startingVelocityY / startingVelocityX)
        self.fireBall?.emissionAngle = atan2(self.ballNode!.physicsBody!.velocity.dx , self.ballNode!.physicsBody!.velocity.dy)
        self.fireBall?.targetNode = self
        
    }
    
    func restartTheGame() {
        
        //Remove the ball
        self.ballNode!.removeFromParent()
        //Stop Timer
        self.speedupTimer!.invalidate()
        self.speedupTimer = nil
        
        self.isPlayingGame = false
        self.startGameInfoNode.hidden = false
        self.restartGameNode.hidden = true
        //Reset the scores
        self.playerOneScore = 0
        self.playerTwoScore = 0
        //Update the labels
        self.updateScoreLabels()
        
    }
    
    func updateScoreLabels() {
        self.playerOneScoreNode.text = "\(self.playerOneScore)"
        self.playerTwoScoreNode.text = "\(self.playerTwoScore)"
    }
    
    func pointForPlayer(player: Int){
        
        switch player {
        case 1:
            self.playerOneScore++
            self.ballNode!.removeFromParent()
            self.isPlayingGame = false
            self.startGameInfoNode.hidden = false
            self.restartGameNode.hidden = true
            self.speedupTimer!.invalidate()
            self.speedupTimer = nil
        case 2:
            self.playerTwoScore++
            self.ballNode!.removeFromParent()
            self.isPlayingGame = false
            self.startGameInfoNode.hidden = false
            self.restartGameNode.hidden = true
            self.speedupTimer!.invalidate()
            self.speedupTimer = nil
        default:
            println()
        }
        self.updateScoreLabels()
    }
    
    override func willMoveFromView(view: SKView) {
        //reset timer
        self.speedupTimer!.invalidate()
        self.speedupTimer = nil
    }
    
    //Method called by the timer
    func speedUpTheBall() {
        var velocityX: CGFloat = self.ballNode!.physicsBody!.velocity.dx * kVelocityMultFactor
        var velocityY: CGFloat = self.ballNode!.physicsBody!.velocity.dy * kVelocityMultFactor
        self.ballNode!.physicsBody!.velocity = CGVectorMake(velocityX, velocityY)
    }
    
    //Move the first paddle with data from previous and new touch positions
    func moveFirstPaddle() {
        var previousLocation: CGPoint = self.playerOnePaddleControlTouch!.previousLocationInNode(self)
        var newLocation: CGPoint = self.playerOnePaddleControlTouch!.locationInNode(self)
        if newLocation.x > self.size.width / 2.0 {
            return
        }
        var x: CGFloat = self.playerOnePaddleNode.position.x
        var y: CGFloat = self.playerOnePaddleNode.position.y + (newLocation.y - previousLocation.y) * kPaddleMoveMult
        var yMax: CGFloat = self.size.height - self.playerOnePaddleNode.size.width / 2.0 - self.playerOnePaddleNode.size.height / 2.0
        var yMin: CGFloat = self.playerOnePaddleNode.size.width / 2.0 + self.playerOnePaddleNode.size.height / 2.0
        if y > yMax {
            y = yMax
        }
        else {
            if y < yMin {
                y = yMin
            }
        }
        self.playerOnePaddleNode.position = CGPointMake(x, y)
    }
    
    //Move the second paddle with the data from previous and new touch positions
    func moveSecondPaddle() {
        var previousLocation: CGPoint = self.playerTwoPaddleControlTouch!.previousLocationInNode(self)
        var newLocation: CGPoint = self.playerTwoPaddleControlTouch!.locationInNode(self)
        if newLocation.x < self.size.width / 2.0 {
            return
        }
        var x: CGFloat = self.playerTwoPaddleNode.position.x
        var y: CGFloat = self.playerTwoPaddleNode.position.y + (newLocation.y - previousLocation.y) * kPaddleMoveMult
        var yMax: CGFloat = self.size.height - self.playerTwoPaddleNode.size.width / 2.0 - self.playerTwoPaddleNode.size.height / 2.0
        var yMin: CGFloat = self.playerTwoPaddleNode.size.width / 2.0 + self.playerTwoPaddleNode.size.height / 2.0
        if y > yMax {
            y = yMax
        }
        else {
            if y < yMin {
                y = yMin
            }
        }
        self.playerTwoPaddleNode.position = CGPointMake(x, y)
    }
    
    //React to contact between nodes/bodies
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        //Check if we have a ball with a corner contact
        /*
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == cornerCategory {
            //ball touched left side
            if firstBody.node!.position.x <= firstBody.node!.frame.size.width {
                self.pointForPlayer(2)
                self.runAction(self.failSoundAction)
            }
            else {
                //ball touched the right side
                if firstBody.node!.position.x >= (self.size.width - firstBody.node!.frame.size.width) {
                    self.pointForPlayer(1)
                    self.runAction(self.failSoundAction)
                }
                else {
                    self.runAction(self.bounceSoundAction)
                }
            }
        }

            
        //Check if we have a ball and pad contact
        else  */if(firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory){
            self.runAction(self.bounceSoundAction)
            //you can react here if you want to customize the ball movement or direction
            //in original pong direction of the ball after it hits the paddle depends on
            //what part of the paddle does it hit
            //so you can customize it as you want
            var paddleNode: SKSpriteNode = secondBody.node as! SKSpriteNode
            var ballPosition: CGPoint = self.ballNode!.position
            var firstThird: CGFloat = (paddleNode.position.y - paddleNode.size.height / 2.0) + paddleNode.size.height * (1.0 / 3.0)
            var secondThird: CGFloat = (paddleNode.position.y - paddleNode.size.height / 2.0) + paddleNode.size.height * (2.0 / 3.0)
            var dx: CGFloat = self.ballNode!.physicsBody!.velocity.dx
            var dy: CGFloat = self.ballNode!.physicsBody!.velocity.dy
            if ballPosition.y < firstThird {
                //ball hits the left part
                if dy > 0 {
                    self.ballNode!.physicsBody!.velocity = CGVectorMake(dx, -dy)
                }
            }
            else {
                if ballPosition.y > secondThird {
                    //ball hits the left part
                    if dy < 0 {
                        self.ballNode!.physicsBody!.velocity = CGVectorMake(dx, -dy)
                    }
                }
            }
        }
        
        
        
        //change the flame direction
       // println(self.fireBall?.emissionAngle)
        //self.fireBall?.emissionAngle = atan(self.ballNode!.physicsBody!.velocity.dy / self.ballNode!.physicsBody!.velocity.dx)
        //println(atan(self.ballNode!.physicsBody!.velocity.dy / self.ballNode!.physicsBody!.velocity.dx))
        self.fireBall?.emissionAngle = CGFloat(M_PI ) + atan2(self.ballNode!.physicsBody!.velocity.dy,self.ballNode!.physicsBody!.velocity.dx)
        
        //println(atan2(self.ballNode!.physicsBody!.velocity.dy, self.ballNode!.physicsBody!.velocity.dx))
        
    }
    
    
  
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.isPlayingGame {
            for touch in touches as! Set<UITouch> {
                //Set touch to move paddles
                var location: CGPoint = touch.locationInNode(self)
                //Check if it is at the restart node
                if CGRectContainsPoint(self.restartGameNode.frame, location) {
                    self.restartTheGame()
                    return
                }
                if self.playerOnePaddleControlTouch == nil {
                    if location.x < self.size.width / 2.0 {
                        self.playerOnePaddleControlTouch = touch
                    }
                }
                if self.playerTwoPaddleControlTouch == nil {
                    if location.x > self.size.width / 2.0 {
                        self.playerTwoPaddleControlTouch = touch
                    }
                }
            }
            return
        }
        else {
            //Start Playing
            self.startPlayingTheGame()
            return
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches as! Set<UITouch> {
            if touch == self.playerOnePaddleControlTouch {
                self.moveFirstPaddle()
            }
            else {
                if touch == self.playerTwoPaddleControlTouch {
                    self.moveSecondPaddle()
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches as! Set<UITouch> {
            if touch == self.playerOnePaddleControlTouch {
                self.playerOnePaddleControlTouch = nil
            }
            else {
                if touch == self.playerTwoPaddleControlTouch {
                    self.playerTwoPaddleControlTouch = nil
                }
            }
        }
    }
    
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//    }
}
