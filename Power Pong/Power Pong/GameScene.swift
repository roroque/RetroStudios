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
var highScore = 3//maximum punctuation of the game

//categories for detecting contacts between nodes
let ballCategory : UInt32 = 0x1 << 0
let cornerCategory : UInt32 = 0x1 << 1
let paddleCategory : UInt32  = 0x1 << 2
let powerUpCategory : UInt32 = 0x1 << 3

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var isPlayingGame: Bool = false
    //ball node
    var ballNode : [SKSpriteNode] = []
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
    //var restartGameNode : SKSpriteNode!
    //Return to menu node
    var returnToMenuNode : SKSpriteNode!
    //start game info node
    var startGameInfoNode : SKLabelNode!
    var outlineGameInfoNode : SKLabelNode!
    var backgroundStartGameInfoNode : SKShapeNode!
    
    //winner info node
    var winnerInfoNode : SKLabelNode!
    //touches
    var playerOnePaddleControlTouch : UITouch?
    var playerTwoPaddleControlTouch : UITouch?
    //score
    var playerOneScore : Int = 0
    var playerTwoScore : Int = 0
    //timer for speed-up
    var speedupTimer : NSTimer?
    //timer for powerUp
    var powerUpTimer : NSTimer?
    //sounds
    var bounceSoundAction : SKAction?
    var failSoundAction : SKAction?
    
    var firstRound: Bool = true
    var paddleWithBall: Int = 1
    var winner: Int = 0
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //Setup point limit of the game
        let defaults = NSUserDefaults.standardUserDefaults()
        highScore = defaults.integerForKey("PointLimit")
        
        //Setup the scene
        self.backgroundColor = SKColor.brownColor()
        var background = NodesCreator.createBackgroud(self.size)
        background.zPosition = -2
        self.addChild(background)
        
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
//        var numberOfLines = Int(size.height / (2 * middleLineHeight))
//        var linePosition: CGPoint = CGPointMake(size.width / 2.0, middleLineHeight * 1.5)
//        for var i = 0; i < numberOfLines; i++ {
//            var lineNode: SKSpriteNode = SKSpriteNode(color: SKColor(white: 1.0, alpha: 0.5), size: CGSizeMake(middleLineWidth, middleLineHeight))
//            lineNode.position = linePosition
//            linePosition.y += 2 * middleLineHeight
//            self.addChild(lineNode)
//        }
        
        //Paddles
        self.playerOnePaddleNode = PaddleCreator.create(.left, paddleWidth: paddleWidth, paddleHeight: paddleHeight, color: SKColor.whiteColor(), category: paddleCategory, initialYPos: CGRectGetMidY(self.frame), initialXPos: 2*paddleWidth)
        self.addChild(self.playerOnePaddleNode)
        self.playerTwoPaddleNode = PaddleCreator.create(.right, paddleWidth: paddleWidth, paddleHeight: paddleHeight, color: SKColor.whiteColor(), category: paddleCategory, initialYPos: CGRectGetMidY(self.frame), initialXPos: CGRectGetMaxX(self.frame) - 2*paddleWidth)
        self.addChild(self.playerTwoPaddleNode)
        
        //Score Labels
        self.playerOneScoreNode = NodesCreator.createScoreLabel("Helvetica", fontSize: scoreFontSize, color: SKColor.whiteColor(), xPos: size.width * 0.25, yPos: size.height - scoreFontSize * 2.0)
        self.addChild(self.playerOneScoreNode)
        self.playerTwoScoreNode = NodesCreator.createScoreLabel("Helvetica", fontSize: scoreFontSize, color: SKColor.whiteColor(), xPos: size.width * 0.75, yPos: size.height - scoreFontSize * 2.0)
        self.addChild(self.playerTwoScoreNode)

        //Restart node
        //self.restartGameNode = NodesCreator.createRestartGameNode("restartNode.png", height: restartNodeWidthHeight, width: restartNodeWidthHeight, xPos: size.width / 2.0, yPos:  size.height - restartNodeWidthHeight)
        //self.addChild(self.restartGameNode)
        
        //Return to menu node
        self.returnToMenuNode = NodesCreator.createRestartGameNode("return", height: restartNodeWidthHeight, width: restartNodeWidthHeight, xPos: size.width / 2.0, yPos:  size.height - restartNodeWidthHeight)
        self.addChild(self.returnToMenuNode)
        
        //start game info node
        self.startGameInfoNode = NodesCreator.createInfoLabel("Helvetica", fontSize: scoreFontSize, color: SKColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0), xPos: size.width / 2.0, yPos: size.height / 2.0, text: "Tap to start!")
        self.addChild(self.startGameInfoNode)
        
        self.outlineGameInfoNode = NodesCreator.createInfoLabel("Helvetica", fontSize: scoreFontSize, color: SKColor.blackColor(), xPos: 2, yPos: 2, text: startGameInfoNode.text)
        self.outlineGameInfoNode.zPosition = -1
        self.startGameInfoNode.addChild(self.outlineGameInfoNode)
        
        self.backgroundStartGameInfoNode = SKShapeNode(rectOfSize: CGSize(width: self.startGameInfoNode.fontSize * 5.5, height: self.startGameInfoNode.fontSize * 1.8), cornerRadius: 20)
        self.backgroundStartGameInfoNode.fillColor = UIColor.whiteColor()
        self.backgroundStartGameInfoNode.alpha = 0.45
        //self.backgroundStartGameInfoNode.zPosition = -1
        self.backgroundStartGameInfoNode.lineWidth = 0
        self.backgroundStartGameInfoNode.position = CGPoint(x: 0, y: self.startGameInfoNode.fontSize/3)
        self.startGameInfoNode.addChild(self.backgroundStartGameInfoNode)
        
        //winner info node
        self.winnerInfoNode = NodesCreator.createInfoLabel("Helvetica", fontSize: scoreFontSize, color: SKColor.whiteColor(), xPos: size.width / 2.0, yPos: size.height / 4.0, text: "")
        self.addChild(self.winnerInfoNode)
        
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
        self.winnerInfoNode.hidden = true
        //self.restartGameNode.hidden = false
        self.returnToMenuNode.hidden = true

        
        var ballWidth: CGFloat = kBallRadius * 2.0
        var ballHeight: CGFloat = kBallRadius * 2.0
        var ballRadius: CGFloat = kBallRadius
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            ballWidth *= kIpadMultFactor;
            ballHeight *= kIpadMultFactor;
            ballRadius *= kIpadMultFactor;
        }
        
        //Create the ball
        if firstRound {
            self.ballNode.append (NodesCreator.createBall(ballWidth, ballHeight: ballHeight, ballRadius: ballRadius, category: ballCategory, contact: cornerCategory | paddleCategory, xPos: self.size.width / 2.0, yPos: self.size.height / 2.0))
            self.addChild(self.ballNode.first!)
        }else{
        
            if winner == 1{
                positionPlayerOnePaddleNode()
                self.addChild(self.ballNode.first!)
            }else{
                positionPlayerTwoPaddleNode()
                self.addChild(self.ballNode.first!)
            }
        }
        
        var startingVelocityX: CGFloat = kStartingVelocityX
        var startingVelocityY: CGFloat = kStartingVelocityY
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
            startingVelocityX *= kIpadMultFactor
            startingVelocityY *= kIpadMultFactor
        }
        startingVelocityX = sqrt( startingVelocityX * startingVelocityX + startingVelocityY * startingVelocityY)
        if self.paddleWithBall == 2 {
            startingVelocityX = -startingVelocityX
        }
        startingVelocityY = 0 
        
        //Start ball and timer to speedup the ball
        self.ballNode.first!.physicsBody!.velocity = CGVectorMake(startingVelocityX, startingVelocityY)
        
        self.speedupTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(kSpeedupInterval), target: self, selector: Selector("speedUpTheBall"), userInfo: nil, repeats: true)
        self.powerUpTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(kSpeedupInterval), target: self, selector: Selector("powerItUp"), userInfo: nil, repeats: true)
        firstRound = false
    }
    
    func restartTheGame() {
        //Remove the ball
        self.ballNode.first!.removeFromParent()
        //Stop Timer
        self.speedupTimer!.invalidate()
        //self.speedupTimer = nil
        self.powerUpTimer?.invalidate()
        
        self.isPlayingGame = false
        self.winnerInfoNode.hidden = false
        self.startGameInfoNode.hidden = false
        //self.restartGameNode.hidden = true
        
        self.returnToMenuNode.hidden = false

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
    
    func endOfTheGame(){
        //Show the back arrow, in case the user wants to go to the menu
        self.returnToMenuNode.hidden = false
        
        //Check if the game is over
        if (self.playerOneScore == highScore)&&(highScore != 0) {
            self.playerOneScoreNode.removeAllActions()
            self.winnerInfoNode.text = "Player 1 wins!"
            self.restartTheGame()
        }else if (self.playerTwoScore == highScore)&&(highScore != 0) {
            self.playerTwoScoreNode.removeAllActions()
            self.winnerInfoNode.text = "Player 2 wins!"
            self.restartTheGame()
        }
        changeColorForLabelNode(self.winnerInfoNode, toColor: SKColor(red: 218/255, green: 91/255, blue: 28/255, alpha: 1.0), withDuration: 5.0)
    }
    
    func changeColorForLabelNode(labelNode: SKLabelNode, toColor: SKColor, withDuration: NSTimeInterval) {
        labelNode.runAction(SKAction.customActionWithDuration(withDuration, actionBlock: {
            node, elapsedTime in
            
            let label = node as! SKLabelNode
            
            let toColorComponents = CGColorGetComponents(toColor.CGColor)
            let fromColorComponents = CGColorGetComponents(label.fontColor.CGColor)
            
            let finalRed = fromColorComponents[0] + (toColorComponents[0] - fromColorComponents[0])*CGFloat(elapsedTime / CGFloat(withDuration))
            let finalGreen = fromColorComponents[1] + (toColorComponents[1] - fromColorComponents[1])*CGFloat(elapsedTime / CGFloat(withDuration))
            let finalBlue = fromColorComponents[2] + (toColorComponents[2] - fromColorComponents[2])*CGFloat(elapsedTime / CGFloat(withDuration))
            let finalAlpha = fromColorComponents[3] + (toColorComponents[3] - fromColorComponents[3])*CGFloat(elapsedTime / CGFloat(withDuration))
            
            labelNode.fontColor = SKColor(red: finalRed, green: finalGreen, blue: finalBlue, alpha: finalAlpha)
        }))
    }
    
    
    func goBackToMenu(){
        //Return to the menu
        if((self.delegate?.respondsToSelector(Selector("returnToMenu"))) == true){
            let returnEnabled = self.delegate as! returnToMenu
            returnEnabled.returnToMenu()
        }
    }
    
    
    func pointForPlayer(player: Int, ball: SKSpriteNode){
        
        switch player {
        case 1:
            self.playerOneScore++
            self.paddleWithBall = 2
            ball.physicsBody!.velocity = CGVector.zeroVector
            ball.removeFromParent()
            //check if there are no more balls in game
            self.isPlayingGame = false
            //self.startGameInfoNode.hidden = false
            //self.restartGameNode.hidden = true
            self.speedupTimer!.invalidate()
            self.powerUpTimer!.invalidate()
            
            positionPlayerOnePaddleNode()
            self.playerTwoPaddleNode.addChild(self.ballNode.first!)
            self.winner = 1
            animateScore(winner)
            println("ponto1")
    
            //self.speedupTimer = nil
        case 2:
            self.playerTwoScore++
            self.paddleWithBall = 1
            ball.physicsBody!.velocity = CGVector.zeroVector
            ball.removeFromParent()
            self.winner = 2
            animateScore(winner)
            //check if there are no more balls in game
            
            
            self.isPlayingGame = false
            //self.startGameInfoNode.hidden = false
            //self.restartGameNode.hidden = true
            self.speedupTimer!.invalidate()
            self.powerUpTimer!.invalidate()

            
            positionPlayerTwoPaddleNode()
            self.playerOnePaddleNode.addChild(self.ballNode.first!)

             println("ponto2")
        default:
            println()
        }
        self.updateScoreLabels()
        self.endOfTheGame()
    }
    
    func positionPlayerOnePaddleNode(){
        let tempPhysicsBody = self.ballNode.first!.physicsBody
        self.ballNode.first!.physicsBody = nil
        self.ballNode.first!.position = CGPointMake(self.playerTwoPaddleNode.position.x - 45, self.playerTwoPaddleNode.position.y)
        self.ballNode.first!.physicsBody = tempPhysicsBody

    }
    
    func positionPlayerTwoPaddleNode(){
        let tempPhysicsBody = self.ballNode.first!.physicsBody
        self.ballNode.first!.physicsBody = nil
        self.ballNode.first!.position = CGPointMake(self.playerOnePaddleNode.position.x + 45, self.playerOnePaddleNode.position.y)
        self.ballNode.first!.physicsBody = tempPhysicsBody

    }
    
    func animateScore(point: Int)
    {
        let growAction = SKAction.scaleBy(1.2, duration: 0.4)
        let shrinkAction = SKAction.scaleBy(0.8333, duration: 0.4)
        let growAndShrink = SKAction.sequence([growAction, shrinkAction])
        
        if point == 1{
            self.playerOneScoreNode.runAction(SKAction.repeatAction(growAndShrink, count: 3))
        }else{
            self.playerTwoScoreNode.runAction(SKAction.repeatAction(growAndShrink, count: 3))
        }
    }

    override func willMoveFromView(view: SKView) {
        //reset timer
        self.speedupTimer!.invalidate()
        self.powerUpTimer?.invalidate()
    }
    
    
    //method called by the timer
    func powerItUp()
    {
        
        powerUpShouldAppear++
        if powerUpShouldAppear >= powerUpTime
        {
            if self.powerUp != nil
            {
                self.powerUp?.removeFromParent()
            }
            powerUpShouldAppear = 0
            self.powerUp = PowerUpController().getRandomPowerUp(self.size)
            
            self.addChild(powerUp!)
            self.powerUp!.physicsBody!.categoryBitMask = powerUpCategory
            self.powerUp!.physicsBody!.collisionBitMask = 0
            self.powerUp?.physicsBody!.contactTestBitMask = ballCategory
            
        }
        if flaming
        {
            println(flamingTimer)
            flamingTimer++
            if flamingTimer >= flamingLimit{
                println("apaguei")
                let velocity = self.ballNode.first!.physicsBody!.velocity
                for i in self.ballNode
                {
                    i.physicsBody!.velocity = CGVectorMake(velocity.dx / 2  , velocity.dy / 2)
                }
                resetFlames()
                
            }
            
        }


        
    }
    
    
    //Method called by the timer
    func speedUpTheBall() {
        var velocityX: CGFloat = self.ballNode.first!.physicsBody!.velocity.dx * kVelocityMultFactor
        var velocityY: CGFloat = self.ballNode.first!.physicsBody!.velocity.dy * kVelocityMultFactor
        for i in self.ballNode
        {
            i.physicsBody!.velocity = CGVectorMake(velocityX, velocityY)
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
      
        //check if passed through a powerUp
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == powerUpCategory
        {
            resetPowerUp()
            resetFlames()
            //check if the powerUp is the flamingBall
            if powerUp!.name == "flamingBall"
            {
                let velocity = self.ballNode.first!.physicsBody!.velocity
                //remember to set more than one flame
                self.flames = SKEmitterNode(fileNamed: "exampleFire")

                for i in self.ballNode
                {
                    i.physicsBody!.velocity = CGVectorMake(velocity.dx * 2 , velocity.dy * 2)
                }
                
                self.ballNode.first!.addChild(self.flames!)
                self.flames?.targetNode = self
                flaming = true
                println("pegando fogo")
                
            }
            return

            
        }
        
        
        
        //Check if we have a ball with a corner contact
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == cornerCategory {
            
            //ball touched left side
            if firstBody.node!.position.x <= firstBody.node!.frame.size.width {
                self.pointForPlayer(2,ball: firstBody.node as! SKSpriteNode)
                self.runAction(self.failSoundAction)
                resetFlames()
                resetPowerUp()

            }
            else {
                //ball touched the right side
                if firstBody.node!.position.x >= (self.size.width - firstBody.node!.frame.size.width) {
                    self.pointForPlayer(1,ball: firstBody.node as! SKSpriteNode)
                    self.runAction(self.failSoundAction)
                    resetFlames()
                    resetPowerUp()

                }
                else {
                    self.runAction(self.bounceSoundAction)
                }
            }
        }
        //Check if we have a ball and pad contact
        else if(firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory){
            self.runAction(self.bounceSoundAction)
            
        }
        //change flames direction
        if flaming
        {
            self.flames?.emissionAngle = CGFloat(M_PI ) + atan2(self.ballNode.first!.physicsBody!.velocity.dy,self.ballNode.first!.physicsBody!.velocity.dx)
            self.flames?.speed = self.ballNode.first!.speed
            
        }
    }
    
    //reset flames
    func resetFlames()
    {
        flaming = false
        flamingTimer = 0
        self.flames?.removeFromParent()
    }
    
    //reset powerUp
    func resetPowerUp()
    {
        powerUp?.removeFromParent()
        powerUpShouldAppear = 0
        
    }
    
    
  
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.isPlayingGame {
            for touch in touches as! Set<UITouch> {
                //Set touch to move paddles
                var location: CGPoint = touch.locationInNode(self)
                
                
                //Check if a powerUp is being clicked
                let node = self.nodeAtPoint(location)
                
                if node == self.returnToMenuNode{
                    println("return")
                }
                
                
                //Check if it is at the restart node
//                if CGRectContainsPoint(self.restartGameNode.frame, location) {
//                    self.restartTheGame()
//                    return
//                }
                
                
                
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
            for touch in touches as! Set<UITouch> {
                var location: CGPoint = touch.locationInNode(self)
                let node = self.nodeAtPoint(location)
                if node == self.returnToMenuNode{
                    self.goBackToMenu()
                }
                self.returnToMenuNode.hidden = true
                
                if node != self.playerOnePaddleNode && node != self.playerTwoPaddleNode {
                    //Start Playing
                    self.ballNode.first?.removeFromParent()

                    self.startPlayingTheGame()

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
