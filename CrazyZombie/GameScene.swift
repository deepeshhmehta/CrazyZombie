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
    
    private var zombie :SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
    let zombieAnimation : SKAction
    let cameraNode : SKCameraNode = SKCameraNode()
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var zombieMovePointsPerSec: CGFloat = 480.0
    let cameraMovePointsPerSec: CGFloat = 200.0
    
    var velocity = CGPoint(x:0, y: 0)
    var playableRect : CGRect
    var destination : CGPoint = CGPoint(x:0,y:0)

    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    var lives = 5
    var catsInTrain = 0
    var zombieIsBlinking = false
    var gameOver = false
    var moveRight = true
    
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
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -3
            addChild(background)
        }
        
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        camera = cameraNode
        addChild(cameraNode)
        
        zombie.position = CGPoint.init(x: size.width/4, y: 400)
        zombie.zPosition = 1
        addChild(zombie)

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemyPrimary()
                },SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 2.0, max: 5.0)))])))
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnCat()
                },SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 1.0, max: 5.0)))])))
        
        playBackgroundMusic(filename: "backgroundMusic.mp3")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
//        if zombie.position.x >= size.width/3 {
//            cameraNode.position.x = zombie.position.x + size.width/3
//        }
        
        if destination.x > zombie.position.x{
            print("A")
            print("destination: \(destination.x)")
            print("zombie: \(zombie.position.x)")
            self.moveRight = true
            var pos: CGFloat = zombie.position.x + size.width/4
//            pos = pos > size.width/2 ? pos : size.width/2
            let transitionAnimate = SKAction.moveTo(x: pos, duration: 0.5)
            cameraNode.run(transitionAnimate)
            
            enumerateChildNodes(withName: "background") { node, _ in
                let background = node as! SKSpriteNode
                if background.position.x + background.size.width < self.cameraRect.origin.x {
                    background.position = CGPoint(
                        x: background.position.x + background.size.width*2,
                        y: background.position.y)
                }
            }
        }
        if destination.x < zombie.position.x {
            print("B")
            print("destination: \(destination.x)")
            print("zombie: \(zombie.position.x)")
            self.moveRight = false
            var pos: CGFloat = zombie.position.x - size.width/4
//            pos = pos > size.width/2 ? pos : size.width/2
            let transitionAnimate = SKAction.moveTo(x: pos, duration: 0.5)
            cameraNode.run(transitionAnimate)
            
            enumerateChildNodes(withName: "background") { node, _ in
                let background = node as! SKSpriteNode
                if background.position.x > self.cameraRect.maxX{
                    background.position = CGPoint(
                        x: background.position.x - background.size.width*2,
                        y: background.position.y)
                }
            }
        }
        
        if(destination - zombie.position).length() > (CGFloat(dt) * zombieMovePointsPerSec){
            move(sprite: zombie,velocity: velocity)
            rotate(sprite: zombie, direction: velocity, rotateRadiansPerSecond: 3)
        }else{
            zombie.removeAction(forKey: "ZombieWalk")
        }
        
        boundsCheckZombie()
        moveTrain()

        if lives < 0 && gameOver == false{
            gameOver = true
            print("Lost")
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            backgroundMusicPlayer.stop()
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        if catsInTrain >= 15 && gameOver == false{
            gameOver = true
            print("Won")
            let gameWonScene = GameOverScene(size: size, won: true)
            gameWonScene.scaleMode = scaleMode
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            backgroundMusicPlayer.stop()
            view?.presentScene(gameWonScene, transition: reveal)
        }
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width <
                self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            destination = touchLocation
            moveZombieToward(location: touchLocation)
        }
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
        let bottomLeft = CGPoint(x: zombie.size.width/2 + cameraRect.minX, y: cameraRect.minY + zombie.size.height / 2)
        let topRight = CGPoint(x: cameraRect.maxX - zombie.size.width / 2, y: cameraRect.maxY - zombie.size.height / 2)
        
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
    
    func spawnEnemyPrimary(){
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.setScale(0.8)
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width, y: CGFloat.random(min: cameraRect.minY + enemy.size.height/2, max: cameraRect.maxY - enemy.size.height/2) )
        var action = SKAction.moveTo(x: cameraRect.minX - enemy.size.width/2, duration: 4.0)
        let actionRemove = SKAction.removeFromParent()
        
        if !self.moveRight{
            enemy.xScale = -0.8
            enemy.position.x = cameraRect.minX - enemy.size.width
            action = SKAction.moveTo(x: cameraRect.maxX + enemy.size.width/2, duration: 4.0)
        }
//        let actionMid = SKAction.moveBy(x: -size.width/2 , y: -playableRect.maxY/2 + enemy.size.height/2, duration: 1.0)
//        let actionWait = SKAction.wait(forDuration: 2.0)
//        let actionMove = SKAction.moveBy(x: -size.width/2 , y: playableRect.maxY/2 - enemy.size.height/2, duration: 1.0)
//        let sequence = SKAction.sequence([actionMid, actionWait, actionMove,actionMid.reversed(),actionMove.reversed()])
//        let repeated = SKAction.repeatForever(sequence)
//        enemy.run(repeated)
        
        addChild(enemy)
        enemy.run(SKAction.sequence([action,actionRemove]))
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX + cat.size.width/2,
                              max: cameraRect.maxX - cat.size.width/2),
            y: CGFloat.random(min: cameraRect.minY + cat.size.height/2,
                              max: cameraRect.maxY - cat.size.height/2))
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
            self.catsInTrain += 1
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
                    
                    looseCats()
                    self.lives -= 1
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
                node.xScale = self.moveRight ? 1.0 : -1.0
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
    
    func looseCats(){
        var looseCount = 0
        enumerateChildNodes(withName: "train"){ node, stop in
            let randomX = CGFloat.random(min: 0, max: self.size.width)
            let randomY = CGFloat.random(min: self.playableRect.minY, max: self.playableRect.maxY)
            node.removeAllActions()
            node.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x:randomX, y:randomY), duration: 1.0),
                    SKAction.rotate(byAngle: 3.14 * 4, duration: 1.0),
                    SKAction.colorize(with: UIColor.black, colorBlendFactor: 1.0, duration: 1.0)
                    ]),
                SKAction.removeFromParent()
                ]))
            looseCount += 1
            self.catsInTrain -= 1

            if looseCount >= 2{
                stop[0] = true
            }
            
        }
    }
    
    func backgroundNode() -> SKSpriteNode {
        // 1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        // 2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        // 3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        
        backgroundNode.zPosition = -2
        backgroundNode.name = "background"
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity =
            CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
    }
    
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2
            + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2
            + (size.height - playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }
}
