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

class GameScene: SKScene, SKPhysicsContactDelegate, BoxDelegate {
    
    func boxSwiped(box: TouchableSpriteNode) {
        player.zRotation = 0
    }
    
    var animator:UIDynamicAnimator!
    var player: TouchableSpriteNode!
    var floor: SKSpriteNode!
    var cameraX: SKCameraNode!
    var gameOver: SKLabelNode!
    var contactSpeed: SKLabelNode!
    var speedToShow: SKLabelNode!
    var gestureAction = false
    var solarWind: UIFieldBehavior!
    var mainfire: SKEmitterNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        
        makePlayer()
        makeFloor()
        
        self.view?.showsPhysics = true
        
        cameraX = SKCameraNode()
        scene?.physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        scene?.camera = cameraX
        
        doHeadsUpDisplay()
        enableGestures()
        preloadSound()

        // example of serious BUG in iOS
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print("now")
            self.solarWind = UIFieldBehavior.radialGravityField(position: CGPoint(x: -320, y: 0))
            self.solarWind.region = UIRegion(size: CGSize(width: 750, height: 750))
            self.solarWind.strength = 0.5
            self.solarWind.falloff = 2
            self.solarWind.minimumRadius = 0.05
            self.animator = UIDynamicAnimator(referenceView: self.view!)
            self.animator.setValue(true, forKey: "debugEnabled")
            self.animator.addBehavior(self.solarWind)
        }
    }
    
    func preloadSound() {
        do {
            let path = Bundle.main.path(forResource: "explosion" , ofType: "wav")!
            let url:URL = URL(fileURLWithPath: path)
            let player:AVAudioPlayer = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch {
            print("crashed loading sound")
        }
    }
    
    func doHeadsUpDisplay() {
        let wait = SKAction.wait(forDuration: 1.0)
        let runX = SKAction.run {
            self.showSpeed()
        }
        run(SKAction.sequence([wait, runX]))
        run(SKAction.repeatForever(SKAction.sequence([wait, runX])), withKey: "hud")
    }
    
    func makeFloor() {
//        floor = SKSpriteNode(color: UIColor.green, size: CGSize(width: 400, height: 10))
        let floorTexture = SKTexture(image: UIImage(named:"floor")!)
        let floorImage = UIImage(named:"floor")
        floor = SKSpriteNode(imageNamed: "floor")
        floor.physicsBody = SKPhysicsBody(texture: floorTexture, alphaThreshold: 0.5, size: (floorImage?.size)!)
//        floor.physicsBody = SKPhysicsBody(texture: floorTexture,
//                                          size: CGSize(width: floorTexture.size().width,
//                                                       height: floorTexture.size().height))
        floor.position = CGPoint(x: 0, y: -350)
//        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 400, height: 10))
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.isDynamic = false
        // angle floor //
//        let radAngle = CGFloat(10) * .pi / 180
//        let radAngle:CGFloat = 0.3745
//        let rotationAction = SKAction.rotate(toAngle: radAngle, duration: 0.5)
//        floor.run(rotationAction)
        self.addChild(floor)
    }
    
    func makePlayer() {
//        player = SKSpriteNode(imageNamed: "player_frame1")
        player = TouchableSpriteNode(imageNamed: "player_frame1")
        player.boxDelegate = self
        let playerTexture = SKTexture(image: UIImage(named:"player_frame1")!)
//        player.texture = playerTexture
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
        player.name = "lunar"
        player.isUserInteractionEnabled = true
        
        
        self.addChild(player)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // only tiggered if we set collisions
        mainfire?.removeFromParent()
        mainfire = nil
        let hitrate = contact.collisionImpulse
        if hitrate > 6 {
            // zRotation result is in radians shows rotation of player sprite
            print("contact exceeded \(contact.collisionImpulse) \(player.zRotation)")
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
        print("touchDown \(pos)")
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        print("touchMoved \(pos)")
    }
    
    func touchUp(atPoint pos : CGPoint) {
        print("touchUp \(pos)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gestureAction { gestureAction = false; return }
        let pointTouched = touches.first?.location(in: self.view)
        
        if pointTouched!.x < (self.view?.bounds.minX)! + 128 {
//            print("LeftSide")
            player.physicsBody?.applyImpulse(CGVector(dx: -4, dy: 4))
            return
        }
        if pointTouched!.x > (self.view?.bounds.maxX)! - 128 {
//            print("RightSide")
            player.physicsBody?.applyImpulse(CGVector(dx: 4, dy: 4))
            return
        }
        
        player.texture = SKTexture(image:UIImage(named:"player_frame2")!)
        // one time application
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 16))
        if mainfire == nil {
            mainfire = SKEmitterNode(fileNamed: "MainFire")!
            mainfire!.position = CGPoint(x: 0, y: -30)
            player.addChild(mainfire!)
        }
        
        if gameOver != nil {
            if gameOver.parent != nil {
                makePlayer()
                gameOver.removeFromParent()
                gameOver = nil
                contactSpeed.removeFromParent()
                doHeadsUpDisplay()
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
//        print("\(rateOfDecent) \(speedOfDecent)")
        
    }
    
    func enableGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view!.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view!.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view!.addGestureRecognizer(swipeDown)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        tapGesture.numberOfTapsRequired = 2
//        self.view!.addGestureRecognizer(tapGesture)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        gestureAction = true
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right")
                player.physicsBody?.applyImpulse(CGVector(dx: 4, dy: 4))
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
                player.physicsBody?.applyImpulse(CGVector(dx: -4, dy: 4))
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
            }
        }
//        if let _ = gesture as? UITapGestureRecognizer {
//            player.zRotation = 0
//        }
    }
    
}


