//
//  GameScene.swift
//  luner
//
//  Created by localadmin on 19.10.18.
//  Copyright © 2018 ch.cqd.luner. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var animator: UIDynamicAnimator?
    var player: SKSpriteNode!
    var floor: SKSpriteNode!
    var cameraX: SKCameraNode!
    var gameOver: SKLabelNode!
    var contactSpeed: SKLabelNode!
    var speedToShow: SKLabelNode!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        makePlayer()
        makeFloor()
        
        self.view?.showsPhysics = true
        scene?.physicsWorld.gravity = CGVector(dx: 0, dy: -1.0)
        
        do {
            let path = Bundle.main.path(forResource: "explosion" , ofType: "wav")!
            let url:URL = URL(fileURLWithPath: path)
            let player:AVAudioPlayer = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch {
            print("crashed loading sound")
        }
        
        cameraX = SKCameraNode()
        scene?.camera = cameraX
        
        doHUD()
    }
    
    func doHUD() {
        let wait = SKAction.wait(forDuration: 1.0)
        let runX = SKAction.run {
            self.showSpeed()
        }
        run(SKAction.sequence([wait, runX]))
        run(SKAction.repeatForever(SKAction.sequence([wait, runX])), withKey: "hud")
    }
    
    func makeFloor() {
        floor = SKSpriteNode(color: UIColor.red, size: CGSize(width: 400, height: 10))
        floor.position = CGPoint(x: 0, y: -350)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 400, height: 10))
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.isDynamic = false
        self.addChild(floor)
    }
    
    func makePlayer() {
        player = SKSpriteNode(imageNamed: "player_frame1")
        
        let playerTexture = SKTexture(image: UIImage(named:"player_frame1")!)
        player.physicsBody = SKPhysicsBody(texture: playerTexture, alphaThreshold: 0, size: (UIImage(named:"player_frame1")?.size)!)
        player.physicsBody?.affectedByGravity = true
        player.position = CGPoint(x: 0, y: 0)
        player.physicsBody?.linearDamping = 0.5
        player.physicsBody?.angularDamping = 0.5
        player.physicsBody?.restitution = 0.2
        player.physicsBody?.friction = 0.2
        player.physicsBody?.mass = 0.1
        player.physicsBody?.allowsRotation = true
        player.physicsBody?.isDynamic = true
        player.physicsBody?.contactTestBitMask = 1
        
        self.addChild(player)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // only tiggered if we set collisions
        
        let hitrate = contact.collisionImpulse
        if hitrate > 8 {
            print("contact exceeded \(contact.collisionImpulse)")
            showContact(contactNo: hitrate)
            let explosion: SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = player.position
            self.addChild(explosion)
            self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
            player.removeFromParent()
            gameover()
            removeAction(forKey: "hud")
        }
    }
    
    @objc func showSpeed() {
        
        if speedToShow == nil {
            speedToShow = SKLabelNode(fontNamed: "HoeflerText-Italic")
            addChild(speedToShow)
        } else {
            let speed2Show = (player.physicsBody?.velocity.dy)!
            speedToShow.text = "\(speed2Show)"
            speedToShow.fontSize = 16
            speedToShow.fontColor = SKColor.green
            speedToShow.position = CGPoint(x: frame.midX, y: (scene?.frame.minY)!/2 - 96)
        }
        
    }
    
    func showContact(contactNo: CGFloat) {
        if contactSpeed == nil {
            contactSpeed = SKLabelNode(fontNamed: "HoeflerText-Italic")
            addChild(contactSpeed)
        } else {
            contactSpeed.text = "\(contactNo)"
            contactSpeed.fontSize = 16
            contactSpeed.fontColor = SKColor.green
            contactSpeed.position = CGPoint(x: frame.midX, y: (scene?.frame.minY)!/2 - 48)
        }
        
    }
    
    func gameover() {
        gameOver = SKLabelNode(fontNamed: "HoeflerText-Italic")
        gameOver.text = "Game Over"
        gameOver.fontSize = 65
        gameOver.fontColor = SKColor.green
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOver)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.texture = SKTexture(image:UIImage(named:"player_frame2")!)
        // one time application
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 24))
        if gameOver != nil {
            if gameOver.parent != nil {
                makePlayer()
                gameOver.removeFromParent()
                gameOver = nil
                contactSpeed.removeFromParent()
                doHUD()
            }
        }
        // continous force over time
//        player.physicsBody?.applyForce(CGVector(dx: 0, dy: 1000))
        
//        player.physicsBody?.velocity = CGVector(dx: 0, dy: 1200)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.texture = SKTexture(image:UIImage(named:"player_frame3")!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.texture = SKTexture(image:UIImage(named:"player_frame1")!)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if (!intersects(player)) {
            if cameraX.parent == nil {
//                cameraX.position.y = 200
                player.addChild(cameraX)
            }
        } else {
            if cameraX != nil {
                cameraX.removeFromParent()
            }
        }
        let rateOfDecent = (player.physicsBody?.velocity.dy)!
        let speedOfDecent = (player.physicsBody?.angularVelocity)!
        print("\(rateOfDecent) \(speedOfDecent)")
        
    }
    
}
