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
let kStartingVelocityX: CGFloat = 150.0 //starting velocity x value for moving the ball
let kStartingVelocityY: CGFloat = -150.0 //starting velocity y value for moving the ball
let kVelocityMultFactor: CGFloat = 1.03 //multiply factor for speeding up the ball after some time
let kSpeedupInterval: CGFloat = 1.0 //interval after which the speedUpTheBall method is called
let kIpadMultFactor: CGFloat = 2.0 //multiply factor for ipad object scaling
let kScoreFontSize: CGFloat = 30.0 //font size of score label nodes
let kRestartGameWidthHeight: CGFloat = 50.0 //width and height of restart node
let kPaddleMoveMult: CGFloat = 1.5 //multiply factor when moving fingers to move the paddles, by moving finger for N pt it will move it for N * kPaddleMoveMult
var powerUpShouldAppear = 0 //powerUp counter till some powerUp should appear
let powerUpTime = 10//time till powerUp appears

//categories for detecting contacts between nodes
let  ballCategory : UInt32 = 0x1 << 0
let cornerCategory : UInt32 = 0x1 << 1
let paddleCategory : UInt32  = 0x1 << 2

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var isPlayingGame: Bool = false
    //ball node
    var ballNode : SKSpriteNode?
    //powerUp node
    var powerUp : SKSpriteNode?
    
    //flaming
    var flaming = false
    var flames : SKEmitterNode?
    var flamingTimer = 0
    var flamingLimit = 3
    
    
    
    
    //paddle nodes
    var playerOnePaddleNode : SKShapeNode!
    var playerTwoPaddleNode : SKShapeNode!
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
    
    var gameBalls: GameBalls?
    
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
        self.playerOnePaddleNode = PaddleCreator.create(.left, paddleWidth: paddleWidth, paddleHeight: paddleHeight, color: SKColor.greenColor(), category: paddleCategory, initialYPos: CGRectGetMidY(self.frame), initialXPos: 2*paddleWidth)
        self.addChild(self.playerOnePaddleNode)
        self.playerTwoPaddleNode = PaddleCreator.create(.right, paddleWidth: paddleWidth, paddleHeight: paddleHeight, color: SKColor.yellowColor(), category: paddleCategory, initialYPos: CGRectGetMidY(self.frame), initialXPos: CGRectGetMaxX(self.frame) - 2*paddleWidth)
        self.addChild(self.playerTwoPaddleNode)
        
        //Score Labels
        self.playerOneScoreNode = NodesCreator.createScoreLabel("Helvetica", fontSize: scoreFontSize, color: SKColor.whiteColor(), xPos: size.width * 0.25, yPos: size.height - scoreFontSize * 2.0)
        self.addChild(self.playerOneScoreNode)
        self.playerTwoScoreNode = NodesCreator.createScoreLabel("Helvetica", fontSize: scoreFontSize, color: SKColor.whiteColor(), xPos: size.width * 0.75, yPos: size.height - scoreFontSize * 2.0)
        self.addChild(self.playerTwoScoreNode)

        //Restart node
        self.restartGameNode = NodesCreator.createRestartGameNode("restartNode.png", height: restartNodeWidthHeight, width: restartNodeWidthHeight, xPos: size.width / 2.0, yPos:  size.height - restartNodeWidthHeight)
        self.addChild(self.restartGameNode)
        
        //start game info node
        self.startGameInfoNode = NodesCreator.createInfoLabel("Helvetica", fontSize: scoreFontSize, color: SKColor.whiteColor(), xPos: size.width / 2.0, yPos: size.height / 2.0, text: "Tap to start!")
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
        self.ballNode = NodesCreator.createBall(ballWidth, ballHeight: ballHeight, ballRadius: ballRadius, category: ballCategory, contact: cornerCategory | paddleCategory, xPos: self.size.width / 2.0, yPos: self.size.height / 2.0)
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
        //Start ball and timer to speedup the ball
        self.ballNode!.physicsBody!.velocity = CGVectorMake(startingVelocityX, startingVelocityY)
        self.speedupTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(kSpeedupInterval), target: self, selector: Selector("speedUpTheBall"), userInfo: nil, repeats: true)
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
        
        powerUpShouldAppear++
        if powerUpShouldAppear >= powerUpTime
        {
            powerUpShouldAppear = 0
            powerUp = PowerUpController().getRandomPowerUp(self.size)
            self.addChild(powerUp!)
        }
        
        if flaming
        {
            flamingTimer++
            if flamingTimer >= flamingLimit{
                flamingTimer = 0
                flames?.removeFromParent()
                println("apaguei")
                let velocity = self.ballNode!.physicsBody!.velocity
                self.ballNode!.physicsBody!.velocity = CGVectorMake(velocity.dx / 2  , velocity.dy / 2)
                flaming = false

            }
            
        }
        
        
        
        
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
        //In case it is the iPad there is a need to multiply the sizes
        var multiplier:CGFloat = 1
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            multiplier = kIpadMultFactor
        }
        //Define the max and min positions that the paddler can move
        var yMax: CGFloat = self.size.height - multiplier*kPaddleHeight / 4.0 - multiplier*kPaddleHeight / 2.0
        var yMin: CGFloat = multiplier*kPaddleHeight / 4.0 + multiplier*kPaddleHeight / 2.0
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
        //In case it is the iPad there is a need to multiply the sizes
        var multiplier:CGFloat = 1
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            multiplier = kIpadMultFactor
        }
        //Define the max and min positions that the paddler can move
        var yMax: CGFloat = self.size.height - multiplier*kPaddleHeight / 4.0 - multiplier*kPaddleHeight / 2.0
        var yMin: CGFloat = multiplier*kPaddleHeight / 4.0 + multiplier*kPaddleHeight / 2.0
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
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == cornerCategory {
            //on point remove power ups on field and put down flames
            
            
            
            //ball touched left side
            if firstBody.node!.position.x <= firstBody.node!.frame.size.width {
                self.pointForPlayer(2)
                self.runAction(self.failSoundAction)
                flaming = false
                powerUp?.removeFromParent()
            }
            else {
                //ball touched the right side
                if firstBody.node!.position.x >= (self.size.width - firstBody.node!.frame.size.width) {
                    self.pointForPlayer(1)
                    self.runAction(self.failSoundAction)
                    flaming = false
                    powerUp?.removeFromParent()
                }
                else {
                    self.runAction(self.bounceSoundAction)
                }
            }
        }
        //Check if we have a ball and pad contact
        else if(firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory){
            self.runAction(self.bounceSoundAction)
            //you can react here if you want to customize the ball movement or direction
            //in original pong direction of the ball after it hits the paddle depends on
            //what part of the paddle does it hit
            //so you can customize it as you want
//            var paddleNode: SKSpriteNode = secondBody.node as! SKSpriteNode
//            var ballPosition: CGPoint = self.ballNode!.position
//            var firstThird: CGFloat = (paddleNode.position.y - paddleNode.size.height / 2.0) + paddleNode.size.height * (1.0 / 3.0)
//            var secondThird: CGFloat = (paddleNode.position.y - paddleNode.size.height / 2.0) + paddleNode.size.height * (2.0 / 3.0)
//            var dx: CGFloat = self.ballNode!.physicsBody!.velocity.dx
//            var dy: CGFloat = self.ballNode!.physicsBody!.velocity.dy
//            if ballPosition.y < firstThird {
//                //ball hits the left part
//                if dy > 0 {
//                    self.ballNode!.physicsBody!.velocity = CGVectorMake(dx, -dy)
//                }
//            }
//            else {
//                if ballPosition.y > secondThird {
//                    //ball hits the left part
//                    if dy < 0 {
//                        self.ballNode!.physicsBody!.velocity = CGVectorMake(dx, -dy)
//                    }
//                }
//            }
        }
        if flaming
        {
            self.flames?.emissionAngle = CGFloat(M_PI ) + atan2(self.ballNode!.physicsBody!.velocity.dy,self.ballNode!.physicsBody!.velocity.dx)
            self.flames?.speed = self.ballNode!.speed
            
        }
        
        
        
        
    }
    
    
  
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.isPlayingGame {
            for touch in touches as! Set<UITouch> {
                //Set touch to move paddles
                var location: CGPoint = touch.locationInNode(self)
                
                
                //Check if a powerUp is being clicked
                let node = self.nodeAtPoint(location)
                if node.name == "flamingBall"
                {
                    let velocity = self.ballNode!.physicsBody!.velocity
                    self.ballNode!.physicsBody!.velocity = CGVectorMake(velocity.dx * 2 , velocity.dy * 2)
                    self.powerUp?.removeFromParent()
                    self.flames = SKEmitterNode(fileNamed: "exampleFire")
                    self.ballNode?.addChild(self.flames!)
                    self.flames?.targetNode = self
                    flaming = true
                    println("pegando fogo")
                    
                }

                
                
                
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
