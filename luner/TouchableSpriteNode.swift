//
//  TouchableSpriteNode.swift
//  luner
//
//  Created by localadmin on 20.10.18.
//  Copyright © 2018 ch.cqd.luner. All rights reserved.
//

import SpriteKit

protocol BoxDelegate: NSObjectProtocol {
    func boxSwiped(box: TouchableSpriteNode)
}

//weak var boxDelegate: BoxDelegate!

class TouchableSpriteNode : SKSpriteNode
{
    weak var boxDelegate: BoxDelegate!
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 4))
        print("WTF")
        boxDelegate.boxSwiped(box: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
}
