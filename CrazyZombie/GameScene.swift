//
//  GameScene.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-05-31.
//  Copyright © 2018 DGames. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var zombie :SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint(x:0, y: 0)
    var playableRect : CGRect
    var destination : CGPoint = CGPoint(x:0,y:0)
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieAnimation : SKAction
    var zombieIsBlinking = false;
    
    override init(size: CGSize) {
        let maxAspectRatio : CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = ( size.height - playableHeight )/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var textures : [SKTexture] = []
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -2
//        background.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(background)
        
        zombie.position = CGPoint.init(x: 400, y: 400)
        zombie.zPosition = 1
        addChild(zombie)

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                },SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 2.0, max: 5.0)))])))
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnCat()
                },SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 1.0, max: 5.0)))])))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
//        if(destination - zombie.position).length() > (CGFloat(dt) * zombieMovePointsPerSec){
            move(sprite: zombie,velocity: velocity)
            rotate(sprite: zombie, direction: velocity, rotateRadiansPerSecond: 3)
//        }else{
//            zombie.removeAction(forKey: "ZombieWalk")
//        }
        
        boundsCheckZombie()
        moveTrain()
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        // 1
        let amountToMove = velocity * CGFloat(dt)
        // 2
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "ZombieWalk")
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        destination = touchLocation
        moveZombieToward(location: touchLocation)
        let touchPointer = SKSpriteNode.init(imageNamed: "touchMarker")
        touchPointer.zPosition = 5.0
        touchPointer.position = touchLocation
        addChild(touchPointer)
        touchPointer.setScale(1.0)
        let touchDisappear = SKAction.scale(to: 0.0, duration: 0.5)
        let touchRemove = SKAction.run {
            touchPointer.removeFromParent()
        }
        let touchActions = SKAction.sequence([touchDisappear,touchRemove])
        touchPointer.run(touchActions)
        
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//        let touchLocation = touch.location(in: self)
//        destination = touchLocation
//        moveZombieToward(location: touchLocation)
//    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0 + zombie.size.width / 2, y: playableRect.minY + zombie.size.height / 2)
        let topRight = CGPoint(x: size.width - zombie.size.width / 2, y: playableRect.maxY - zombie.size.height / 2)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSecond : CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSecond * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: playableRect.minY + enemy.size.height/2, max: playableRect.maxY - enemy.size.height/2) )
        enemy.name = "enemy"
        enemy.setScale(0.8)
        addChild(enemy)
        let action = SKAction.moveTo(x: -enemy.size.width/2, duration: 3.0)
        let actionRemove = SKAction.removeFromParent()
//        let actionMid = SKAction.moveBy(x: -size.width/2 , y: -playableRect.maxY/2 + enemy.size.height/2, duration: 1.0)
//        let actionWait = SKAction.wait(forDuration: 2.0)
//        let actionMove = SKAction.moveBy(x: -size.width/2 , y: playableRect.maxY/2 - enemy.size.height/2, duration: 1.0)
//        let sequence = SKAction.sequence([actionMid, actionWait, actionMove,actionMid.reversed(),actionMove.reversed()])
//        let repeated = SKAction.repeatForever(sequence)
//        enemy.run(repeated)
        
        enemy.run(SKAction.sequence([action,actionRemove]))
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(
            x: CGFloat.random(min: playableRect.minX + cat.size.width/2,
                              max: playableRect.maxX - cat.size.width/2),
            y: CGFloat.random(min: playableRect.minY + cat.size.height/2,
                              max: playableRect.maxY - cat.size.height/2))
        cat.name = "cat"
        cat.setScale(0)
        addChild(cat)
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = SKAction.scale(by: 1/1.2, duration: 0.25)
        let fullScale = SKAction.sequence([scaleUp,scaleDown,scaleUp,scaleDown])
        
        let group = SKAction.group([fullWiggle,fullScale])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    func zombieHit(object: SKSpriteNode){
        switch object.name {
        case "cat":do {
//            print("cat removed")
//            object.removeFromParent()
            object.removeAllActions()
            object.setScale(1.0)
            object.zRotation = 0
            object.name = "train"
            let greenAction = SKAction.colorize(with: UIColor.green, colorBlendFactor: 0.8, duration: TimeInterval(1.0))
            object.run(greenAction)
            run(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false))
            }
        case "enemy":do {
                if zombieIsBlinking == false{
//                    print("enemy removed")
//                    object.removeFromParent()
                    let blinkTimes = 10.0
                    let duration = 3.0
                    let blinkAction = SKAction.customAction(
                    withDuration: duration) { node, elapsedTime in
                        let slice = duration / blinkTimes
                        let remainder = Double(elapsedTime).truncatingRemainder(
                            dividingBy: slice)
                        node.isHidden = remainder > slice / 2
                        self.zombieIsBlinking = true
                        
                    }
                    let isNoLongerBlinkingAction = SKAction.run {
                        self.zombieIsBlinking = false;
                        self.zombie.isHidden = false;
                    }
                    
                    let zombieBlinkCodeGroup = SKAction.sequence([blinkAction,isNoLongerBlinkingAction])
                    zombie.run(zombieBlinkCodeGroup)
                    run(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false))
                    
                    let changeEnemyColour = SKAction.colorize(with: UIColor.red, colorBlendFactor:0.2, duration: 0.5)
                    object.run(changeEnemyColour)
                }
            }
        default:
            object.removeFromParent()
        }
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(object: cat)
        }
        
        var hitEnemies : [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") {node, _ in
            let enemy = node as! SKSpriteNode
            if enemy.frame.intersects(self.zombie.frame){
                hitEnemies.append(enemy)
            }
        }
        
        for enemy in hitEnemies{
            zombieHit(object: enemy)
        }
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        enumerateChildNodes(withName: "train") { node, stop in
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.zombieMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
    }
}
