import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var slots = [WhackSlot]()
    var popupTime = 0.85
    var numOfRounds = 0
    
    override func didMove(to view: SKView) {
        setBackground()
        setGameScore()
        createSlots()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let name = node.name else { continue }
            
            switch name {
            case "charFriend":
                let whackSlot = node.parent!.parent as! WhackSlot
                
                whackSlot.hit() { [unowned self] in
                    self.score -= 5
                    let action = SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false)
                    self.run(action)
                }
            case "charEnemy":
                let whackSlot = node.parent!.parent as! WhackSlot
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                whackSlot.hit() { [unowned self] in
                    self.score += 1
                    let action = SKAction.playSoundFileNamed("whack", waitForCompletion: false)
                    self.run(action)
                }
            case "gameContinue":
                node.parent?.childNode(withName: "gameOver")?.removeFromParent()
                node.removeFromParent()
                restartGame()
            default:
                continue

            }
        }
    }
    func setBackground() {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    func setGameScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
    }
    
    func createSlots() {
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numOfRounds += 1
        guard numOfRounds < 30  else {
            setGameOver()
            return
        }
        
        popupTime *= 0.991
        
        slots = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: slots) as! [WhackSlot]
        slots[0].show(hideTime: popupTime)
        
        if RandomInt(min: 0, max: 12) > 4 { slots[1].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 8 { slots[2].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 10 { slots[3].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        
        let delay = RandomDouble(min: minDelay, max: maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
            self.createEnemy()
        }
    }
    
    func setGameOver() {
        for slot in slots {
            slot.hide()
            
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.name = "gameOver"
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        addChild(gameOver)
        
        let gameContinue = SKLabelNode(fontNamed: "chalkduster")
        gameContinue.text = "Continue?"
        gameContinue.position = CGPoint(x: 512, y: 200)
        gameContinue.horizontalAlignmentMode = .center
        gameContinue.fontSize = 60
        gameContinue.zPosition = 1
        gameContinue.name = "gameContinue"
        addChild(gameContinue)
        
    }
    
    func restartGame() {
        slots = [WhackSlot]()
        createSlots()
        
        score = 0
        numOfRounds = 0
        popupTime = 0.85
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.createEnemy()
        }
    }
    
}
