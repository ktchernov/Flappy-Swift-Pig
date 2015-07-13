//
//  GameScene.swift
//  Flappy Swift Pig
//
//  Created by Konstantin Tchernov on 12/07/15.
//  Copyright (c) 2015 Konstantin Tchernov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var pig = SKNode()
    
    var pipeUpTexture = SKTexture()
    var pipeDownTexture = SKTexture()
    var PipesMoveAndRemove = SKAction()
    
    let kPipeGap = 170.0
    
    let kPigCategory = UInt32(1 << 2)
    
    
    var gameOver = false
    
    override func didMoveToView(view: SKView) {
        pig = childNodeWithName("PigNode")!
        
        pig.physicsBody!.categoryBitMask = kPigCategory
        
        self.physicsWorld.gravity = CGVectorMake(0, -7.0)
        self.physicsWorld.contactDelegate = self
        
        pipeUpTexture = SKTexture(imageNamed:"PipeUp")
        pipeDownTexture = SKTexture(imageNamed:"PipeDown")
        
        // movement of pipes
        
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeUpTexture.size().width)
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        
        PipesMoveAndRemove = SKAction.sequence([movePipes,removePipes])
        
        //Spawn Pipes
        
        let spawn  = SKAction.runBlock({() in self.spawnPipes()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever, withKey:"SpawnPipesAction")
    }
    
    func spawnPipes() {
        
        let pipePair = SKNode()
        pipePair.position = CGPointMake(self.frame.size.width + pipeUpTexture.size().width * 2, 0)
        pipePair.zPosition = -10
        
        let height = UInt32(self.frame.size.height / 6)
        let y = arc4random() % height + height
        
        let pipeDown = SKSpriteNode(texture: pipeDownTexture)
        pipeDown.setScale(2.0)
        pipeDown.position = CGPointMake(0.0, CGFloat(y) + pipeDown.size.height + CGFloat(kPipeGap))
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize:pipeDown.size)
        pipeDown.physicsBody!.dynamic = false
        pipeDown.physicsBody!.contactTestBitMask = kPigCategory
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody!.dynamic = false
        pipeUp.physicsBody!.contactTestBitMask = kPigCategory
        pipePair.addChild(pipeUp)
        
        pipePair.runAction(PipesMoveAndRemove, withKey:"PipesMoveAction")
        self.addChild(pipePair)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (!gameOver) {
            pig.physicsBody!.velocity = CGVectorMake(0, 0)
            pig.physicsBody!.applyImpulse(CGVectorMake(0, 50))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (!gameOver) {
            gameOver = true
            pig.physicsBody!.collisionBitMask = 0
            pig.physicsBody!.velocity = CGVectorMake(0, -20)

            removeAllActions()
        }
    }
}
