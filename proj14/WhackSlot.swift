//
//  WhackSlot.swift
//  proj14
//
//  Created by dh on 10/9/16.
//  Copyright © 2016 dhfromkorea. All rights reserved.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    var isVisible = false
    var isHit = false    
    
    func configure(at position: CGPoint) {
        self.position = position
        let whackHole = SKSpriteNode(imageNamed: "whackHole")
        addChild(whackHole)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        
        cropNode.addChild(charNode)
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        guard !isVisible else { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        let action = SKAction.moveBy(x: 0, y: 80, duration: 0.05)
        charNode.run(action)
        isVisible = true
        isHit = false
        
        if RandomInt(min: 0, max: 2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"

        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (3.5 * hideTime)) { [unowned self] in
            self.hide()
        }
    }
    
    func hide() {
        guard isVisible else { return }
        let action = SKAction.moveBy(x: 0, y: -80, duration: 0.05)
        charNode.run(action)
        isVisible = false
    }
    
    func hit(completion: () -> Void) {
        guard isVisible else { return }
        guard !isHit else { return }

        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false}
        charNode.run(SKAction.sequence([delay, hide, notVisible]))
        
        completion()
    }
}
