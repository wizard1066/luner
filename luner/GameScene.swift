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
    var gameOver: SKLabelNode!
    var contactSpeed: SKLabelNode!
    var speedToShow: SKLabelNode!
    var gestureAction = false
    var solarWind: UIFieldBehavior!
    var mainfire: SKEmitterNode?
    var point: SKSpriteNode!
    
    var fuel: Int!
    var fullTank: Int!
    var fullCircle: CGFloat!
    
    var cameraX: SKCameraNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.physicsWorld.contactDelegate = self
        cameraX = SKCameraNode()
        scene?.physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        scene?.camera = cameraX
        
        
        fullTank = 3600
        fuel = fullTank
        fullCircle = 110
        // ping
        let gauge = SKSpriteNode(imageNamed: "gauge")
        point = SKSpriteNode(imageNamed: "pointX")
        
        
        gauge.position = CGPoint(x: 0, y: 500)
        point.position = CGPoint(x: 0, y: 450)
        point.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        
       
        
        
        
        
        addChild(point)
        addChild(gauge)
        
        makePlayer()
        makeFloor()
        
        self.view?.showsPhysics = true
        
        cameraX = SKCameraNode()
        scene?.physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        scene?.camera = cameraX
        
        doHeadsUpDisplay()
        enableGestures()
        preloadSound()
        
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })

        // example of serious BUG in iOS
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            print("now")
//            self.solarWind = UIFieldBehavior.radialGravityField(position: CGPoint(x: -320, y: 0))
//            self.solarWind.region = UIRegion(size: CGSize(width: 750, height: 750))
//            self.solarWind.strength = 0.5
//            self.solarWind.falloff = 2
//            self.solarWind.minimumRadius = 0.05
//            self.animator = UIDynamicAnimator(referenceView: self.view!)
//            self.animator.setValue(true, forKey: "debugEnabled")
//            self.animator.addBehavior(self.solarWind)
//        }
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
        if player != nil {
            player.isHidden = false
            return
        }
        player = TouchableSpriteNode(imageNamed: "player_frame1")
        player.boxDelegate = self
        
        
        
        let playerTexture = SKTexture(image: UIImage(named:"player_frame1")!)
        player.physicsBody = SKPhysicsBody(texture: playerTexture, alphaThreshold: 0, size: (UIImage(named:"player_frame1")?.size)!)
        player.physicsBody?.affectedByGravity = true
        
        
        
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width,height: player.size.height))

        
        
        
        
        
        
        
        
        
        
        
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
        mainfire = SKEmitterNode(fileNamed: "MainFire")!
        mainfire!.position = CGPoint(x: 0, y: -30)
        mainfire?.isHidden = true
        player.addChild(mainfire!)
        self.addChild(player)
    }
    
    func setScene() -> CGPoint {
        let xScene = scene?.view?.bounds.midX
        let yScene = scene?.view?.bounds.maxY
        let sceneBottom = scene?.convertPoint(fromView:CGPoint(x:xScene!,y:yScene!))
        let nodeBottom = floor.convert(sceneBottom!,from:scene!)
        return nodeBottom
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // only tiggered if we set collisions
        mainfire?.isHidden = true
        let hitrate = contact.collisionImpulse
        if hitrate > 5 {
            // zRotation result is in radians shows rotation of player sprite
//            print("contact exceeded \(contact.collisionImpulse) \(player.zRotation)")
//            showContact(contactNo: hitrate)
            
            let explode = SKAction.run {
                self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
                let explosion: SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
                explosion.position = self.player.position
                self.addChild(explosion)
                self.player.isHidden = true
            }
            let waitAction = SKAction.wait(forDuration: 4)
            let fadeOut = SKAction.fadeOut(withDuration: 4)
            let sequence = SKAction.sequence([explode, waitAction, fadeOut])
            player.run(sequence)
//            player.removeFromParent()
            gameover()
            removeAction(forKey: "hud")
        }
    }
    
    @objc func showSpeed() {
        if speedToShow == nil {
            speedToShow = SKLabelNode(fontNamed: "Futura-Medium")
            addChild(speedToShow)
        } else {
            let speed2Show = (player.physicsBody?.velocity.dy)!
            speedToShow.text = "\(speed2Show)"
            speedToShow.fontSize = 16
            speedToShow.fontColor = SKColor.green
            speedToShow.position = CGPoint(x: frame.midX, y: (scene?.frame.maxX)!/2 + 96)
        }
    }
    
    func showContact(contactNo: CGFloat) {
        if contactSpeed == nil {
            contactSpeed = SKLabelNode(fontNamed: "Futura-Medium")
            addChild(contactSpeed)
        } else {
            contactSpeed.text = "\(contactNo)"
            contactSpeed.fontSize = 16
            contactSpeed.fontColor = SKColor.green
            contactSpeed.position = CGPoint(x: frame.midX, y: (scene?.frame.maxY)!/2 + 48)
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
        
        
        player.texture =  SKTexture(image:UIImage(named:"player_frame2")!)
        // one time application
//        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 16))
//
//        fuel = fuel - 500
        mainfire?.isHidden = false
        removeAction(forKey: "fire")
//        mainfire?.run(SKAction.fadeIn(withDuration: 0))
        if gameOver != nil {
            if gameOver.parent != nil {
                makePlayer()
                fuel = 3600
                gameOver.removeFromParent()
                gameOver = nil
//                contactSpeed.removeFromParent()
                doHeadsUpDisplay()
            }
        }
        // continous force over time
//        player.physicsBody?.applyForce(CGVector(dx: 0, dy: 1000))
        
//        player.physicsBody?.velocity = CGVector(dx: 0, dy: 1200)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        player.texture = SKTexture(image:UIImage(named:"player_frame3")!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        player.texture = SKTexture(image:UIImage(named:"player_frame1")!)
        mainfire?.run(SKAction.fadeOut(withDuration: 1), withKey: "fire")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//        if (!intersects(player)) {
//            if cameraX.parent == nil {
////                cameraX.position.y = 200
//                player.addChild(cameraX)
//            }
//        } else {
//            if cameraX != nil {
//                cameraX.removeFromParent()
//            }
//        }
//        let rateOfDecent = (player.physicsBody?.velocity.dy)!
//        let speedOfDecent = (player.physicsBody?.angularVelocity)!
        fuel = fuel - 1
//        print("\(fuel) ")
        // furmula for fuel angle
//        point.zRotation = X
        
    }
    
    func enableGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view!.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view!.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToGesture))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view!.addGestureRecognizer(swipeDown)
        
        
        
        
        
        
        
        
        
        
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.respondToGesture))
        tap.numberOfTouchesRequired = 1
        self.view!.addGestureRecognizer(tap)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        tapGesture.numberOfTapsRequired = 2
//        self.view!.addGestureRecognizer(tapGesture)
    }
    
    @objc func respondToGesture(gesture: UIGestureRecognizer) {
        if fuel  <  0 {
            mainfire?.run(SKAction.fadeOut(withDuration: 1))
            return
        }
        
//        gestureAction = true
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right")
//                player.physicsBody?.applyImpulse(CGVector(dx: 4, dy: 4))
            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
//                player.physicsBody?.applyImpulse(CGVector(dx: -4, dy: 4))
            default:
                break
            }
        }
        
        if let _ = gesture as? UITapGestureRecognizer {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 12))
            fuel = fuel - 500
            let roast:CGFloat = CGFloat(CGFloat(fuel)/CGFloat(fullTank))
            let degrees = fullCircle - CGFloat(120) * CGFloat(roast)
            fullCircle -= degrees
            let radians = degrees * CGFloat.pi / 180

            point.run(SKAction.rotate(byAngle: radians, duration: 0))
//            print("fuel \(fuel!) FT \(fullCircle) radians \(radians) degrees \(degrees)")
            
        }
    }
    
}


