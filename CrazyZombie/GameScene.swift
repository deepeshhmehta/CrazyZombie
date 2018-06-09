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
    
    var cameraRect : CGRect {
        let x = DataStore.cameraNode.position.x - size.width/2
            + (size.width - DataStore.playableRect.width)/2
        let y = DataStore.cameraNode.position.y - size.height/2
            + (size.height - DataStore.playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: DataStore.playableRect.width,
            height: DataStore.playableRect.height)
    }
    
    override func didMove(to view: SKView) {
        DataStore.lives = 5
        DataStore.catsInTrain = 0
        DataStore.gameOver = false
        DataStore.zombieIsBlinking = false
        DataStore.lastUpdateTime = 0
        DataStore.dt = 0
        
//        print("GameStats")
//        print("------")
//        print("lives: \(Values.lives)")
//        print("catsInTrain: \(Values.catsInTrain)")
//        print("gameOver: \(Values.gameOver)")
//        print("zombieIsBlinking: \(Values.zombieIsBlinking)")
//        print("lastUpdateTime: \(Values.lastUpdateTime)")
//        print("dt: \(Values.dt)")
        
        let maxAspectRatio : CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = ( size.height - playableHeight )/2.0
        DataStore.playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        for i in 0...1 {
            let background = SpawnAndAnimations.backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -3
            addChild(background)
        }
        
        DataStore.cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        camera = DataStore.cameraNode
        addChild(DataStore.cameraNode)
        
        addChild(SpawnAndAnimations.spawnZombie(x: size.width/4, y: 400))

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
        if DataStore.lastUpdateTime > 0 {
            DataStore.dt = currentTime - DataStore.lastUpdateTime
        } else {
            DataStore.dt = 0
        }
        DataStore.lastUpdateTime = currentTime
        
        if DataStore.destination.x > DataStore.zombie.position.x{
            DataStore.moveRight = true
            let pos: CGFloat = DataStore.zombie.position.x + size.width/4
//            pos = pos > size.width/2 ? pos : size.width/2
            let transitionAnimate = SKAction.moveTo(x: pos, duration: 0.5)
            DataStore.cameraNode.run(transitionAnimate)
            
            enumerateChildNodes(withName: "background") { node, _ in
                let background = node as! SKSpriteNode
                if background.position.x + background.size.width < self.cameraRect.origin.x {
                    background.position = CGPoint(
                        x: background.position.x + background.size.width*2,
                        y: background.position.y)
                }
            }
        }
        if DataStore.destination.x < DataStore.zombie.position.x {
            DataStore.moveRight = false
            let pos: CGFloat = DataStore.zombie.position.x - size.width/4
//            pos = pos > size.width/2 ? pos : size.width/2
            let transitionAnimate = SKAction.moveTo(x: pos, duration: 0.5)
            DataStore.cameraNode.run(transitionAnimate)
            
            enumerateChildNodes(withName: "background") { node, _ in
                let background = node as! SKSpriteNode
                if background.position.x > self.cameraRect.maxX{
                    background.position = CGPoint(
                        x: background.position.x - background.size.width*2,
                        y: background.position.y)
                }
            }
        }
        
        if(DataStore.destination - DataStore.zombie.position).length() > (CGFloat(DataStore.dt) * DataStore.zombieMovePointsPerSec){
            move(sprite: DataStore.zombie,velocity: DataStore.velocity)
            SpawnAndAnimations.rotate(sprite: DataStore.zombie, direction: DataStore.velocity, rotateRadiansPerSecond: 3)
        }else{
            DataStore.zombie.removeAction(forKey: "ZombieWalk")
        }
        
        boundsCheckZombie()
        moveTrain()

        if DataStore.lives < 0 && DataStore.gameOver == false{
            DataStore.gameOver = true
            print("Lost")
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            backgroundMusicPlayer.stop()
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        if DataStore.catsInTrain >= 15 && DataStore.gameOver == false{
            DataStore.gameOver = true
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
        let amountToMove = velocity * CGFloat(DataStore.dt)
        // 2
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        DataStore.zombie.run(SKAction.repeatForever(DataStore.zombieAnimation), withKey: "ZombieWalk")
        let offset = location - DataStore.zombie.position
        let direction = offset.normalized()
        DataStore.velocity = direction * DataStore.zombieMovePointsPerSec
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
            let touchLocation = touch.location(in: self)
            DataStore.destination = touchLocation
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
            DataStore.destination = touchLocation
            moveZombieToward(location: touchLocation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: DataStore.zombie.size.width/2 + cameraRect.minX, y: cameraRect.minY + DataStore.zombie.size.height / 2)
        let topRight = CGPoint(x: cameraRect.maxX - DataStore.zombie.size.width / 2, y: cameraRect.maxY - DataStore.zombie.size.height / 2)
        
        SpawnAndAnimations.boundsCheckZombie(bottomLeft: bottomLeft, topRight: topRight)
    }
    
    func spawnEnemyPrimary(){
        let enemy = SpawnAndAnimations.spawnEnemyPrimary()
        
        enemy.position.y =  CGFloat.random(min: cameraRect.minY + enemy.size.height/2, max: cameraRect.maxY - enemy.size.height/2)
        enemy.position.x = DataStore.moveRight ? cameraRect.maxX + enemy.size.width : cameraRect.minX - enemy.size.width
        
        let dest = DataStore.moveRight ? cameraRect.minX - enemy.size.width/2 : cameraRect.maxX + enemy.size.width/2
        let  action = SKAction.moveTo(x: dest, duration: 4.0)
        
        let actionRemove = SKAction.removeFromParent()
        addChild(enemy)
        enemy.run(SKAction.sequence([action,actionRemove]))
    }
    
    func spawnCat() {
        let cat = SpawnAndAnimations.spawnCat()
        cat.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX + cat.size.width/2,
                              max: cameraRect.maxX - cat.size.width/2),
            y: CGFloat.random(min: cameraRect.minY + cat.size.height/2,
                              max: cameraRect.maxY - cat.size.height/2))
        addChild(cat)
        
        cat.run(SpawnAndAnimations.catAnimation())
    }
    
    
    func checkCollisions() {
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(DataStore.zombie.frame) {
                SpawnAndAnimations.zombieHit(object: cat,scene: self)
            }
        }
        
        enumerateChildNodes(withName: "enemy") {node, _ in
            let enemy = node as! SKSpriteNode
            if enemy.frame.intersects(DataStore.zombie.frame){
                SpawnAndAnimations.zombieHit(object: enemy, scene: self)
            }
        }
        
    }
    
    func moveTrain() {
        var targetPosition = DataStore.zombie.position
        enumerateChildNodes(withName: "train") { node, stop in
            if !node.hasActions() {
                node.xScale = DataStore.moveRight ? 1.0 : -1.0
                SpawnAndAnimations.moveCatTrain(cat: node as! SKSpriteNode, targetPosition: targetPosition)
            }
            targetPosition = node.position
        }
    }
    
    func looseCats(){
        var looseCount = 0
        enumerateChildNodes(withName: "train"){ node, stop in
            let randomX = CGFloat.random(min: 0, max: self.size.width)
            let randomY = CGFloat.random(min: self.cameraRect.minY, max: self.cameraRect.maxY)
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
            DataStore.catsInTrain -= 1

            if looseCount >= 2{
                stop[0] = true
            }
            
        }
    }
}
